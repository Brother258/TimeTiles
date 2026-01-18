import 'package:flutter/material.dart';

class MarginEditor extends StatelessWidget {
  final double topMargin;
  final double bottomMargin;
  final ValueChanged<double> onTopMarginChanged;
  final ValueChanged<double> onBottomMarginChanged;

  const MarginEditor({
    super.key,
    required this.topMargin,
    required this.bottomMargin,
    required this.onTopMarginChanged,
    required this.onBottomMarginChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  'Top Margin',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Slider(
                  value: topMargin,
                  min: 5.0,
                  max: 40.0,
                  divisions: 35,
                  label: '${topMargin.toStringAsFixed(0)}%',
                  onChanged: onTopMarginChanged,
                ),
              ),
              SizedBox(
                width: 45,
                child: Text(
                  '${topMargin.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  'Bottom Margin',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Slider(
                  value: bottomMargin,
                  min: 5.0,
                  max: 40.0,
                  divisions: 35,
                  label: '${bottomMargin.toStringAsFixed(0)}%',
                  onChanged: onBottomMarginChanged,
                ),
              ),
              SizedBox(
                width: 45,
                child: Text(
                  '${bottomMargin.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
