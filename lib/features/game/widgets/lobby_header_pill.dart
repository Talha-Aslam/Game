import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/game_state_model.dart';

/// Frosted glass top header pill: "Round X | PHASE | N Alive"
class LobbyHeaderPill extends StatefulWidget {
  final GamePhase phase;
  final int roundNumber;
  final int aliveCount;

  const LobbyHeaderPill({
    super.key, required this.phase, required this.roundNumber, required this.aliveCount,
  });

  @override
  State<LobbyHeaderPill> createState() => _LobbyHeaderPillState();
}

class _LobbyHeaderPillState extends State<LobbyHeaderPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _glow;

  @override
  void initState() { super.initState(); _glow = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true); }
  @override
  void dispose() { _glow.dispose(); super.dispose(); }

  Color get _phaseColor {
    switch (widget.phase) {
      case GamePhase.night: return AppColors.purpleDeep;
      case GamePhase.morningReveal: return AppColors.gold;
      case GamePhase.day: return AppColors.gold;
      case GamePhase.voting: return AppColors.cyan;
      case GamePhase.runoff: return AppColors.crimsonRed;
      case GamePhase.elimination: return AppColors.crimsonRed;
      case GamePhase.result: return AppColors.gold;
      case GamePhase.roleAssignment: return AppColors.purpleNeon;
      default: return AppColors.purpleNeon;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _phaseColor;
    return AnimatedBuilder(animation: _glow, builder: (_, _) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.white05,
              border: Border.all(color: color.withValues(alpha: 0.2 + _glow.value * 0.1), width: 0.5),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08 + _glow.value * 0.04), blurRadius: 12)],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                // Round
                Text('Round ${widget.roundNumber}', style: TextStyle(
                  color: AppColors.white50, fontSize: 11, fontWeight: FontWeight.w500)),
                Container(width: 1, height: 14, margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: AppColors.glassBorder),
                // Phase
                Text(widget.phase.displayName, style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.5,
                  shadows: [Shadow(color: color.withValues(alpha: 0.4), blurRadius: 8)])),
                Container(width: 1, height: 14, margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: AppColors.glassBorder),
                // Alive count
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.online)),
                  const SizedBox(width: 4),
                  Text('${widget.aliveCount} Alive', style: const TextStyle(
                    color: AppColors.white50, fontSize: 11, fontWeight: FontWeight.w500)),
                ]),
              ]),
            ),
          ),
        ),
      );
    });
  }
}
