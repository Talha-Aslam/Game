import 'avatar_borders.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/rank_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import 'calling_cards.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AVATAR SHOWCASE WIDGET  — v2
//  A single cohesive "Profile Showcase Deck" card:
//   • Glassmorphic card with dark translucent fill + blur
//   • Avatar ring overflows the top boundary (~35%)
//   • Rank shield badge pinned to avatar rim
//   • Username + Title chip inside card body
//   • Horizontal XP progress bar at card base
//   • All text widgets are overflow-safe (ellipsis + Flexible/ConstrainedBox)
//   • Breathing + floating micro-animation
// ─────────────────────────────────────────────────────────────────────────────
class AvatarShowcaseWidget extends ConsumerStatefulWidget {
  const AvatarShowcaseWidget({super.key});

  @override
  ConsumerState<AvatarShowcaseWidget> createState() =>
      _AvatarShowcaseWidgetState();
}

class _AvatarShowcaseWidgetState extends ConsumerState<AvatarShowcaseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final rank = RankModel.fromTier(user?.rankTier ?? 0);
    final ec = user?.equippedCosmetics;

    return AnimatedBuilder(
      animation: _anim,
      builder: (ctx, _) {
        final t = _anim.value;
        final floatY = sin(t * 2 * pi) * 4.0;
        final glowAlpha = 0.30 + sin(t * 2 * pi) * 0.12;

        return Transform.translate(
          offset: Offset(0, floatY),
          child: _ProfileCard(
            user: user,
            rank: rank,
            animPhase: t,
            glowAlpha: glowAlpha,
            backgroundId: ec?.background ?? '',
            borderId: ec?.cardBorder ?? '',
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserModel? user;
  final RankModel rank;
  final double animPhase;
  final double glowAlpha;
  final String backgroundId;
  final String borderId;

  const _ProfileCard({
    required this.user,
    required this.rank,
    required this.animPhase,
    required this.glowAlpha,
    required this.backgroundId,
    required this.borderId,
  });

  static const double _avatarSize = 96.0;
  static const double _avatarOverflow = _avatarSize * 0.38;

  @override
  Widget build(BuildContext context) {
    final frameStyle = _FrameStyle.forTier(rank.tier, borderId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: _avatarOverflow),
            child: _GlassCard(
              rank: rank,
              glowAlpha: glowAlpha,
              backgroundId: backgroundId,
              borderId: borderId,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, _avatarSize - _avatarOverflow + 10, 20, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: double.infinity),
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Colors.white, frameStyle.ringColors.first.withValues(alpha: 0.80)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds),
                        child: Text(
                          user?.username ?? 'Agent',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _TitleChip(
                      title: user?.equippedTitle?.isNotEmpty == true
                          ? user!.equippedTitle!
                          : 'Shadow Boss',
                      rank: rank,
                      accentColor: frameStyle.ringColors.first,
                    ),
                    const SizedBox(height: 16),
                    _XpBar(user: user, rank: rank, accentColor: frameStyle.ringColors.first),
                  ],
                ),
              ),
            ),
          ),
          _AvatarRing(
            user: user,
            rank: rank,
            frameStyle: frameStyle,
            glowAlpha: glowAlpha,
            animPhase: animPhase,
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final RankModel rank;
  final double glowAlpha;
  final Widget child;
  final String backgroundId;
  final String borderId;

  const _GlassCard({
    required this.rank,
    required this.glowAlpha,
    required this.child,
    required this.backgroundId,
    required this.borderId,
  });

  @override
  Widget build(BuildContext context) {
    final innerContent = Stack(
      children: [
        if (!backgroundId.startsWith('cc')) Positioned.fill(child: _GridPattern(color: rank.color)),
        if (!backgroundId.startsWith('cc')) Positioned.fill(child: _CornerAccents(color: rank.color)),
        child,
      ],
    );

    if (backgroundId == 'cc1') return CallingCardNeonOverdrive(child: innerContent);
    if (backgroundId == 'cc2') return CallingCardSyndicateExecutive(child: innerContent);
    if (backgroundId == 'cc3') return CallingCardCrimsonVendetta(child: innerContent);
    if (backgroundId == 'cc4') return CallingCardCosmicShadow(child: innerContent);
    if (backgroundId == 'cc5') return CallingCardToxicUnderworld(child: innerContent);

    List<Color> bgColors = [
      Colors.black.withValues(alpha: 0.45),
      const Color(0xFF0D0D1F).withValues(alpha: 0.60),
      Colors.black.withValues(alpha: 0.38),
    ];

    if (backgroundId == 's2') {
      bgColors = [
        const Color(0xFF001220).withValues(alpha: 0.8),
        const Color(0xFF00458B).withValues(alpha: 0.6),
        const Color(0xFF001220).withValues(alpha: 0.8),
      ];
    } else if (backgroundId == 's8') {
      bgColors = [
        const Color(0xFF1A1A00).withValues(alpha: 0.8),
        const Color(0xFF4D4D00).withValues(alpha: 0.6),
        const Color(0xFF1A1A00).withValues(alpha: 0.8),
      ];
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: bgColors,
              stops: const [0.0, 0.5, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.13),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: rank.glowColor.withValues(alpha: glowAlpha * 0.25),
                blurRadius: 28,
                spreadRadius: 1,
              ),
            ],
          ),
          child: innerContent,
        ),
      ),
    );
  }
}

