import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/year_utils.dart';
import '../models/background_settings.dart';

class YearGridPainter extends CustomPainter {
  final Color pastColor;
  final Color currentDayColor;
  final Color emptyColor;
  final BackgroundSettings backgroundSettings;
  final int columnCount;
  final String? quote;
  final bool showQuote;
  final double topMarginPercent;
  final double bottomMarginPercent;
  final ui.Image? backgroundImage;

  static const double blockSpacing = 3.0;

  YearGridPainter({
    required this.pastColor,
    required this.currentDayColor,
    required this.emptyColor,
    this.backgroundSettings = const BackgroundSettings(),
    this.columnCount = 7,
    this.quote,
    this.showQuote = true,
    this.topMarginPercent = 20.0,
    this.bottomMarginPercent = 20.0,
    this.backgroundImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);

    final currentYear = YearUtils.getCurrentYear();
    final totalDays = YearUtils.getTotalDaysInYear(currentYear);
    final currentDayOfYear = YearUtils.getCurrentDayOfYear();

    final topMargin = size.height * (topMarginPercent / 100.0);
    final bottomMargin = size.height * (bottomMarginPercent / 100.0);

    final contentHeight = size.height - topMargin - bottomMargin;
    final contentWidth = size.width * 0.95;
    final contentStartX = (size.width - contentWidth) / 2;

    final gridHeight = contentHeight * 0.65;
    final quoteHeight = contentHeight * 0.25;
    final spacing = contentHeight * 0.05;

    _drawGrid(
      canvas,
      contentStartX,
      topMargin,
      contentWidth,
      gridHeight,
      totalDays,
      currentDayOfYear,
    );

    final gridEndY = topMargin + gridHeight + spacing;
    _drawYearAndProgress(
      canvas,
      size.width / 2,
      gridEndY,
      currentYear,
      currentDayOfYear,
      totalDays,
    );

    if (showQuote && quote != null && quote!.isNotEmpty) {
      final quoteStartY = size.height - bottomMargin - quoteHeight;
      _drawQuote(canvas, size.width / 2, quoteStartY, contentWidth, quote!);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    switch (backgroundSettings.type) {
      case BackgroundType.solidColor:
        final paint = Paint()..color = backgroundSettings.solidColor;
        canvas.drawRect(rect, paint);
        break;

      case BackgroundType.linearGradient:
        final angle = backgroundSettings.gradientAngle * math.pi / 180;
        final gradient = LinearGradient(
          begin: Alignment(
            math.cos(angle + math.pi),
            math.sin(angle + math.pi),
          ),
          end: Alignment(
            math.cos(angle),
            math.sin(angle),
          ),
          colors: backgroundSettings.gradientColors,
        );
        final paint = Paint()..shader = gradient.createShader(rect);
        canvas.drawRect(rect, paint);
        break;

      case BackgroundType.radialGradient:
        final gradient = RadialGradient(
          colors: backgroundSettings.gradientColors,
          center: Alignment.center,
          radius: 1.0,
        );
        final paint = Paint()..shader = gradient.createShader(rect);
        canvas.drawRect(rect, paint);
        break;

      case BackgroundType.sweepGradient:
        final gradient = SweepGradient(
          colors: backgroundSettings.gradientColors,
          center: Alignment.center,
        );
        final paint = Paint()..shader = gradient.createShader(rect);
        canvas.drawRect(rect, paint);
        break;

      case BackgroundType.image:
        if (backgroundImage != null) {
          final srcRect = Rect.fromLTWH(
            0,
            0,
            backgroundImage!.width.toDouble(),
            backgroundImage!.height.toDouble(),
          );
          canvas.drawImageRect(backgroundImage!, srcRect, rect, Paint());
        } else {
          final paint = Paint()..color = backgroundSettings.solidColor;
          canvas.drawRect(rect, paint);
        }
        break;
    }
  }

  void _drawGrid(
    Canvas canvas,
    double startX,
    double startY,
    double width,
    double height,
    int totalDays,
    int currentDayOfYear,
  ) {
    final rowCount = (totalDays / columnCount).ceil();

    final blockWidthWithSpacing = width / columnCount;
    final blockHeightWithSpacing = height / rowCount;

    final blockSizeWithSpacing =
        math.min(blockWidthWithSpacing, blockHeightWithSpacing);
    final blockSize = blockSizeWithSpacing - blockSpacing;

    final gridWidth = blockSizeWithSpacing * columnCount;
    final gridHeight = blockSizeWithSpacing * rowCount;

    final gridStartX = startX + (width - gridWidth) / 2;
    final gridStartY = startY + (height - gridHeight) / 2;

    final blockPaint = Paint()..style = PaintingStyle.fill;

    for (int day = 1; day <= totalDays; day++) {
      final index = day - 1;
      final col = index % columnCount;
      final row = index ~/ columnCount;

      final x = gridStartX + (col * blockSizeWithSpacing);
      final y = gridStartY + (row * blockSizeWithSpacing);

      if (day < currentDayOfYear) {
        blockPaint.color = pastColor;
      } else if (day == currentDayOfYear) {
        blockPaint.color = currentDayColor;
      } else {
        blockPaint.color = emptyColor;
      }

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, blockSize, blockSize),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, blockPaint);
    }
  }

  void _drawYearAndProgress(
    Canvas canvas,
    double centerX,
    double y,
    int year,
    int currentDay,
    int totalDays,
  ) {
    final percentage = ((currentDay / totalDays) * 100).toStringAsFixed(2);
    final text = '$year - $percentage% complete';

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2, y),
    );
  }

  void _drawQuote(
      Canvas canvas, double centerX, double y, double maxWidth, String quote) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '"$quote"',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 3,
    );

    textPainter.layout(maxWidth: maxWidth * 0.9);
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2, y),
    );
  }

  @override
  bool shouldRepaint(covariant YearGridPainter oldDelegate) {
    return oldDelegate.pastColor != pastColor ||
        oldDelegate.currentDayColor != currentDayColor ||
        oldDelegate.emptyColor != emptyColor ||
        oldDelegate.backgroundSettings.type != backgroundSettings.type ||
        oldDelegate.backgroundSettings.solidColor !=
            backgroundSettings.solidColor ||
        oldDelegate.columnCount != columnCount ||
        oldDelegate.quote != quote ||
        oldDelegate.showQuote != showQuote ||
        oldDelegate.topMarginPercent != topMarginPercent ||
        oldDelegate.bottomMarginPercent != bottomMarginPercent ||
        oldDelegate.backgroundImage != backgroundImage;
  }
}
