import 'package:flutter/material.dart';

import 'pepper_batches.dart';
import 'QR_generation.dart';

class BlockchainProcessScreen extends StatefulWidget {
  const BlockchainProcessScreen({super.key});

  @override
  State<BlockchainProcessScreen> createState() =>
      _BlockchainProcessScreenState();
}

class _BlockchainProcessScreenState extends State<BlockchainProcessScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildCard({
      required Color color,
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
    }) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blockchain Process'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 6),
            buildCard(
              color: Colors.green,
              icon: Icons.verified_rounded,
              title: 'Verify Pepper Batches',
              subtitle: 'Review submitted batches and mark as verified',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VerifyBatchesScreen()),
              ),
            ),
            buildCard(
              color: Colors.blue,
              icon: Icons.qr_code_2_rounded,
              title: 'Generate QR Code',
              subtitle: 'Create QR codes for verified batches',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QRGenerationScreen()),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade100),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please verify pepper batches to ensure QR codes represent for approved products. Tap “Verify Pepper Batches” to proceed.',
                      style: TextStyle(color: Colors.green.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
