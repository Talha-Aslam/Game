import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PurchaseDialog extends StatelessWidget {
  final int currentBalance;
  final bool isSyndicateCoins;

  const PurchaseDialog({
    super.key,
    required this.currentBalance,
    this.isSyndicateCoins = true,
  });

  static void show(BuildContext context, {required int currentBalance, bool isSyndicateCoins = true}) {
    showDialog(
      context: context,
      builder: (_) => PurchaseDialog(
        currentBalance: currentBalance,
        isSyndicateCoins: isSyndicateCoins,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = isSyndicateCoins ? AppColors.gold : AppColors.cyan;
    final icon = isSyndicateCoins ? Icons.diamond : Icons.toll;
    final title = isSyndicateCoins ? 'SYNDICATE COINS' : 'INFLUENCE POINTS';

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 64),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTextStyles.headlineSmall.copyWith(color: color),
              ),
              const SizedBox(height: 8),
              const Text(
                'Unlock premium cosmetics, battle passes, and exclusive rewards!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.white70, fontSize: 12),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'BALANCE:',
                      style: TextStyle(color: AppColors.white50, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$currentBalance',
                      style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/premium-store');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: isSyndicateCoins 
                          ? [AppColors.gold, const Color(0xFFFF8F00)]
                          : [AppColors.cyan, const Color(0xFF0091EA)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 12,
                      )
                    ]
                  ),
                  child: const Center(
                    child: Text(
                      'BUY MORE COINS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel', style: TextStyle(color: AppColors.white30)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
