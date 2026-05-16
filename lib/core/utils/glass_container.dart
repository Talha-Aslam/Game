import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Glassmorphism container with frosted blur, neon border, and customizable opacity
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final Color borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.blur = 10,
    this.borderColor = AppColors.glassBorder,
    this.borderWidth = 1,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient == null
                  ? (backgroundColor ?? AppColors.glassBackground)
                  : null,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