class _AvatarRing extends StatelessWidget {
  final UserModel? user;
  final RankModel rank;
  final _FrameStyle frameStyle;
  final double glowAlpha;
  final double animPhase;

  const _AvatarRing({
    required this.user,
    required this.rank,
    required this.frameStyle,
    required this.glowAlpha,
    required this.animPhase,
  });

  static const double _size = 96.0;

  @override
  Widget build(BuildContext context) {
    final accentColor = frameStyle.ringColors.first;
    return SizedBox(
      width: _size + 18,
      height: _size + 18,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: _size + 18,
            height: _size + 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: accentColor.withValues(alpha: glowAlpha), blurRadius: 22, spreadRadius: 5),
                BoxShadow(color: accentColor.withValues(alpha: glowAlpha * 0.35), blurRadius: 44, spreadRadius: 10),
              ],
            ),
          ),
          CustomPaint(
            size: Size(_size + 10, _size + 10),
            painter: _RingPainter(colors: frameStyle.ringColors, phase: animPhase, style: frameStyle),
          ),
          PremiumAvatarBorder(
            borderId: user?.equippedCosmetics.cardBorder,
            radius: _size / 2,
            child: Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceLight,
                border: Border.all(color: AppColors.background, width: 2.5),
              ),
              child: ClipOval(child: _avatarContent()),
            ),
          ),
          Positioned(bottom: 1, right: 1, child: _RankBadge(rank: rank, frameStyle: frameStyle)),
        ],
      ),
    );
  }

  Widget _avatarContent() {
    final url = user?.avatarUrl ?? '';
    final resolved = url.startsWith('/') ? '${AppConstants.apiBaseUrl}$url' : url;
    if (resolved.isNotEmpty) {
      return Image.network(resolved, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => _fallback());
    }
    return _fallback();
  }

  Widget _fallback() {
    final accentColor = frameStyle.ringColors.first;
    final initials = (user?.username.isNotEmpty == true) ? user!.username[0].toUpperCase() : 'A';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentColor.withValues(alpha: 0.35), AppColors.purpleDeep.withValues(alpha: 0.55)],
        ),
      ),
      child: Center(
        child: Text(initials, style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, shadows: [Shadow(color: accentColor, blurRadius: 14)])),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final RankModel rank;
  final _FrameStyle frameStyle;
  const _RankBadge({required this.rank, required this.frameStyle});
  @override
  Widget build(BuildContext context) {
    final colors = frameStyle.ringColors;
    return Container(
      width: 26, height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors.length >= 2 ? [colors.first, colors.last] : [rank.color, rank.color.withValues(alpha: 0.6)]),
        border: Border.all(color: AppColors.background, width: 2.0),
        boxShadow: [BoxShadow(color: colors.first.withValues(alpha: 0.5), blurRadius: 8)],
      ),
      child: Icon(_tierIcon(rank.tier), color: Colors.white, size: 13),
    );
  }
  IconData _tierIcon(int tier) {
    switch (tier) {
      case 0: return Icons.shield_outlined;
      case 1: return Icons.shield;
      case 2: return Icons.military_tech;
      case 3: return Icons.diamond;
      default: return Icons.workspace_premium;
    }
  }
}

class _TitleChip extends StatelessWidget {
  final String title;
  final RankModel rank;
  final Color accentColor;
  const _TitleChip({required this.title, required this.rank, required this.accentColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [accentColor.withValues(alpha: 0.18), Colors.black.withValues(alpha: 0.35)], begin: Alignment.centerLeft, end: Alignment.centerRight),
        border: Border.all(color: accentColor.withValues(alpha: 0.28), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: accentColor, size: 9),
          const SizedBox(width: 5),
          Flexible(child: Text(title.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: accentColor, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.8))),
        ],
      ),
    );
  }
}

class _XpBar extends StatelessWidget {
  final UserModel? user;
  final RankModel rank;
  final Color accentColor;
  const _XpBar({required this.user, required this.rank, required this.accentColor});
  @override
  Widget build(BuildContext context) {
    final bpXP = user?.battlePassXP ?? 0;
    final bpTier = user?.battlePassTier ?? 0;
    const xpPerTier = 1000;
    final progress = ((bpXP % xpPerTier) / xpPerTier).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text('LEVEL ${bpTier + 1}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.white30, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.2))),
          const SizedBox(width: 8),
          Flexible(child: Text('${xpPerTier - (bpXP % xpPerTier)} XP TO NEXT LEVEL', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: TextStyle(color: accentColor.withValues(alpha: 0.65), fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 0.4))),
        ]),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(6), child: SizedBox(height: 8, child: LinearProgressIndicator(value: progress, backgroundColor: Colors.white.withValues(alpha: 0.06), valueColor: AlwaysStoppedAnimation<Color>(accentColor), minHeight: 8))),
      ],
    );
  }
}

