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
    final isDisabled = onPressed == null;
    final color = isDisabled ? AppColors.white30 : (glowColor ?? AppColors.purpleNeon);
    final opacity = isDisabled ? 0.4 : 1.0;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isOutlined || isDisabled
              ? null
              : LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
          color: isDisabled && !isOutlined ? AppColors.white05 : null,
          border: Border.all(
            color: isOutlined ? color : color.withValues(alpha: isDisabled ? 0.1 : 0.3),
            width: isOutlined ? 1.5 : 1,
          ),
          boxShadow: isDisabled ? [] : [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Center(
          child: Opacity(
            opacity: opacity,
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
      ),
    );
  }
}
