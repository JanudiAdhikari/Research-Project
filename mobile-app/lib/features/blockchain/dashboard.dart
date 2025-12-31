import 'package:flutter/material.dart';
import '../../utils/responsive.dart';
import 'QR_scan.dart';

class BlockchainDashboard extends StatefulWidget {
  const BlockchainDashboard({super.key});

  @override
  State<BlockchainDashboard> createState() => _BlockchainDashboardState();
}

class _BlockchainDashboardState extends State<BlockchainDashboard> {
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final primary = const Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Traceability'),
        backgroundColor: primary,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(responsive.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(responsive.largeSpacing),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFC8E6C9), const Color(0xFFA5D6A7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.qr_code_rounded,
                            color: primary,
                            size: 26,
                          ),
                        ),
                        SizedBox(width: responsive.mediumSpacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Track Your Shipment',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              SizedBox(height: responsive.smallSpacing),
                              Text(
                                'Scan QR codes to view blockchain records',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive.largeSpacing),

              // Info Section
              Text(
                'How It Works',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: responsive.smallSpacing),
              Text(
                'Follow these simple steps to trace your pepper shipment',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color.fromARGB(255, 60, 60, 60),
                ),
              ),

              SizedBox(height: responsive.mediumSpacing),

              _buildInfoCard(
                responsive,
                '1',
                'Locate QR Code',
                'Find the unique QR code on your pepper package or shipment label',
              ),
              SizedBox(height: responsive.mediumSpacing),
              _buildInfoCard(
                responsive,
                '2',
                'Start Scanning',
                'Click the Start button below and point your camera at the QR code',
              ),
              SizedBox(height: responsive.mediumSpacing),
              _buildInfoCard(
                responsive,
                '3',
                'View Full Details',
                'See complete shipment information, origin, and handling details',
              ),
              SizedBox(height: responsive.mediumSpacing),
              _buildInfoCard(
                responsive,
                '4',
                'Verify Origin',
                'Confirm the pepper is authentic and from our registered exporters',
              ),
              SizedBox(height: responsive.mediumSpacing),
              _buildInfoCard(
                responsive,
                '5',
                'Check History',
                'View complete blockchain record of the shipment journey',
              ),

              SizedBox(height: responsive.largeSpacing),

              // Start Button
              Center(
                child: SizedBox(
                  width: responsive.value(
                    mobile: MediaQuery.of(context).size.width * 0.65,
                    tablet: MediaQuery.of(context).size.width * 0.45,
                    desktop: 360,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QRScanScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Start',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    Responsive responsive,
    String number,
    String title,
    String description,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.mediumSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 166, 133, 235),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          SizedBox(width: responsive.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
