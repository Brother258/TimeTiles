import 'package:flutter/material.dart';
import '../services/wallpaper_channel_service.dart';

class QuoteEditor extends StatefulWidget {
  final String quote;
  final ValueChanged<String> onQuoteChanged;

  const QuoteEditor({
    super.key,
    required this.quote,
    required this.onQuoteChanged,
  });

  @override
  State<QuoteEditor> createState() => _QuoteEditorState();
}

class _QuoteEditorState extends State<QuoteEditor> {
  CustomQuoteInfo? _customQuoteInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomQuoteInfo();
  }

  Future<void> _loadCustomQuoteInfo() async {
    try {
      final info = await WallpaperChannelService.getCustomQuote();
      setState(() {
        _customQuoteInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2D2D2D),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quote Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_customQuoteInfo?.hasCustomQuote == true)
                  TextButton.icon(
                    onPressed: _clearCustomQuote,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Use Daily Quotes'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildQuoteStatus(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showQuoteEditor(context),
                icon: const Icon(Icons.add),
                label: Text(
                  _customQuoteInfo?.hasCustomQuote == true
                      ? 'Change Custom Quote'
                      : 'Set Custom Quote',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteStatus() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_customQuoteInfo?.hasCustomQuote == true) {
      final info = _customQuoteInfo!;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.format_quote,
                    color: Colors.deepPurple, size: 20),
                const SizedBox(width: 8),
                Text(
                  info.isPermanent ? 'Permanent Quote' : 'Custom Quote',
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!info.isPermanent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${info.remainingDays} day${info.remainingDays == 1 ? '' : 's'} left',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '"${info.quote}"',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Using Daily Rotating Quotes',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '100 motivational quotes that change daily',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCustomQuote() async {
    try {
      await WallpaperChannelService.clearCustomQuote();
      await _loadCustomQuoteInfo();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Switched to daily rotating quotes!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear quote: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showQuoteEditor(BuildContext context) {
    final quoteController = TextEditingController(
      text: _customQuoteInfo?.hasCustomQuote == true
          ? _customQuoteInfo!.quote
          : '',
    );
    int selectedDays = 7;
    bool isPermanent = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text(
                'Set Custom Quote',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: quoteController,
                      maxLength: 200,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter your motivational quote',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepPurple),
                        ),
                        counterStyle: TextStyle(color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Duration',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text(
                        'Permanent (no expiration)',
                        style: TextStyle(color: Colors.white70),
                      ),
                      value: isPermanent,
                      onChanged: (value) {
                        setDialogState(() {
                          isPermanent = value ?? false;
                        });
                      },
                      activeColor: Colors.deepPurple,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (!isPermanent) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'How many days?',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: selectedDays.toDouble(),
                              min: 1,
                              max: 365,
                              divisions: 364,
                              activeColor: Colors.deepPurple,
                              inactiveColor: Colors.white24,
                              label: '$selectedDays days',
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedDays = value.round();
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '$selectedDays days',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildDurationChip(1, selectedDays, (d) {
                            setDialogState(() => selectedDays = d);
                          }),
                          _buildDurationChip(7, selectedDays, (d) {
                            setDialogState(() => selectedDays = d);
                          }),
                          _buildDurationChip(30, selectedDays, (d) {
                            setDialogState(() => selectedDays = d);
                          }),
                          _buildDurationChip(90, selectedDays, (d) {
                            setDialogState(() => selectedDays = d);
                          }),
                          _buildDurationChip(365, selectedDays, (d) {
                            setDialogState(() => selectedDays = d);
                          }),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final newQuote = quoteController.text.trim();
                    if (newQuote.isNotEmpty) {
                      try {
                        await WallpaperChannelService.saveCustomQuote(
                          newQuote,
                          isPermanent ? 0 : selectedDays,
                        );
                        widget.onQuoteChanged(newQuote);
                        await _loadCustomQuoteInfo();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isPermanent
                                    ? 'Custom quote saved permanently!'
                                    : 'Custom quote saved for $selectedDays days!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to save quote: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDurationChip(
      int days, int selectedDays, ValueChanged<int> onSelected) {
    final isSelected = days == selectedDays;
    final label = days == 1
        ? '1 day'
        : days == 365
            ? '1 year'
            : '$days days';
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(days),
      selectedColor: Colors.deepPurple,
      backgroundColor: Colors.white12,
      checkmarkColor: Colors.white,
    );
  }
}
