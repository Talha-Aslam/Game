import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AnimatedPlayButton extends StatefulWidget {
  final VoidCallback? onPressed;
  const AnimatedPlayButton({super.key, this.onPressed});

  @override
  State<AnimatedPlayButton> createState() => _AnimatedPlayButtonState();
}

class _AnimatedPlayButtonState extends State<AnimatedPlayButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    _rotateController = AnimationController(duration: const Duration(seconds: 8), vsync: this)..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _rotateController]),
        builder: (context, _) {
          final scale = 1.0 + _pulseController.value * 0.06;
          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 140, height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer rotating ring
                  Transform.rotate(
                    angle: _rotateController.value * 2 * pi,
                    child: Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.purpleNeon.withValues(alpha: 0.3 + _pulseController.value * 0.2),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  // Glow
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purpleNeon.withValues(alpha: 0.3 + _pulseController.value * 0.2),
                          blurRadius: 30 + _pulseController.value * 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // Main button
                  Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.purpleNeon, AppColors.purpleDeep],
                      ),
                      border: Border.all(color: AppColors.purpleGlow.withValues(alpha: 0.5), width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                        Text('PLAY', style: AppTextStyles.labelLarge.copyWith(letterSpacing: 3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
