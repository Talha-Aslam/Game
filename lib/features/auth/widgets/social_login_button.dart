import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const SocialLoginButton({super.key, required this.label, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.white05,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.white70, size: 22),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: AppColors.white70, fontWeight: FontWeight.w500, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
