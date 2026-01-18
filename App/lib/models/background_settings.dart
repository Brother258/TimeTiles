import 'package:flutter/material.dart';

enum BackgroundType {
  solidColor,
  linearGradient,
  radialGradient,
  sweepGradient,
  image,
}

class BackgroundSettings {
  final BackgroundType type;
  final Color solidColor;
  final List<Color> gradientColors;
  final double gradientAngle;
  final String? imagePath;

  const BackgroundSettings({
    this.type = BackgroundType.solidColor,
    this.solidColor = Colors.black,
    this.gradientColors = const [Colors.black, Colors.deepPurple],
    this.gradientAngle = 0.0,
    this.imagePath,
  });

  BackgroundSettings copyWith({
    BackgroundType? type,
    Color? solidColor,
    List<Color>? gradientColors,
    double? gradientAngle,
    String? imagePath,
  }) {
    return BackgroundSettings(
      type: type ?? this.type,
      solidColor: solidColor ?? this.solidColor,
      gradientColors: gradientColors ?? this.gradientColors,
      gradientAngle: gradientAngle ?? this.gradientAngle,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'solidColor': _colorToInt(solidColor),
      'gradientColors': gradientColors.map((c) => _colorToInt(c)).toList(),
      'gradientAngle': gradientAngle,
      'imagePath': imagePath ?? '',
    };
  }

  static int _colorToInt(Color color) {
    return (color.a * 255).toInt() << 24 |
        (color.r * 255).toInt() << 16 |
        (color.g * 255).toInt() << 8 |
        (color.b * 255).toInt();
  }

  factory BackgroundSettings.fromMap(Map<String, dynamic> map) {
    return BackgroundSettings(
      type: BackgroundType.values[map['type'] as int? ?? 0],
      solidColor: Color(map['solidColor'] as int? ?? 0xFF000000),
      gradientColors: (map['gradientColors'] as List?)
              ?.map((c) => Color(c as int))
              .toList() ??
          [Colors.black, Colors.deepPurple],
      gradientAngle: (map['gradientAngle'] as num?)?.toDouble() ?? 0.0,
      imagePath: map['imagePath'] as String?,
    );
  }

  static List<BackgroundSettings> get presets => [
        const BackgroundSettings(
          type: BackgroundType.solidColor,
          solidColor: Colors.black,
        ),
        const BackgroundSettings(
          type: BackgroundType.solidColor,
          solidColor: Color(0xFF1A1A2E),
        ),
        const BackgroundSettings(
          type: BackgroundType.solidColor,
          solidColor: Color(0xFF0F0F23),
        ),
        const BackgroundSettings(
          type: BackgroundType.linearGradient,
          gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)],
          gradientAngle: 135,
        ),
        const BackgroundSettings(
          type: BackgroundType.linearGradient,
          gradientColors: [Color(0xFF11998e), Color(0xFF38ef7d)],
          gradientAngle: 90,
        ),
        const BackgroundSettings(
          type: BackgroundType.linearGradient,
          gradientColors: [
            Color(0xFF833ab4),
            Color(0xFFfd1d1d),
            Color(0xFFfcb045)
          ],
          gradientAngle: 135,
        ),
        const BackgroundSettings(
          type: BackgroundType.linearGradient,
          gradientColors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
          gradientAngle: 180,
        ),
        const BackgroundSettings(
          type: BackgroundType.linearGradient,
          gradientColors: [
            Color(0xFF0f0c29),
            Color(0xFF302b63),
            Color(0xFF24243e)
          ],
          gradientAngle: 180,
        ),
        const BackgroundSettings(
          type: BackgroundType.radialGradient,
          gradientColors: [
            Color(0xFF3a1c71),
            Color(0xFFd76d77),
            Color(0xFFffaf7b)
          ],
        ),
        const BackgroundSettings(
          type: BackgroundType.radialGradient,
          gradientColors: [Color(0xFF200122), Color(0xFF6f0000)],
        ),
        const BackgroundSettings(
          type: BackgroundType.sweepGradient,
          gradientColors: [
            Color(0xFFff0000),
            Color(0xFFff7f00),
            Color(0xFFffff00),
            Color(0xFF00ff00),
            Color(0xFF0000ff),
            Color(0xFF4b0082),
            Color(0xFF9400d3),
          ],
        ),
      ];
}
