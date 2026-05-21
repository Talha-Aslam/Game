import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Animated "Let's Play" / "Invite to Play" button
class LetsPlayButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool compact;

  const LetsPlayButton({
    super.key,
    this.onPressed,
    this.label = "LET'S PLAY",
    this.compact = false,
  });

  @override
  State<LetsPlayButton> createState() => _LetsPlayButtonState();
}

class _LetsPlayButtonState extends State<LetsPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        final glowIntensity = _glowController.value;
        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            height: widget.compact ? 34 : 44,
            padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 12 : 20,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.compact ? 8 : 12),
              gradient: LinearGradient(
                colors: [
                  AppColors.mintGreen,
                  AppColors.mintGreen.withValues(alpha: 0.7),
                ],
              ),
              border: Border.all(
                color: AppColors.mintGreen.withValues(
                  alpha: 0.4 + glowIntensity * 0.3,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mintGreen.withValues(
                    alpha: 0.2 + glowIntensity * 0.15,
                  ),
                  blurRadius: 12 + glowIntensity * 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_esports,
                  color: Colors.white,
                  size: widget.compact ? 14 : 18,
                ),
                SizedBox(width: widget.compact ? 4 : 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: widget.compact ? 10 : 13,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
