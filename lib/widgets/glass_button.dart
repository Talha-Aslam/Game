import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Glassmorphic action button with glow effects
class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? glowColor;
  final double? width;
  final double height;
  final bool isOutlined;

  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.glowColor,
    this.width,
    this.height = 50,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = glowColor ?? AppColors.purpleNeon;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isOutlined
              ? null
              : LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
          border: Border.all(
            color: isOutlined ? color : color.withValues(alpha: 0.3),
            width: isOutlined ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
