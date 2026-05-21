import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/game_state_model.dart';
import 'neon_text.dart';

/// Phase indicator showing current game phase
class PhaseIndicator extends StatelessWidget {
  final GamePhase phase;

  const PhaseIndicator({super.key, required this.phase});

  Color get _phaseColor {
    switch (phase) {
      case GamePhase.night: return AppColors.purpleDeep;
      case GamePhase.morningReveal: return AppColors.gold;
      case GamePhase.day: return AppColors.gold;
      case GamePhase.voting: return AppColors.cyan;
      case GamePhase.runoff: return AppColors.crimsonRed;
      case GamePhase.elimination: return AppColors.crimsonRed;
      case GamePhase.result: return AppColors.gold;
      default: return AppColors.purpleNeon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _phaseColor.withValues(alpha: 0.15),
        border: Border.all(color: _phaseColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: _phaseColor.withValues(alpha: 0.2),
            blurRadius: 15,
          ),
        ],
      ),
      child: NeonText(
        text: phase.displayName,
        color: _phaseColor,
        fontSize: 14,
        fontWeight: FontWeight.w800,
        glowRadius: 10,
      ),
    );
  }
}
