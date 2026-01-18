import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/background_settings.dart';

class BackgroundEditor extends StatefulWidget {
  final BackgroundSettings settings;
  final ValueChanged<BackgroundSettings> onSettingsChanged;
  final VoidCallback onPickImage;

  const BackgroundEditor({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required this.onPickImage,
  });

  @override
  State<BackgroundEditor> createState() => _BackgroundEditorState();
}

class _BackgroundEditorState extends State<BackgroundEditor> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Background Type',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTypeChip(
                  'Solid',
                  Icons.square_rounded,
                  BackgroundType.solidColor,
                ),
                const SizedBox(width: 8),
                _buildTypeChip(
                  'Linear',
                  Icons.gradient,
                  BackgroundType.linearGradient,
                ),
                const SizedBox(width: 8),
                _buildTypeChip(
                  'Radial',
                  Icons.blur_circular,
                  BackgroundType.radialGradient,
                ),
                const SizedBox(width: 8),
                _buildTypeChip(
                  'Sweep',
                  Icons.donut_large,
                  BackgroundType.sweepGradient,
                ),
                const SizedBox(width: 8),
                _buildTypeChip(
                  'Image',
                  Icons.image,
                  BackgroundType.image,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (widget.settings.type == BackgroundType.solidColor)
            _buildSolidColorPicker(),
          if (widget.settings.type == BackgroundType.linearGradient ||
              widget.settings.type == BackgroundType.radialGradient ||
              widget.settings.type == BackgroundType.sweepGradient)
            _buildGradientEditor(),
          if (widget.settings.type == BackgroundType.image) _buildImagePicker(),
          const SizedBox(height: 16),
          Text(
            'Presets',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: BackgroundSettings.presets.length,
              itemBuilder: (context, index) {
                final preset = BackgroundSettings.presets[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => widget.onSettingsChanged(preset),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white24,
                          width: 1,
                        ),
                        gradient: _getPresetGradient(preset),
                        color: preset.type == BackgroundType.solidColor
                            ? preset.solidColor
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, IconData icon, BackgroundType type) {
    final isSelected = widget.settings.type == type;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.black : Colors.white70,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (_) {
        widget.onSettingsChanged(widget.settings.copyWith(type: type));
      },
    );
  }

  Widget _buildSolidColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Background Color',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showColorPicker(
            widget.settings.solidColor,
            (color) => widget.onSettingsChanged(
              widget.settings.copyWith(solidColor: color),
            ),
          ),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: widget.settings.solidColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: const Center(
              child: Text(
                'Tap to change color',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gradient Colors (tap to edit)',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.settings.gradientColors.length + 1,
            itemBuilder: (context, index) {
              if (index == widget.settings.gradientColors.length) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () {
                      final newColors =
                          List<Color>.from(widget.settings.gradientColors)
                            ..add(Colors.white);
                      widget.onSettingsChanged(
                        widget.settings.copyWith(gradientColors: newColors),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.add, color: Colors.white70),
                    ),
                  ),
                );
              }
              final color = widget.settings.gradientColors[index];
              return Padding(
                padding: EdgeInsets.only(left: index > 0 ? 8 : 0),
                child: GestureDetector(
                  onTap: () => _showColorPicker(
                    color,
                    (newColor) {
                      final newColors =
                          List<Color>.from(widget.settings.gradientColors);
                      newColors[index] = newColor;
                      widget.onSettingsChanged(
                        widget.settings.copyWith(gradientColors: newColors),
                      );
                    },
                  ),
                  onLongPress: () {
                    if (widget.settings.gradientColors.length > 2) {
                      final newColors =
                          List<Color>.from(widget.settings.gradientColors)
                            ..removeAt(index);
                      widget.onSettingsChanged(
                        widget.settings.copyWith(gradientColors: newColors),
                      );
                    }
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.settings.type == BackgroundType.linearGradient) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Angle: ${widget.settings.gradientAngle.toStringAsFixed(0)}°',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              Expanded(
                child: Slider(
                  value: widget.settings.gradientAngle,
                  min: 0,
                  max: 360,
                  divisions: 36,
                  onChanged: (value) {
                    widget.onSettingsChanged(
                      widget.settings.copyWith(gradientAngle: value),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Background Image',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: widget.onPickImage,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
              image: widget.settings.imagePath != null &&
                      widget.settings.imagePath!.isNotEmpty
                  ? DecorationImage(
                      image: FileImage(File(widget.settings.imagePath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.settings.imagePath == null ||
                    widget.settings.imagePath!.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate,
                            color: Colors.white70, size: 32),
                        SizedBox(height: 4),
                        Text(
                          'Tap to select image',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Gradient? _getPresetGradient(BackgroundSettings preset) {
    if (preset.type == BackgroundType.solidColor) return null;

    switch (preset.type) {
      case BackgroundType.linearGradient:
        final angle = preset.gradientAngle * 3.14159 / 180;
        return LinearGradient(
          begin: Alignment(
            -1 * (angle == 0 ? 0 : (angle < 180 ? 1 : -1)),
            -1,
          ),
          end: Alignment(
            angle == 0 ? 0 : (angle < 180 ? -1 : 1),
            1,
          ),
          colors: preset.gradientColors,
        );
      case BackgroundType.radialGradient:
        return RadialGradient(colors: preset.gradientColors);
      case BackgroundType.sweepGradient:
        return SweepGradient(colors: preset.gradientColors);
      default:
        return null;
    }
  }

  void _showColorPicker(Color currentColor, ValueChanged<Color> onColorPicked) {
    Color pickedColor = currentColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) => pickedColor = color,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onColorPicked(pickedColor);
              Navigator.pop(context);
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }
}
