import 'package:flutter/material.dart';

class ColorUtils {
  static int colorToArgb(Color color) {
    final a = (color.a * 255).round();
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    return (a << 24) | (r << 16) | (g << 8) | b;
  }

  static Color argbToColor(int argb) {
    return Color.fromARGB(
      (argb >> 24) & 0xFF,
      (argb >> 16) & 0xFF,
      (argb >> 8) & 0xFF,
      argb & 0xFF,
    );
  }

  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
