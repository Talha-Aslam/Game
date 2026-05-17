import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Reusable glassmorphic stat card
class FamilyStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const FamilyStatCard({super.key, required this.label, required this.value,
    required this.icon, this.color = AppColors.purpleGlow});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), color: AppColors.white05,
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.labelLarge.copyWith(color: color)),
        Text(label, style: AppTextStyles.labelSmall),
      ]),
    );
  }
}
