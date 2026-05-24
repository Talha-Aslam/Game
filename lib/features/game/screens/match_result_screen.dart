import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/matchmaking_provider.dart';
import '../../../core/theme/app_colors.dart';

import '../../../models/game_state_model.dart';
import '../../../models/player_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/glass_button.dart';
import '../../../widgets/neon_text.dart';
import '../../../widgets/particle_field.dart';

/// Full cinematic match result screen
class MatchResultScreen extends ConsumerStatefulWidget {
  const MatchResultScreen({super.key});

  @override
  ConsumerState<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends ConsumerState<MatchResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _bannerSweep;
  late AnimationController _statsReveal;
  late AnimationController _buttonSlide;
  late AnimationController _glow;

  // Animated stat values

  bool _commendationSent = false;

  @override
  void initState() {
    super.initState();
    _bannerSweep = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    _statsReveal = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _buttonSlide = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _glow = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Stagger: banner → stats → buttons
    _bannerSweep.addStatusListener((s) {
      if (s == AnimationStatus.completed) _statsReveal.forward();
    });
    _statsReveal.addStatusListener((s) {
      if (s == AnimationStatus.completed) _buttonSlide.forward();
    });
  }

  @override
  void dispose() {
    _bannerSweep.dispose();
    _statsReveal.dispose();
    _buttonSlide.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gs = ref.watch(gameProvider);
    final rd = gs.resultData;
    final winner = gs.winner;
    final lp = gs.localPlayer;
    final isWinner = winner == WinningSide.civilians
        ? !(lp?.isMafia ?? false)
        : (lp?.isMafia ?? false);
    final winColor = winner == WinningSide.mafia
        ? AppColors.crimsonRed
        : AppColors.mintGreen;
    final mvp = gs.players.where((p) => p.id == rd?.mvpPlayerId).firstOrNull;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ref.read(gameProvider.notifier).resetGame();
        context.go('/home');
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isWinner
                        ? winColor.withValues(alpha: 0.08)
                        : AppColors.background,
                    AppColors.background,
                    AppColors.surface,
                  ],
                ),
              ),
            ),

            // Particles
            RepaintBoundary(
              child: ParticleField(
                particleCount: 20,
                particleColor: winColor.withValues(alpha: 0.3),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ═══ WINNER BANNER ═══
                    _buildWinnerBanner(winner, isWinner, winColor),

                    const SizedBox(height: 24),

                    // ═══ MVP CARD ═══
                    if (mvp != null) _buildMvpCard(mvp, winColor),

                    const SizedBox(height: 20),

                    // ═══ STAT CARDS ═══
                    if (rd != null) _buildStatCards(rd, winColor),

                    const SizedBox(height: 20),

                    // ═══ ROLE REVEAL TABLE ═══
                    _buildRoleTable(gs),

                    const SizedBox(height: 20),

                    // ═══ ACTION BUTTONS ═══
                    _buildActionButtons(gs, winColor),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ── Winner Banner with sweep-in animation ──
  Widget _buildWinnerBanner(
    WinningSide? winner,
    bool isWinner,
    Color winColor,
  ) {
    return AnimatedBuilder(
      animation: _bannerSweep,
      builder: (_, _) {
        final t = Curves.easeOutBack.transform(_bannerSweep.value);
        return Transform.scale(
          scale: 0.5 + t * 0.5,
          child: Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: Column(
              children: [
                // Victory/Defeat label
                AnimatedBuilder(
                  animation: _glow,
                  builder: (_, _) => NeonText(
                    text: isWinner ? '🎉 VICTORY' : '💀 DEFEAT',
                    fontSize: 36,
                    color: isWinner ? AppColors.gold : AppColors.crimsonRed,
                    glowRadius: 20 + _glow.value * 10,
                  ),
                ),
                const SizedBox(height: 8),
                // Faction
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: winColor.withValues(alpha: 0.08),
                        border: Border.all(
                          color: winColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        winner == WinningSide.mafia
                            ? 'THE SYNDICATE PREVAILS'
                            : 'CIVILIANS TRIUMPH',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: winColor,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ── MVP Card ──
  Widget _buildMvpCard(PlayerModel mvp, Color winColor) {
    return AnimatedBuilder(
      animation: _statsReveal,
      builder: (_, _) {
        final t = Curves.easeOut.transform(
          (_statsReveal.value * 2).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - t)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.gold.withValues(alpha: 0.06),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.08),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Crown + avatar
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.gold.withValues(alpha: 0.1),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                mvp.name.isNotEmpty
                                    ? mvp.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -8,
                            left: 12,
                            child: Text('👑', style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MOST VALUABLE PLAYER',
                              style: TextStyle(
                                color: AppColors.gold.withValues(alpha: 0.5),
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              mvp.name,
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              mvp.role?.displayName ?? '',
                              style: TextStyle(
                                color: AppColors.white30,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// ── Stat Cards with animated count-up ──
  Widget _buildStatCards(MatchResultData rd, Color winColor) {
    final stats = [
      _StatItem(Icons.star, 'XP', '+${rd.xpGained}', AppColors.gold),
      _StatItem(
        Icons.military_tech,
        'RANK',
        '${rd.rankDelta > 0 ? '+' : ''}${rd.rankDelta} RP',
        rd.rankDelta >= 0 ? AppColors.mintGreen : AppColors.crimsonRed,
      ),
      _StatItem(
        Icons.local_fire_department,
        'BATTLE PASS',
        '+${rd.bpXpGained}',
        AppColors.purpleGlow,
      ),
      _StatItem(
        Icons.bolt,
        'INFLUENCE',
        '+${rd.influenceGained}',
        AppColors.cyan,
      ),
      _StatItem(
        Icons.favorite,
        'POPULARITY',
        '+${rd.popularityGained}',
        AppColors.giftPink,
      ),
    ];

    return AnimatedBuilder(
      animation: _statsReveal,
      builder: (_, _) {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: List.generate(stats.length, (i) {
            final delay = 0.2 + i * 0.12;
            final t = Curves.easeOutBack.transform(
              ((_statsReveal.value - delay) * 3).clamp(0.0, 1.0),
            );
            final stat = stats[i];

            return Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - t)),
                child: _buildStatChip(stat),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildStatChip(_StatItem stat) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: stat.color.withValues(alpha: 0.06),
            border: Border.all(color: stat.color.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              Icon(stat.icon, color: stat.color, size: 20),
              const SizedBox(height: 6),
              Text(
                stat.label,
                style: TextStyle(
                  color: AppColors.white30,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stat.value,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: stat.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ── Role Reveal Table ──
  Widget _buildRoleTable(GameStateModel gs) {
    return AnimatedBuilder(
      animation: _statsReveal,
      builder: (_, _) {
        final t = ((_statsReveal.value - 0.6) * 2.5).clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.white05,
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ROLE STATISTICS',
                      style: TextStyle(
                        color: AppColors.white50,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...gs.players.map((p) => _buildPlayerRow(p, gs)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerRow(PlayerModel p, GameStateModel gs) {
    final roleColor = _roleColor(p.role);
    final isLocal = p.id == gs.localPlayerId;
    final isMvp = p.id == gs.resultData?.mvpPlayerId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.isAlive
                  ? roleColor.withValues(alpha: 0.1)
                  : AppColors.darkGrey.withValues(alpha: 0.3),
              border: Border.all(
                color: isLocal
                    ? AppColors.purpleNeon.withValues(alpha: 0.5)
                    : AppColors.white10,
              ),
            ),
            child: Center(
              child: Text(
                p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: p.isAlive ? roleColor : AppColors.white30,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Name
          Expanded(
            child: Row(
              children: [
                Text(
                  p.name,
                  style: TextStyle(
                    color: isLocal ? AppColors.purpleGlow : AppColors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isMvp) ...[
                  const SizedBox(width: 4),
                  Text('👑', style: TextStyle(fontSize: 10)),
                ],
                if (isLocal) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(YOU)',
                    style: TextStyle(
                      color: AppColors.purpleNeon.withValues(alpha: 0.5),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: roleColor.withValues(alpha: 0.08),
              border: Border.all(color: roleColor.withValues(alpha: 0.2)),
            ),
            child: Text(
              p.role?.displayName ?? '?',
              style: TextStyle(
                color: roleColor,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Status
          Icon(
            p.isAlive ? Icons.check_circle : Icons.cancel,
            color: p.isAlive
                ? AppColors.mintGreen.withValues(alpha: 0.5)
                : AppColors.crimsonRed.withValues(alpha: 0.4),
            size: 14,
          ),
        ],
      ),
    );
  }

  /// ── Action Buttons ──
  Widget _buildActionButtons(GameStateModel gs, Color winColor) {
    return AnimatedBuilder(
      animation: _buttonSlide,
      builder: (_, _) {
        final t = Curves.easeOutCubic.transform(_buttonSlide.value);
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - t)),
            child: Column(
              children: [
                // Primary row
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        label: 'PLAY AGAIN',
                        glowColor: AppColors.purpleNeon,
                        icon: Icons.replay,
                        height: 44,
                        onPressed: () {
                          ref.read(gameProvider.notifier).resetGame();
                          ref.read(matchmakingServiceProvider).startSearching();
                          context.go('/matchmaking');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    GlassButton(
                      label: 'HOME',
                      isOutlined: true,
                      icon: Icons.home,
                      width: 90,
                      height: 44,
                      onPressed: () {
                        ref.read(gameProvider.notifier).resetGame();
                        context.go('/home');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Secondary row
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        label: 'ADD FRIEND',
                        isOutlined: true,
                        icon: Icons.person_add,
                        height: 38,
                        onPressed: () {
                          // Add friend action stub
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Friend request sent!'),
                              backgroundColor: AppColors.surface,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GlassButton(
                        label: _commendationSent ? 'SENT ✓' : 'COMMEND',
                        isOutlined: true,
                        icon: Icons.thumb_up,
                        height: 38,
                        onPressed: _commendationSent
                            ? null
                            : () {
                                final mvpId = gs.resultData?.mvpPlayerId;
                                if (mvpId != null) {
                                  ref
                                      .read(gameProvider.notifier)
                                      .sendCommendation(mvpId);
                                }
                                setState(() => _commendationSent = true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Commendation sent!'),
                                    backgroundColor: AppColors.surface,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlassButton(
                      label: 'STATS',
                      isOutlined: true,
                      icon: Icons.bar_chart,
                      width: 80,
                      height: 38,
                      onPressed: () {
                        // View stats action — scroll to role table
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _roleColor(GameRole? role) {
    switch (role) {
      case GameRole.mafia:
        return AppColors.crimsonRed;
      case GameRole.doctor:
        return AppColors.mintGreen;
      case GameRole.detective:
        return AppColors.purpleNeon;
      case GameRole.civilian:
        return AppColors.cyan;
      default:
        return AppColors.white30;
    }
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatItem(this.icon, this.label, this.value, this.color);
}
