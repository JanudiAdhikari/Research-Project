import 'package:flutter/material.dart';
import '../../../utils/market forecast/actual_price_data_si.dart';

class MarketplacePromptDialog extends StatelessWidget {
  final VoidCallback onNoThanks;
  final VoidCallback onYesAdd;
  final String language;

  const MarketplacePromptDialog({
    super.key,
    required this.onNoThanks,
    required this.onYesAdd,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: Colors.blue.shade700,
                  size: 44,
                ),
              ),
              const SizedBox(height: 18),

              Text(
                language == 'si'
                    ? 'වෙළඳපලට එක් කරන්නද?'
                    : 'Add to Marketplace?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                language == 'si'
                    ? 'ඔබට මෙම නිෂ්පාදනය වෙළඳපලට එක් කිරීමට අවශ්‍යද?\nමෙය ප්‍රකාශයට පත් කිරීමට පෙර අනුමැතිය අවශ්‍ය වේ.'
                    : 'Are you sure you want to add this product to the marketplace?\nApproval is required before it becomes visible.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onNoThanks,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                      ),
                      child: Text(
                        language == 'si'
                            ? ActualPriceDataSi.cancel
                            : 'Cancel',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onYesAdd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        language == 'si'
                            ? 'ඔව්, එක් කරන්න'
                            : 'Yes, Add',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}