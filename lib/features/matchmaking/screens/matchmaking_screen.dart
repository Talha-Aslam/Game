import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/matchmaking_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/matchmaking_service.dart';
import '../../../models/game_state_model.dart';
import '../../../widgets/glass_button.dart';
import '../../../widgets/neon_text.dart';
import '../../../widgets/particle_field.dart';

class MatchmakingScreen extends ConsumerStatefulWidget {
  const MatchmakingScreen({super.key});
  @override
  ConsumerState<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends ConsumerState<MatchmakingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    // Start matchmaking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      ref
          .read(matchmakingServiceProvider)
          .startSearching(auth.user?.id ?? 'guest_123');
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mmState = ref.watch(matchmakingStateProvider);

    ref.listen(gameProvider, (prev, next) {
      if (next.phase == GamePhase.lobby ||
          next.phase == GamePhase.roleAssignment) {
        context.go('/game');
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.backgroundGradient,
            ),
          ),
          const ParticleField(particleCount: 20, particleColor: AppColors.cyan),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(matchmakingServiceProvider).cancelSearching();
                        context.go('/home');
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white05,
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.white70,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),

                // Scanning animation
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, _) {
                    return SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer rings
                          ...List.generate(3, (i) {
                            final delay = i * 0.33;
                            final animValue =
                                (_scanController.value + delay) % 1.0;
                            return Container(
                              width: 120 + animValue * 80,
                              height: 120 + animValue * 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.cyan.withValues(
                                    alpha: (1 - animValue) * 0.4,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                            );
                          }),
                          // Center circle
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.cyan.withValues(alpha: 0.1),
                              border: Border.all(
                                color: AppColors.cyan.withValues(alpha: 0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cyan.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.radar,
                              color: AppColors.cyan,
                              size: 40,
                            ),
                          ),
                          // Sweep line
                          Transform.rotate(
                            angle: _scanController.value * 2 * pi,
                            child: Container(
                              width: 2,
                              height: 100,
                              alignment: Alignment.topCenter,
                              child: Container(
                                width: 2,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.cyan.withValues(alpha: 0),
                                      AppColors.cyan,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),
                const NeonText(
                  text: 'SEARCHING...',
                  fontSize: 22,
                  color: AppColors.cyan,
                  glowRadius: 15,
                ),
                const SizedBox(height: 12),

                mmState.when(
                  loading: () =>
                      Text('Connecting...', style: AppTextStyles.bodyMedium),
                  error: (e, _) => Text(
                    'Error: $e',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.crimsonRed,
                    ),
                  ),
                  data: (state) {
                    if (state.status == MatchmakingStatus.found) {
                      return Column(
                        children: [
                          const NeonText(
                            text: 'MATCH FOUND!',
                            fontSize: 24,
                            color: AppColors.gold,
                            glowRadius: 20,
                          ),
                          const SizedBox(height: 16),
                          GlassButton(
                            label: 'ACCEPT',
                            glowColor: AppColors.mintGreen,
                            width: 160,
                            onPressed: () {
                              ref
                                  .read(matchmakingServiceProvider)
                                  .acceptMatch();
                              ref
                                  .read(gameProvider.notifier)
                                  .startMatchmaking();
                            },
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Text(
                          'Players found: ${state.playersFound} / ${state.playersNeeded}',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Time: ${state.elapsedSeconds}s',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        // Progress bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: state.playersFound / state.playersNeeded,
                              backgroundColor: AppColors.white10,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.cyan,
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Voice status
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.online,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Voice Connected',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.online,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Cancel
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: GlassButton(
                    label: 'CANCEL',
                    isOutlined: true,
                    glowColor: AppColors.crimsonRed,
                    width: 160,
                    onPressed: () {
                      ref.read(matchmakingServiceProvider).cancelSearching();
                      context.go('/home');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
