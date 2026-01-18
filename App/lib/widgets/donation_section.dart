import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationSection extends StatelessWidget {
  static const String donationUrl =
      'https://year-progress-wallpaper.netlify.app/donate';

  const DonationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.pinkAccent,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Support Development',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'If you enjoy this app, consider supporting its development. Your contribution helps keep the app free and ad-free!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openDonationLink(context),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Support Development'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.pinkAccent,
                  side: const BorderSide(color: Colors.pinkAccent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDonationLink(BuildContext context) async {
    final uri = Uri.parse(donationUrl);

    try {
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          _showErrorSnackbar(context, 'Could not open the link');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackbar(context, 'Failed to open browser');
      }
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
