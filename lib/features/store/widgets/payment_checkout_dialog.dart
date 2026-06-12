import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PaymentCheckoutDialog extends StatefulWidget {
  final String packageId;
  final Map<String, dynamic> packageData;
  final VoidCallback onConfirm;

  const PaymentCheckoutDialog({
    super.key,
    required this.packageId,
    required this.packageData,
    required this.onConfirm,
  });

  static void show(BuildContext context, {
    required String packageId,
    required Map<String, dynamic> packageData,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentCheckoutDialog(
        packageId: packageId,
        packageData: packageData,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<PaymentCheckoutDialog> createState() => _PaymentCheckoutDialogState();
}

class _PaymentCheckoutDialogState extends State<PaymentCheckoutDialog> {
  int _step = 0; // 0 = summary, 1 = processing

  @override
  Widget build(BuildContext context) {
    final amount = widget.packageData['amount'];
    final bonus = widget.packageData['bonus'];
    final price = widget.packageData['price'];
    final isSC = widget.packageData['currency'] == 'syndicate_coins';
    final color = isSC ? AppColors.gold : AppColors.cyan;
    final total = amount + bonus;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: color.withValues(alpha: 0.3))),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _step == 0 ? _buildSummary(color, total, bonus, price) : _buildProcessing(),
        ),
      ),
    );
  }

  Widget _buildSummary(Color color, num total, num bonus, num price) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Text('ORDER SUMMARY', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1))),
        const SizedBox(height: 24),
        
        // Item Details
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Currency', style: TextStyle(color: AppColors.white70, fontSize: 14)),
                  Text('$total', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              if (bonus > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Includes Bonus', style: TextStyle(color: AppColors.white50, fontSize: 12)),
                    Text('+$bonus', style: const TextStyle(color: AppColors.mintGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
              const Divider(color: AppColors.white10, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Price', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('\$${price.toStringAsFixed(2)}', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        const Text('PAYMENT METHOD', style: TextStyle(color: AppColors.white50, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: AppColors.glassBorder), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.credit_card, color: AppColors.white70),
              const SizedBox(width: 12),
              const Expanded(child: Text('Visa ending in 4242', style: TextStyle(color: Colors.white))),
              Icon(Icons.check_circle, color: color, size: 16),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Buttons
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel', style: TextStyle(color: AppColors.white50)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () {
                  setState(() => _step = 1);
                  widget.onConfirm(); // Let the parent handle processing state and pop
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10)]),
                  child: const Center(child: Text('PAY NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildProcessing() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 24),
        CircularProgressIndicator(color: Colors.white),
        SizedBox(height: 24),
        Text('Processing Payment...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Please do not close the app.', style: TextStyle(color: AppColors.white50, fontSize: 12)),
        SizedBox(height: 24),
      ],
    );
  }
}
