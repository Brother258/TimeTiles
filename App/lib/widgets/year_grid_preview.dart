import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../painters/year_grid_painter.dart';
import '../models/background_settings.dart';

class YearGridPreview extends StatefulWidget {
  final Color pastColor;
  final Color currentDayColor;
  final Color emptyColor;
  final String quote;
  final int columnCount;
  final BackgroundSettings backgroundSettings;
  final double topMarginPercent;
  final double bottomMarginPercent;

  const YearGridPreview({
    super.key,
    required this.pastColor,
    required this.currentDayColor,
    required this.emptyColor,
    required this.quote,
    this.columnCount = 7,
    this.backgroundSettings = const BackgroundSettings(),
    this.topMarginPercent = 20.0,
    this.bottomMarginPercent = 20.0,
  });

  @override
  State<YearGridPreview> createState() => _YearGridPreviewState();
}

class _YearGridPreviewState extends State<YearGridPreview> {
  ui.Image? _backgroundImage;

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage();
  }

  @override
  void didUpdateWidget(YearGridPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.backgroundSettings.imagePath !=
        widget.backgroundSettings.imagePath) {
      _loadBackgroundImage();
    }
  }

  Future<void> _loadBackgroundImage() async {
    if (widget.backgroundSettings.type == BackgroundType.image &&
        widget.backgroundSettings.imagePath != null &&
        widget.backgroundSettings.imagePath!.isNotEmpty) {
      try {
        final file = File(widget.backgroundSettings.imagePath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          if (mounted) {
            setState(() {
              _backgroundImage = frame.image;
            });
          }
        }
      } catch (e) {
        debugPrint('Failed to load background image: $e');
      }
    } else {
      if (mounted && _backgroundImage != null) {
        setState(() {
          _backgroundImage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white24,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 9 / 19.5,
          child: CustomPaint(
            painter: YearGridPainter(
              pastColor: widget.pastColor,
              currentDayColor: widget.currentDayColor,
              emptyColor: widget.emptyColor,
              columnCount: widget.columnCount,
              quote: widget.quote,
              showQuote: true,
              backgroundSettings: widget.backgroundSettings,
              topMarginPercent: widget.topMarginPercent,
              bottomMarginPercent: widget.bottomMarginPercent,
              backgroundImage: _backgroundImage,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}
