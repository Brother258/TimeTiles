import 'package:flutter/material.dart';
import '../services/wallpaper_channel_service.dart';

class ColumnCountEditor extends StatelessWidget {
  final int columnCount;
  final ValueChanged<int> onColumnCountChanged;

  const ColumnCountEditor({
    super.key,
    required this.columnCount,
    required this.onColumnCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: const Text(
        'Grid Columns',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: columnCount > WallpaperChannelService.minColumnCount
                  ? () => onColumnCountChanged(columnCount - 1)
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.white70,
              disabledColor: Colors.white24,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$columnCount columns',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: columnCount < WallpaperChannelService.maxColumnCount
                  ? () => onColumnCountChanged(columnCount + 1)
                  : null,
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.white70,
              disabledColor: Colors.white24,
            ),
          ],
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.tune, color: Colors.white70),
        onPressed: () => _showSliderDialog(context),
        tooltip: 'Fine-tune columns',
      ),
    );
  }

  void _showSliderDialog(BuildContext context) {
    int tempColumnCount = columnCount;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text(
                'Adjust Grid Columns',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$tempColumnCount columns',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: tempColumnCount.toDouble(),
                    min: WallpaperChannelService.minColumnCount.toDouble(),
                    max: WallpaperChannelService.maxColumnCount.toDouble(),
                    divisions: WallpaperChannelService.maxColumnCount -
                        WallpaperChannelService.minColumnCount,
                    label: '$tempColumnCount',
                    onChanged: (value) {
                      setDialogState(() {
                        tempColumnCount = value.round();
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '${WallpaperChannelService.minColumnCount} - ${WallpaperChannelService.maxColumnCount} columns',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    onColumnCountChanged(tempColumnCount);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
