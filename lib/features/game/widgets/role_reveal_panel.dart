import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/player_model.dart';

/// Cinematic role reveal panel with glass + blur reveal animation
class RoleRevealPanel extends StatefulWidget {
  final GameRole? role;
  final bool isRevealing;

  const RoleRevealPanel({super.key, this.role, this.isRevealing = false});

  @override
  State<RoleRevealPanel> createState() => _RoleRevealPanelState();
}

class _RoleRevealPanelState extends State<RoleRevealPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _reveal;

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    if (widget.role != null) _reveal.forward();
  }

  @override
  void didUpdateWidget(RoleRevealPanel old) {
    super.didUpdateWidget(old);
    if (widget.role != null && old.role == null) _reveal.forward(from: 0);
  }

  @override
  void dispose() { _reveal.dispose(); super.dispose(); }

  Color get _roleColor {
    switch (widget.role) {
      case GameRole.mafia: return AppColors.crimsonRed;
      case GameRole.doctor: return AppColors.mintGreen;
      case GameRole.detective: return AppColors.purpleNeon;
      case GameRole.civilian: return AppColors.cyan;
      default: return AppColors.white30;
    }
  }

  IconData get _roleIcon {
    switch (widget.role) {
      case GameRole.mafia: return Icons.dangerous;
      case GameRole.doctor: return Icons.healing;
      case GameRole.detective: return Icons.search;
      case GameRole.civilian: return Icons.person;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _roleColor;
    return AnimatedBuilder(animation: _reveal, builder: (_, __) {
      final t = Curves.easeOutBack.transform(_reveal.value);
      final blurAmount = (1.0 - t) * 12;
      final opacity = t.clamp(0.0, 1.0);

      return Transform.scale(
        scale: 0.85 + t * 0.15,
        child: Opacity(
          opacity: opacity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: color.withValues(alpha: 0.06),
                  border: Border.all(color: color.withValues(alpha: 0.25 + t * 0.15)),
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1 + t * 0.1), blurRadius: 20)],
                ),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.12),
                        border: Border.all(color: color.withValues(alpha: 0.3))),
                      child: Icon(_roleIcon, color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('YOUR ROLE', style: TextStyle(
                        color: AppColors.white30, fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 1)),
                      Text(widget.role?.displayName ?? '???', style: TextStyle(
                        color: color, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1,
                        shadows: [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 8)])),
                    ]),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