enum _FrameShape { circle, hexagonal, octagon }
class _FrameStyle {
  final List<Color> ringColors;
  final _FrameShape shape;
  final double strokeWidth;
  const _FrameStyle({required this.ringColors, required this.shape, this.strokeWidth = 3.0});
  static _FrameStyle forTier(int tier, String borderId) {
    if (borderId == 's1') return const _FrameStyle(ringColors: [AppColors.crimsonRed, Color(0xFFFF5252), Color(0xFFFF8A80)], shape: _FrameShape.octagon, strokeWidth: 3.5);
    if (borderId == 's7') return const _FrameStyle(ringColors: [Color(0xFF80D8FF), Color(0xFF40C4FF), Color(0xFF00B0FF)], shape: _FrameShape.octagon, strokeWidth: 3.5);
    if (borderId == 's8') return const _FrameStyle(ringColors: [AppColors.gold, Color(0xFFFFD600), Color(0xFFFFFF8D)], shape: _FrameShape.hexagonal, strokeWidth: 3.5);
    switch (tier) {
      case 0: return const _FrameStyle(ringColors: [Color(0xFFCD7F32), Color(0xFFB87333), Color(0xFFDA8A45)], shape: _FrameShape.circle, strokeWidth: 2.8);
      case 1: return const _FrameStyle(ringColors: [Color(0xFFC0C0C0), Color(0xFF9E9E9E), Color(0xFFE0E0E0)], shape: _FrameShape.circle, strokeWidth: 2.8);
      case 2: return const _FrameStyle(ringColors: [Color(0xFFFFD700), Color(0xFFFF8F00), Color(0xFFFFEC61)], shape: _FrameShape.hexagonal, strokeWidth: 3.2);
      case 3: return const _FrameStyle(ringColors: [Color(0xFF00E5FF), Color(0xFF00B4D8), Color(0xFF80FFFF)], shape: _FrameShape.octagon, strokeWidth: 3.2);
      default: return const _FrameStyle(ringColors: [Color(0xFF9B59FF), Color(0xFF6C3CE0), Color(0xFFBB86FC), Color(0xFF9B59FF)], shape: _FrameShape.octagon, strokeWidth: 3.5);
    }
  }
}

class _RingPainter extends CustomPainter {
  final List<Color> colors;
  final double phase;
  final _FrameStyle style;
  const _RingPainter({required this.colors, required this.phase, required this.style});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweep = SweepGradient(colors: [...colors, colors.first], startAngle: phase * 2 * pi, endAngle: phase * 2 * pi + 2 * pi);
    final paint = Paint()..shader = sweep.createShader(Rect.fromCircle(center: center, radius: radius))..style = PaintingStyle.stroke..strokeWidth = style.strokeWidth..strokeCap = StrokeCap.round;
    switch (style.shape) {
      case _FrameShape.circle: canvas.drawCircle(center, radius - style.strokeWidth / 2, paint);
      case _FrameShape.hexagonal: _drawPolygon(canvas, center, radius - style.strokeWidth / 2, 6, -30, paint);
      case _FrameShape.octagon: _drawPolygon(canvas, center, radius - style.strokeWidth / 2, 8, -22.5, paint);
    }
  }
  void _drawPolygon(Canvas canvas, Offset center, double r, int sides, double startAngleDeg, Paint paint) {
    final path = Path();
    for (int i = 0; i < sides; i++) {
      final angle = (startAngleDeg + i * 360 / sides) * pi / 180;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant _RingPainter old) => old.phase != phase;
}

class _GridPattern extends StatelessWidget {
  final Color color;
  const _GridPattern({required this.color});
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GridPatternPainter(color: color));
}

class _GridPatternPainter extends CustomPainter {
  final Color color;
  const _GridPatternPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.03)..style = PaintingStyle.stroke..strokeWidth = 0.5;
    const s = 26.0;
    for (double x = 0; x < size.width + s; x += s) {
      for (double y = 0; y < size.height + s; y += s) {
        canvas.drawPath(Path()..moveTo(x, y - s / 2)..lineTo(x + s / 2, y)..lineTo(x, y + s / 2)..lineTo(x - s / 2, y)..close(), paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant _GridPatternPainter old) => false;
}

class _CornerAccents extends StatelessWidget {
  final Color color;
  const _CornerAccents({required this.color});
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _CornerPainter(color: color));
}

class _CornerPainter extends CustomPainter {
  final Color color;
  const _CornerPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.35)..style = PaintingStyle.stroke..strokeWidth = 1.4..strokeCap = StrokeCap.square;
    const len = 14.0; const margin = 9.0;
    canvas.drawLine(const Offset(margin, margin), const Offset(margin + len, margin), paint);
    canvas.drawLine(const Offset(margin, margin), const Offset(margin, margin + len), paint);
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin - len, margin), paint);
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin, margin + len), paint);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin + len, size.height - margin), paint);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin, size.height - margin - len), paint);
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin - len, size.height - margin), paint);
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin, size.height - margin - len), paint);
  }
  @override
  bool shouldRepaint(covariant _CornerPainter old) => false;
}
