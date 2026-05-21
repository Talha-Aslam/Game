import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../widgets/particle_field.dart';

/// Stub spectator screen for watching live family matches
class SpectateMatchScreen extends StatelessWidget {
  const SpectateMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Stack(children: [
      Container(decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient)),
      const ParticleField(particleCount: 10),
      SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          GestureDetector(onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: AppColors.white70)),
          const SizedBox(width: 16),
          Text('Spectating', style: AppTextStyles.headlineMedium),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
              color: AppColors.crimsonRed.withValues(alpha: 0.15)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppColors.crimsonRed)),
              const SizedBox(width: 4),
              const Text('LIVE', style: TextStyle(color: AppColors.crimsonRed,
                fontSize: 10, fontWeight: FontWeight.w700)),
            ])),
        ])),
        const Expanded(child: Center(child: Column(
          mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.visibility, color: AppColors.white10, size: 64),
            SizedBox(height: 16),
            Text('Spectator Mode', style: TextStyle(
              color: AppColors.white50, fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('No active family matches to spectate',
              style: TextStyle(color: AppColors.white30, fontSize: 13)),
            SizedBox(height: 24),
            Text('When a family member is in a match,\nyou can watch live from here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.white10, fontSize: 11)),
          ],
        ))),
      ])),
    ]));
  }
}
