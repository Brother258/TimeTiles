import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/background_settings.dart';
import '../services/wallpaper_channel_service.dart';
import '../utils/color_utils.dart';
import '../widgets/year_grid_preview.dart';
import '../widgets/color_picker_tile.dart';
import '../widgets/quote_editor.dart';
import '../widgets/column_count_editor.dart';
import '../widgets/donation_section.dart';
import '../widgets/margin_editor.dart';
import '../widgets/background_editor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color _pastColor = const Color(0xFF4CAF50);
  Color _currentDayColor = const Color(0xFFFF9800);
  Color _emptyColor = const Color(0xFF424242);
  String _quote = WallpaperChannelService.defaultQuote;
  int _columnCount = WallpaperChannelService.defaultColumnCount;

  double _topMargin = WallpaperChannelService.defaultTopMargin;
  double _bottomMargin = WallpaperChannelService.defaultBottomMargin;
  BackgroundSettings _backgroundSettings = const BackgroundSettings();

  bool _isLoading = true;
  bool _isSaving = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    try {
      final colors = await WallpaperChannelService.getColors();
      final quote = await WallpaperChannelService.getQuote();
      final columnCount = await WallpaperChannelService.getColumnCount();
      final margins = await WallpaperChannelService.getMargins();
      final backgroundSettings =
          await WallpaperChannelService.getBackgroundSettings();

      if (mounted) {
        setState(() {
          _pastColor = Color(colors['pastColor']!);
          _currentDayColor = Color(colors['currentColor']!);
          _emptyColor = Color(colors['emptyColor']!);
          _quote = quote;
          _columnCount = columnCount;
          _topMargin = margins['topMargin']!;
          _bottomMargin = margins['bottomMargin']!;
          _backgroundSettings = backgroundSettings;
          _isLoading = false;
        });
      }
    } on WallpaperChannelException catch (e) {
      debugPrint('Failed to load settings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveAllSettings() async {
    setState(() => _isSaving = true);

    try {
      await WallpaperChannelService.saveColors(
        pastColor: ColorUtils.colorToArgb(_pastColor),
        currentColor: ColorUtils.colorToArgb(_currentDayColor),
        emptyColor: ColorUtils.colorToArgb(_emptyColor),
      );
      await WallpaperChannelService.saveQuote(_quote);
      await WallpaperChannelService.saveColumnCount(_columnCount);
      await WallpaperChannelService.saveMargins(
        topMargin: _topMargin,
        bottomMargin: _bottomMargin,
      );
      await WallpaperChannelService.saveBackgroundSettings(_backgroundSettings);

      await WallpaperChannelService.refreshWallpaper();

      _showSuccessSnackbar('Settings saved');
    } on WallpaperChannelException catch (e) {
      _showErrorSnackbar('Failed to save settings: ${e.message}');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _openWallpaperChooser() async {
    await _saveAllSettings();

    try {
      await WallpaperChannelService.openWallpaperChooser();
    } on WallpaperChannelException catch (e) {
      _showErrorSnackbar('Failed to open wallpaper chooser: ${e.message}');
    }
  }

  Future<void> _pickBackgroundImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName =
            'wallpaper_bg_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedPath = '${appDir.path}/$fileName';

        await File(image.path).copy(savedPath);

        setState(() {
          _backgroundSettings = _backgroundSettings.copyWith(
            type: BackgroundType.image,
            imagePath: savedPath,
          );
        });
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Text('TimeTiles'),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: YearGridPreview(
                        pastColor: _pastColor,
                        currentDayColor: _currentDayColor,
                        emptyColor: _emptyColor,
                        quote: _quote,
                        columnCount: _columnCount,
                        backgroundSettings: _backgroundSettings,
                        topMarginPercent: _topMargin,
                        bottomMarginPercent: _bottomMargin,
                      ),
                    ),
                  ),
                  _buildSectionHeader('Background'),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: BackgroundEditor(
                      settings: _backgroundSettings,
                      onSettingsChanged: (settings) {
                        setState(() => _backgroundSettings = settings);
                      },
                      onPickImage: _pickBackgroundImage,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Block Colors'),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        ColorPickerTile(
                          label: 'Past Days Color',
                          color: _pastColor,
                          onColorChanged: (color) {
                            setState(() => _pastColor = color);
                          },
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ColorPickerTile(
                          label: 'Current Day Color',
                          color: _currentDayColor,
                          onColorChanged: (color) {
                            setState(() => _currentDayColor = color);
                          },
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ColorPickerTile(
                          label: 'Future Days Color',
                          color: _emptyColor,
                          onColorChanged: (color) {
                            setState(() => _emptyColor = color);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Layout Margins'),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: MarginEditor(
                      topMargin: _topMargin,
                      bottomMargin: _bottomMargin,
                      onTopMarginChanged: (value) {
                        setState(() => _topMargin = value);
                      },
                      onBottomMarginChanged: (value) {
                        setState(() => _bottomMargin = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Quote'),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: QuoteEditor(
                      quote: _quote,
                      onQuoteChanged: (newQuote) {
                        setState(() => _quote = newQuote);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Grid Layout'),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: ColumnCountEditor(
                      columnCount: _columnCount,
                      onColumnCountChanged: (newCount) {
                        setState(() => _columnCount = newCount);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isSaving ? null : _saveAllSettings,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: const Text('Save Settings'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _isSaving ? null : _openWallpaperChooser,
                          icon: const Icon(Icons.wallpaper),
                          label: const Text('Set as Wallpaper'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const DonationSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
