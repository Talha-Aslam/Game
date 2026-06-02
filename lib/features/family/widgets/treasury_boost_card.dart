import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/family/family_treasury_model.dart';

/// Individual boost card with activation
class TreasuryBoostCard extends StatelessWidget {
  final FamilyBoostType type;
  final int treasuryBalance;
  final bool isActive;
  final VoidCallback? onActivate;
  const TreasuryBoostCard({
    super.key,
    required this.type,
    required this.treasuryBalance,
    this.isActive = false,
    this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = treasuryBalance >= type.cost;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isActive
            ? AppColors.gold.withValues(alpha: 0.1)
            : type.color.withValues(alpha: 0.05),
        border: Border.all(
          color: isActive
              ? AppColors.gold.withValues(alpha: 0.4)
              : type.color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: type.color.withValues(alpha: 0.12),
              border: Border.all(color: type.color.withValues(alpha: 0.3)),
            ),
            child: Icon(type.icon, color: type.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.displayName,
                  style: TextStyle(
                    color: isActive ? AppColors.gold : type.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '24h duration • ${type.cost} cost',
                  style: AppTextStyles.labelSmall,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: (canAfford && !isActive) ? onActivate : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isActive
                    ? AppColors.gold.withValues(alpha: 0.2)
                    : (canAfford
                          ? type.color.withValues(alpha: 0.15)
                          : AppColors.white05),
                border: Border.all(
                  color: isActive
                      ? AppColors.gold.withValues(alpha: 0.5)
                      : (canAfford
                            ? type.color.withValues(alpha: 0.4)
                            : AppColors.glassBorder),
                ),
              ),
              child: Text(
                isActive ? 'ACTIVATED' : 'ACTIVATE',
                style: TextStyle(
                  color: isActive
                      ? AppColors.gold
                      : (canAfford ? type.color : AppColors.white30),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
