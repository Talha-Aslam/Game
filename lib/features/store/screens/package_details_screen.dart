import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';

class PackageDetailsScreen extends StatelessWidget {
  final String packageId;
  final Map<String, dynamic> packageData;

  const PackageDetailsScreen({
    super.key,
    required this.packageId,
    required this.packageData,
  });

  @override
  Widget build(BuildContext context) {
    final amount = packageData['amount'] as int;
    final bonus = packageData['bonus'] as int;
    final price = packageData['price'] as num;
    final isSC = packageData['currency'] == 'syndicate_coins';
    final color = isSC ? AppColors.gold : AppColors.cyan;
    final icon = isSC ? Icons.diamond : Icons.toll;
    final title = isSC ? 'SYNDICATE COINS' : 'INFLUENCE POINTS';
    final total = amount + bonus;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient)),
          
          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back, color: Colors.white)),
                      const SizedBox(width: 16),
                      const Text('PACKAGE DETAILS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        // Hero Icon
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            gradient: LinearGradient(
                              colors: [color.withValues(alpha: 0.2), AppColors.surface],
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: color.withValues(alpha: 0.3)),
                            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 30)],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(icon, color: color.withValues(alpha: 0.2), size: 140),
                              Icon(icon, color: color, size: 80),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Package Title
                        Text(
                          '$total $title',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Instantly added to your wallet upon purchase.',
                          style: TextStyle(color: AppColors.white50, fontSize: 12),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Breakdown Table
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Column(
                            children: [
                              _buildRow('Base Amount', '$amount', Colors.white),
                              if (bonus > 0) ...[
                                const Divider(color: AppColors.white10, height: 24),
                                _buildRow('Bonus Reward', '+$bonus', AppColors.mintGreen),
                              ],
                              const Divider(color: AppColors.white10, height: 24),
                              _buildRow('Price', '\$${price.toStringAsFixed(2)}', color, isBold: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Checkout Button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: GestureDetector(
                    onTap: () {
                      context.push('/premium-store/checkout', extra: {
                        'id': packageId,
                        'data': packageData,
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 4))],
                      ),
                      child: const Center(
                        child: Text(
                          'PROCEED TO CHECKOUT',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.white70, fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: valueColor, fontSize: isBold ? 18 : 16, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
