import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeMenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const HomeMenuCard({super.key, required this.title, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withValues(alpha: 0.06),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 15)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(title, style: AppTextStyles.labelMedium.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
