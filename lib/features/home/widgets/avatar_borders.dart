import 'dart:math';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  MAFIA AT CITY — Avatar Border Collection
//  20 unique designs: Gothic | Cyberpunk | Villain | Underworld
// ═══════════════════════════════════════════════════════════════════════════════

/// All available border IDs — pass one of these as [borderId].
///
///  b1  — Shadow Sovereign      (gothic pulsing dark-gold crown aura)
///  b2  — Neon Don              (cyberpunk purple-magenta spinning sweep)
///  b3  — Phantom Protocol      (masked-villain rotating dashed circuit ring)
///  b4  — Bloodpact             (crimson heartbeat throb)
///  b5  — Void Walker           (deep-void black-hole rotating rings)
///  b6  — Golden Cartel         (royal gold shimmer with corner ornaments)
///  b7  — Glitch Syndicate      (RGB glitch offset triple ring)
///  b8  — Wraith Signal         (ghost-white fade breath)
///  b9  — Toxic Enforcer        (acid green biohazard spin)
///  b10 — Eclipse Boss          (solar-eclipse corona slow burn)
///  b11 — Dark Masquerade       (violet sweep with ornate mask silhouette dots)
///  b12 — Thunder Capo          (electric arc lightning flash)
///  b13 — Obsidian Throne       (still black-gold engraved octagon)
///  b14 — Revenant              (undead teal mist drift)
///  b15 — Digital Overlord      (matrix green raining tick)
///  b16 — Crimson Veil          (slow-burn dark red veil pulse)
///  b17 — Specter of the City   (dual-ring counter-rotate cyan/purple)
///  b18 — Godfather's Seal      (slow breathing heavy gold ring with chain dots)
///  b19 — Nightfall Assassin    (invisible-to-visible knife-edge appear)
///  b20 — Infernal Pact         (hell-fire radial blaze)

class PremiumAvatarBorder extends StatelessWidget {
  final Widget child;
  final String? borderId;
  final double radius;

  const PremiumAvatarBorder({
    super.key,
    required this.child,
    this.borderId,
    this.radius = 35,
  });

  @override
  Widget build(BuildContext context) {
    switch (borderId) {
      case 'b1':
        return _ShadowSovereignBorder(radius: radius, child: child);
      case 'b2':
        return _NeonDonBorder(radius: radius, child: child);
      case 'b3':
        return _PhantomProtocolBorder(radius: radius, child: child);
      case 'b4':
        return _BloodpactBorder(radius: radius, child: child);
      case 'b5':
        return _VoidWalkerBorder(radius: radius, child: child);
      case 'b6':
        return _GoldenCartelBorder(radius: radius, child: child);
      case 'b7':
        return _GlitchSyndicateBorder(radius: radius, child: child);
      case 'b8':
        return _WraithSignalBorder(radius: radius, child: child);
      case 'b9':
        return _ToxicEnforcerBorder(radius: radius, child: child);
      case 'b10':
        return _EclipseBossBorder(radius: radius, child: child);
      case 'b11':
        return _DarkMasqueradeBorder(radius: radius, child: child);
      case 'b12':
        return _ThunderCapoBorder(radius: radius, child: child);
      case 'b13':
        return _ObsidianThroneBorder(radius: radius, child: child);
      case 'b14':
        return _RevenantBorder(radius: radius, child: child);
      case 'b15':
        return _DigitalOverlordBorder(radius: radius, child: child);
      case 'b16':
        return _CrimsonVeilBorder(radius: radius, child: child);
      case 'b17':
        return _SpecterOfTheCityBorder(radius: radius, child: child);
      case 'b18':
        return _GodfathersSealBorder(radius: radius, child: child);
      case 'b19':
        return _NightfallAssassinBorder(radius: radius, child: child);
      case 'b20':
        return _InfernalPactBorder(radius: radius, child: child);
      default:
        return child;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────────────────────────

/// Cuts a circular mask so glow layers don't bleed into the avatar.
class _CircleMask extends StatelessWidget {
  final double size;
  const _CircleMask({required this.size});
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF080808),
        shape: BoxShape.circle,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// B1 — SHADOW SOVEREIGN
// Gothic: pulsing dark-gold crown-aura with slow radial sweep
// ─────────────────────────────────────────────────────────────────────────────
class _ShadowSovereignBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _ShadowSovereignBorder({required this.child, required this.radius});
  @override
  State<_ShadowSovereignBorder> createState() => _ShadowSovereignBorderState();
}

class _ShadowSovereignBorderState extends State<_ShadowSovereignBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        final glow = 0.15 + _pulse.value * 0.55;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer aura
            IgnorePointer(
              child: Container(
                width: s + 16,
                height: s + 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFFD4AF37,
                      ).withValues(alpha: glow * 0.6),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: const Color(0xFF2A0050).withValues(alpha: 0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            // Crown ring: dark gold → black sweep
            IgnorePointer(
              child: Container(
                width: s + 10,
                height: s + 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Color(0xFF0D0D0D),
                      Color(0xFFD4AF37),
                      Color(0xFFFFF8DC),
                      Color(0xFFD4AF37),
                      Color(0xFF0D0D0D),
                    ],
                    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
                  ),
                ),
              ),
            ),
            _CircleMask(size: s + 2),
            // Crown tooth painter
            IgnorePointer(
              child: CustomPaint(
                size: Size(s + 10, s + 10),
                painter: _CrownToothPainter(
                  color: const Color(0xFFD4AF37).withValues(alpha: glow),
                ),
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}

class _CrownToothPainter extends CustomPainter {
  final Color color;
  const _CrownToothPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final r = size.width / 2;
    final c = Offset(r, r);
    // Draw 6 small pointed ticks around the ring like crown teeth
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * pi - pi / 2;
      final inner = Offset(
        c.dx + (r - 6) * cos(angle),
        c.dy + (r - 6) * sin(angle),
      );
      final outer = Offset(
        c.dx + (r + 3) * cos(angle),
        c.dy + (r + 3) * sin(angle),
      );
      canvas.drawLine(inner, outer, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CrownToothPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// B2 — NEON DON
// Cyberpunk: fast magenta-purple-cyan spinning sweep + outer ring
// ─────────────────────────────────────────────────────────────────────────────
class _NeonDonBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _NeonDonBorder({required this.child, required this.radius});
  @override
  State<_NeonDonBorder> createState() => _NeonDonBorderState();
}

class _NeonDonBorderState extends State<_NeonDonBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Neon glow halo
        IgnorePointer(
          child: Container(
            width: s + 14,
            height: s + 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFBF00FF).withValues(alpha: 0.45),
                  blurRadius: 18,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: const Color(0xFF00FFFF).withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
        // Static outer thin ring
        IgnorePointer(
          child: Container(
            width: s + 10,
            height: s + 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFBF00FF).withValues(alpha: 0.35),
                width: 1,
              ),
            ),
          ),
        ),
        // Spinning sweep
        IgnorePointer(
          child: RotationTransition(
            turns: _ctrl,
            child: Container(
              width: s + 8,
              height: s + 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFFBF00FF),
                    Color(0xFF00FFFF),
                    Color(0xFFFF00AA),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.15, 0.35, 0.55, 0.7],
                ),
              ),
            ),
          ),
        ),
        _CircleMask(size: s + 2),
        widget.child,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// B3 — PHANTOM PROTOCOL
// Villain-masked: rotating dashed circuit ring with corner nodes
// ─────────────────────────────────────────────────────────────────────────────
class _PhantomProtocolBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _PhantomProtocolBorder({required this.child, required this.radius});
  @override
  State<_PhantomProtocolBorder> createState() => _PhantomProtocolBorderState();
}

class _PhantomProtocolBorderState extends State<_PhantomProtocolBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          child: Container(
            width: s + 12,
            height: s + 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00CFFF).withValues(alpha: 0.25),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.rotate(
              angle: _ctrl.value * 2 * pi,
              child: CustomPaint(
                size: Size(s + 10, s + 10),
                painter: _CircuitDashPainter(),
              ),
            ),
          ),
        ),
        _CircleMask(size: s + 2),
        widget.child,
      ],
    );
  }
}

class _CircuitDashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final paint = Paint()
      ..color = const Color(0xFF00CFFF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw dashed circle
    for (int i = 0; i < 36; i++) {
      if (i % 3 == 0) continue; // gap every 3rd segment
      final a1 = (i / 36) * 2 * pi;
      final a2 = ((i + 0.7) / 36) * 2 * pi;
      final path = Path()
        ..addArc(Rect.fromCircle(center: c, radius: r - 2), a1, a2 - a1);
      canvas.drawPath(path, paint);
    }

    // Node squares at cardinal points
    final nodePaint = Paint()
      ..color = const Color(0xFF00CFFF)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 8; i++) {
      final a = (i / 8) * 2 * pi;
      final nx = c.dx + (r - 2) * cos(a);
      final ny = c.dy + (r - 2) * sin(a);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(nx, ny), width: 4, height: 4),
        nodePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// B4 — BLOODPACT
// Villain: heartbeat-throb crimson glow, irregular pulse rhythm
// ─────────────────────────────────────────────────────────────────────────────
class _BloodpactBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _BloodpactBorder({required this.child, required this.radius});
  @override
  State<_BloodpactBorder> createState() => _BloodpactBorderState();
}

class _BloodpactBorderState extends State<_BloodpactBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _beat;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
    // Double-beat heartbeat curve
    _beat = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
          ..chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.3)
          ..chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.3, end: 0.9)
          ..chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 0.0)
          ..chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 30),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return AnimatedBuilder(
      animation: _beat,
      builder: (_, __) {
        final v = _beat.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            IgnorePointer(
              child: Container(
                width: s + 14,
                height: s + 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B0000).withValues(alpha: v * 0.7),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF2222).withValues(alpha: v * 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            IgnorePointer(
              child: Container(
                width: s + 8,
                height: s + 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color.lerp(
                      const Color(0xFF3D0000),
                      const Color(0xFFFF2222),
                      v,
                    )!,
                    width: 2.5 + v * 1.5,
                  ),
                ),
              ),
            ),
            _CircleMask(size: s + 2),
            widget.child,
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// B5 — VOID WALKER
// Gothic: twin counter-rotating deep-void black rings with purple aura
// ─────────────────────────────────────────────────────────────────────────────
class _VoidWalkerBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _VoidWalkerBorder({required this.child, required this.radius});
  @override
  State<_VoidWalkerBorder> createState() => _VoidWalkerBorderState();
}

class _VoidWalkerBorderState extends State<_VoidWalkerBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          child: Container(
            width: s + 18,
            height: s + 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6600CC).withValues(alpha: 0.5),
                  blurRadius: 22,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
        ),
        // Outer ring — forward
        IgnorePointer(
          child: RotationTransition(
            turns: _ctrl,
            child: Container(
              width: s + 12,
              height: s + 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Color(0xFF000000),
                    Color(0xFF6600CC),
                    Color(0xFF9933FF),
                    Color(0xFF6600CC),
                    Color(0xFF000000),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Inner ring — reverse
        IgnorePointer(
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: -1.0).animate(_ctrl),
            child: Container(
              width: s + 5,
              height: s + 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFF9933FF),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.12, 0.25],
                ),
              ),
            ),
          ),
        ),
        _CircleMask(size: s + 1),
        widget.child,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// B6 — GOLDEN CARTEL
// VIP: royal-gold shimmer breathing glow, diamond-pattern ornament dots
// ─────────────────────────────────────────────────────────────────────────────
class _GoldenCartelBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _GoldenCartelBorder({required this.child, required this.radius});
  @override
  State<_GoldenCartelBorder> createState() => _GoldenCartelBorderState();
}

class _GoldenCartelBorderState extends State<_GoldenCartelBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _shimmer = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: Container(
              width: s + 14,
              height: s + 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFFD4AF37,
                    ).withValues(alpha: 0.25 + _shimmer.value * 0.45),
                    blurRadius: 18,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          // Gold ring
          IgnorePointer(
            child: Container(
              width: s + 9,
              height: s + 9,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFD4AF37),
                    Color(0xFFFFF8DC),
                    Color(0xFF8B6914),
                    Color(0xFFD4AF37),
                  ],
                ),
              ),
            ),
          ),
          // Diamond ornament dots
          IgnorePointer(
            child: CustomPaint(
              size: Size(s + 9, s + 9),
              painter: _DiamondDotPainter(alpha: 0.6 + _shimmer.value * 0.4),
            ),
          ),
          _CircleMask(size: s + 2),
          widget.child,
        ],
      ),
    );
  }
}

class _DiamondDotPainter extends CustomPainter {
  final double alpha;
  const _DiamondDotPainter({required this.alpha});
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final paint = Paint()
      ..color = const Color(0xFFFFF8DC).withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final a = (i / 4) * 2 * pi - pi / 4;
      final x = c.dx + r * cos(a);
      final y = c.dy + r * sin(a);
      // Diamond shape (rotated square)
      final path = Path()
        ..moveTo(x, y - 4)
        ..lineTo(x + 3, y)
        ..lineTo(x, y + 4)
        ..lineTo(x - 3, y)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiamondDotPainter old) => old.alpha != alpha;
}

// ─────────────────────────────────────────────────────────────────────────────
// B7 — GLITCH SYNDICATE
// Cyberpunk: RGB channel offset triple-ring glitch flash
// ─────────────────────────────────────────────────────────────────────────────
class _GlitchSyndicateBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _GlitchSyndicateBorder({required this.child, required this.radius});
  @override
  State<_GlitchSyndicateBorder> createState() => _GlitchSyndicateBorderState();
}

class _GlitchSyndicateBorderState extends State<_GlitchSyndicateBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        // Glitch fires in short windows
        final t = _ctrl.value;
        final glitching = (t > 0.1 && t < 0.18) || (t > 0.55 && t < 0.6);
        final offset = glitching ? (Random().nextDouble() * 4 - 2) : 0.0;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Red channel
            IgnorePointer(
              child: Transform.translate(
                offset: Offset(glitching ? offset : 0, 0),
                child: Container(
                  width: s + 8,
                  height: s + 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(
                          alpha: glitching ? 0.7 : 0.15,
                        ),
                        blurRadius: 6,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.red.withValues(
                        alpha: glitching ? 0.8 : 0.2,
                      ),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            // Blue channel
            IgnorePointer(
              child: Transform.translate(
                offset: Offset(glitching ? -offset : 0, 0),
                child: Container(
                  width: s + 10,
                  height: s + 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(
                          alpha: glitching ? 0.7 : 0.15,
                        ),
                        blurRadius: 6,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.blue.withValues(
                        alpha: glitching ? 0.8 : 0.2,
                      ),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            // White base ring
            IgnorePointer(
              child: Container(
                width: s + 6,
                height: s + 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: glitching ? Colors.white : const Color(0xFF888888),
                    width: 2,
                  ),
                ),
              ),
            ),
            _CircleMask(size: s + 1),
            widget.child,
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// B8 — WRAITH SIGNAL
// Gothic: ghostly white breath fade, slow drift
// ─────────────────────────────────────────────────────────────────────────────
class _WraithSignalBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _WraithSignalBorder({required this.child, required this.radius});
  @override
  State<_WraithSignalBorder> createState() => _WraithSignalBorderState();
}

class _WraithSignalBorderState extends State<_WraithSignalBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _breath;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _breath = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return AnimatedBuilder(
      animation: _breath,
      builder: (_, __) {
        final v = _breath.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer mist
            IgnorePointer(
              child: Container(
                width: s + 18,
                height: s + 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: v * 0.12),
                      blurRadius: 24,
                      spreadRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
            // Ghost ring
            IgnorePointer(
              child: Container(
                width: s + 8,
                height: s + 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.1 + v * 0.4),
                      Colors.white.withValues(alpha: 0.05 + v * 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: Container(
                width: s + 5,
                height: s + 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08 + v * 0.25),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            _CircleMask(size: s + 1),
            widget.child,
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// B9 — TOXIC ENFORCER
// Villain: acid-green biohazard spinning segment with drip-glow
// ─────────────────────────────────────────────────────────────────────────────
class _ToxicEnforcerBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _ToxicEnforcerBorder({required this.child, required this.radius});
  @override
  State<_ToxicEnforcerBorder> createState() => _ToxicEnforcerBorderState();
}

class _ToxicEnforcerBorderState extends State<_ToxicEnforcerBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final glow = 4.0 + sin(_ctrl.value * 2 * pi).abs() * 12;
        return Stack(
          alignment: Alignment.center,
          children: [
            IgnorePointer(
              child: Container(
                width: s + 14,
                height: s + 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF39FF14).withValues(alpha: 0.35),
                      blurRadius: glow,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            // Static outer ring
            IgnorePointer(
              child: Container(
                width: s + 9,
                height: s + 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF39FF14).withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Spinning 3-segment hazard
            IgnorePointer(
              child: RotationTransition(
                turns: _ctrl,
                child: CustomPaint(
                  size: Size(s + 9, s + 9),
                  painter: _BiohazardSegmentPainter(),
                ),
              ),
            ),
            _CircleMask(size: s + 2),
            widget.child,
          ],
        );
      },
    );
  }
}

class _BiohazardSegmentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final paint = Paint()
      ..color = const Color(0xFF39FF14)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    // 3 arcs, 120° apart (biohazard)
    for (int i = 0; i < 3; i++) {
      final startAngle = (i / 3) * 2 * pi - pi / 6;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r - 2),
        startAngle,
        pi / 4,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// B10 — ECLIPSE BOSS
// Gothic/Power: solar-eclipse gold-to-black corona, very slow rotation
// ─────────────────────────────────────────────────────────────────────────────
class _EclipseBossBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _EclipseBossBorder({required this.child, required this.radius});
  @override
  State<_EclipseBossBorder> createState() => _EclipseBossBorderState();
}

class _EclipseBossBorderState extends State<_EclipseBossBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          child: Container(
            width: s + 16,
            height: s + 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
        IgnorePointer(
          child: RotationTransition(
            turns: _ctrl,
            child: Container(
              width: s + 10,
              height: s + 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Color(0xFFD4AF37),
                    Color(0xFFFFF5C3),
                    Color(0xFF000000),
                    Color(0xFF6B4C00),
                    Color(0xFFD4AF37),
                  ],
                  stops: [0.0, 0.15, 0.5, 0.85, 1.0],
                ),
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: CustomPaint(
            size: Size(s + 10, s + 10),
            painter: _EclipseRayPainter(),
          ),
        ),
        _CircleMask(size: s + 2),
        widget.child,
      ],
    );
  }
}

class _EclipseRayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    // Short corona rays
    for (int i = 0; i < 24; i++) {
      final a = (i / 24) * 2 * pi;
      final inner = Offset(c.dx + (r - 4) * cos(a), c.dy + (r - 4) * sin(a));
      final outer = Offset(c.dx + (r + 4) * cos(a), c.dy + (r + 4) * sin(a));
      canvas.drawLine(inner, outer, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// B11 — DARK MASQUERADE
// Villain: violet sweep with 6 ornate mask-dot positions (static elegance)
// ─────────────────────────────────────────────────────────────────────────────
class _DarkMasqueradeBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _DarkMasqueradeBorder({required this.child, required this.radius});
  @override
  State<_DarkMasqueradeBorder> createState() => _DarkMasqueradeBorderState();
}

class _DarkMasqueradeBorderState extends State<_DarkMasqueradeBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final v = _ctrl.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            IgnorePointer(
              child: Container(
                width: s + 14,
                height: s + 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF7B2FBE,
                      ).withValues(alpha: 0.2 + v * 0.4),
                      blurRadius: 16,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
            IgnorePointer(
              child: Container(
                width: s + 8,
                height: s + 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Color(0xFF1A0030),
                      Color(0xFF7B2FBE),
                      Color(0xFFBF7FFF),
                      Color(0xFF7B2FBE),
                      Color(0xFF1A0030),
                    ],
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: CustomPaint(
                size: Size(s + 8, s + 8),
                painter: _MasqueradeDotPainter(alpha: 0.5 + v * 0.5),
              ),
            ),
            _CircleMask(size: s + 1),
            widget.child,
          ],
        );
      },
    );
  }
}

class _MasqueradeDotPainter extends CustomPainter {
  final double alpha;
  const _MasqueradeDotPainter({required this.alpha});
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final p1 = Paint()
      ..color = const Color(0xFFBF7FFF).withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    final p2 = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: alpha * 0.5)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 6; i++) {
      final a = (i / 6) * 2 * pi;
      final x = c.dx + r * cos(a);
      final y = c.dy + r * sin(a);
      canvas.drawCircle(Offset(x, y), i.isEven ? 3 : 2, i.isEven ? p1 : p2);
    }
  }

  @override
  bool shouldRepaint(covariant _MasqueradeDotPainter old) => old.alpha != alpha;
}

// ─────────────────────────────────────────────────────────────────────────────
// B12 — THUNDER CAPO
// Cyberpunk: electric arc lightning flash effect around ring
// ─────────────────────────────────────────────────────────────────────────────
class _ThunderCapoBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _ThunderCapoBorder({required this.child, required this.radius});
  @override
  State<_ThunderCapoBorder> createState() => _ThunderCapoBorderState();
}

class _ThunderCapoBorderState extends State<_ThunderCapoBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        final flashing = t < 0.08 || (t > 0.45 && t < 0.5);
        final seed = (t * 1000).toInt();
        return Stack(
          alignment: Alignment.center,
          children: [
            IgnorePointer(
              child: Container(
                width: s + 14,
                height: s + 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFFFFE033,
                      ).withValues(alpha: flashing ? 0.85 : 0.15),
                      blurRadius: flashing ? 22 : 8,
                      spreadRadius: flashing ? 4 : 1,
                    ),
                  ],
                ),
              ),
            ),
            IgnorePointer(
              child: Container(
                width: s + 8,
                height: s + 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: flashing
                        ? const Color(0xFFFFE033)
                        : const Color(0xFF665500),
                    width: flashing ? 2.5 : 1.5,
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: CustomPaint(
                size: Size(s + 8, s + 8),
                painter: _LightningArcPainter(seed: seed, visible: flashing),
              ),
            ),
            _CircleMask(size: s + 2),
            widget.child,
          ],
        );
      },
    );
  }
}

class _LightningArcPainter extends CustomPainter {
  final int seed;
  final bool visible;
  const _LightningArcPainter({required this.seed, required this.visible});
  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;
    final rng = Random(seed);
    final r = size.width / 2;
    final c = Offset(r, r);
    final paint = Paint()
      ..color = const Color(0xFFFFE033).withValues(alpha: 0.9)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 3; i++) {
      final a = rng.nextDouble() * 2 * pi;
      final span = (pi / 6) + rng.nextDouble() * (pi / 4);
      final jag = (r - 4) + rng.nextDouble() * 8 - 4;
      final midA = a + span / 2;
      final p1 = Offset(c.dx + r * cos(a), c.dy + r * sin(a));
      final p2 = Offset(c.dx + jag * cos(midA), c.dy + jag * sin(midA));
      final p3 = Offset(c.dx + r * cos(a + span), c.dy + r * sin(a + span));
      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LightningArcPainter old) =>
      old.seed != seed || old.visible != visible;
}

// ─────────────────────────────────────────────────────────────────────────────
// B13 — OBSIDIAN THRONE
// Gothic Static: still black-gold engraved 8-point octagon border
// ─────────────────────────────────────────────────────────────────────────────
class _ObsidianThroneBorder extends StatelessWidget {
  final Widget child;
  final double radius;
  const _ObsidianThroneBorder({required this.child, required this.radius});

  @override
  Widget build(BuildContext context) {
    final s = radius * 2;
    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          child: Container(
            width: s + 14,
            height: s + 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
        IgnorePointer(
          child: CustomPaint(
            size: Size(s + 12, s + 12),
            painter: _OctagonEngravedPainter(),
          ),
        ),
        _CircleMask(size: s + 2),
        child,
      ],
    );
  }
}

class _OctagonEngravedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);

    // Outer octagon
    final outerPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final outerPath = Path();
    for (int i = 0; i < 8; i++) {
      final a = (i / 8) * 2 * pi - pi / 8;
      final x = c.dx + (r - 1) * cos(a);
      final y = c.dy + (r - 1) * sin(a);
      i == 0 ? outerPath.moveTo(x, y) : outerPath.lineTo(x, y);
    }
    outerPath.close();
    canvas.drawPath(outerPath, outerPaint);

    // Inner faint circle
    canvas.drawCircle(
      c,
      r - 4,
      Paint()
        ..color = const Color(0xFFD4AF37).withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Corner ornament triangles
    final triPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 8; i++) {
      final a = (i / 8) * 2 * pi - pi / 8;
      final x = c.dx + (r - 1) * cos(a);
      final y = c.dy + (r - 1) * sin(a);
      canvas.drawCircle(Offset(x, y), 2.5, triPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// B14 — REVENANT
// Gothic: undead teal mist drift with counter-rotating inner spark
// ─────────────────────────────────────────────────────────────────────────────
class _RevenantBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _RevenantBorder({required this.child, required this.radius});
  @override
  State<_RevenantBorder> createState() => _RevenantBorderState();
}

class _RevenantBorderState extends State<_RevenantBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _mist;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
    _mist = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final v = sin(_ctrl.value * 2 * pi) * 0.5 + 0.5;
        return Stack(
          alignment: Alignment.center,
          children: [
            IgnorePointer(
              child: Container(
                width: s + 18,
                height: s + 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF00FFCC,
                      ).withValues(alpha: 0.1 + v * 0.2),
                      blurRadius: 22,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
            IgnorePointer(
              child: RotationTransition(
                turns: _ctrl,
                child: Container(
                  width: s + 10,
                  height: s + 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFF00FFCC).withValues(alpha: 0.7),
                        const Color(0xFF006655).withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.1, 0.2, 0.4],
                    ),
                  ),
                ),
              ),
            ),
            // Static mist ring
            IgnorePointer(
              child: Container(
                width: s + 6,
                height: s + 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(
                      0xFF00FFCC,
                    ).withValues(alpha: 0.15 + v * 0.2),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            _CircleMask(size: s + 1),
            widget.child,
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// B15 — DIGITAL OVERLORD
// Cyberpunk: matrix-green cascade tick marks rotate slowly
// ─────────────────────────────────────────────────────────────────────────────
class _DigitalOverlordBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _DigitalOverlordBorder({required this.child, required this.radius});
  @override
  State<_DigitalOverlordBorder> createState() => _DigitalOverlordBorderState();
}

class _DigitalOverlordBorderState extends State<_DigitalOverlordBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          child: Container(
            width: s + 14,
            height: s + 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FF41).withValues(alpha: 0.3),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.rotate(
              angle: _ctrl.value * 2 * pi,
              child: CustomPaint(
                size: Size(s + 10, s + 10),
                painter: _MatrixTickPainter(progress: _ctrl.value),
              ),
            ),
          ),
        ),
        _CircleMask(size: s + 2),
        widget.child,
      ],
    );
  }
}

class _MatrixTickPainter extends CustomPainter {
  final double progress;
  const _MatrixTickPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    // 32 ticks; lit ones cascade based on progress
    for (int i = 0; i < 32; i++) {
      final lit = (i / 32) < (progress % 1.0) || i < 4;
      final alpha = lit ? (0.8 - (i / 32) * 0.5).clamp(0.1, 0.9) : 0.08;
      final paint = Paint()
        ..color = const Color(0xFF00FF41).withValues(alpha: alpha)
        ..strokeWidth = i % 4 == 0 ? 2 : 1
        ..strokeCap = StrokeCap.round;
      final a = (i / 32) * 2 * pi;
      final len = i % 8 == 0 ? 8.0 : (i % 4 == 0 ? 5.0 : 3.0);
      canvas.drawLine(
        Offset(c.dx + (r - len) * cos(a), c.dy + (r - len) * sin(a)),
        Offset(c.dx + r * cos(a), c.dy + r * sin(a)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MatrixTickPainter old) =>
      old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// B16 — CRIMSON VEIL
// Villain: slow-burn dark red veil pulse with inner ember ring
// ─────────────────────────────────────────────────────────────────────────────
class _CrimsonVeilBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _CrimsonVeilBorder({required this.child, required this.radius});
  @override
  State<_CrimsonVeilBorder> createState() => _CrimsonVeilBorderState();
}

class _CrimsonVeilBorderState extends State<_CrimsonVeilBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final v = sin(_ctrl.value * 2 * pi) * 0.5 + 0.5;
        return Stack(
          alignment: Alignment.center,
          children: [
            IgnorePointer(
              child: Container(
                width: s + 16,
                height: s + 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF8B0000,
                      ).withValues(alpha: 0.2 + v * 0.5),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
            IgnorePointer(
              child: RotationTransition(
                turns: _ctrl,
                child: Container(
                  width: s + 10,
                  height: s + 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Color(0xFF0D0000),
                        Color(0xFF8B0000),
                        Color(0xFFFF2200),
                        Color(0xFF8B0000),
                        Color(0xFF0D0000),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: Container(
                width: s + 4,
                height: s + 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(
                      0xFFFF4400,
                    ).withValues(alpha: 0.2 + v * 0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
            _CircleMask(size: s + 2),
            widget.child,
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// B17 — SPECTER OF THE CITY
// Cyberpunk: dual-ring counter-rotate, cyan outer / purple inner
// ─────────────────────────────────────────────────────────────────────────────
class _SpecterOfTheCityBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _SpecterOfTheCityBorder({required this.child, required this.radius});
  @override
  State<_SpecterOfTheCityBorder> createState() =>
      _SpecterOfTheCityBorderState();
}

class _SpecterOfTheCityBorderState extends State<_SpecterOfTheCityBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          child: Container(
            width: s + 16,
            height: s + 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withValues(alpha: 0.2),
                  blurRadius: 14,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: const Color(0xFF9933FF).withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
        // Cyan outer — forward
        IgnorePointer(
          child: RotationTransition(
            turns: _ctrl,
            child: Container(
              width: s + 12,
              height: s + 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFF00FFFF),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.18, 0.36],
                ),
              ),
            ),
          ),
        ),
        // Purple inner — reverse
        IgnorePointer(
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: -1.0).animate(_ctrl),
            child: Container(
              width: s + 5,
              height: s + 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFF9933FF),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.12, 0.25],
                ),
              ),
            ),
          ),
        ),
        // Static divider ring
        IgnorePointer(
          child: Container(
            width: s + 8,
            height: s + 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.07),
                width: 1,
              ),
            ),
          ),
        ),
        _CircleMask(size: s + 1),
        widget.child,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// B18 — GODFATHER'S SEAL
// VIP Gothic: heavy gold ring with slow breathing + chain-link dots
// ─────────────────────────────────────────────────────────────────────────────
class _GodfathersSealBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _GodfathersSealBorder({required this.child, required this.radius});
  @override
  State<_GodfathersSealBorder> createState() => _GodfathersSealBorderState();
}

class _GodfathersSealBorderState extends State<_GodfathersSealBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _breath;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    _breath = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return AnimatedBuilder(
      animation: _breath,
      builder: (_, __) {
        final v = _breath.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Heavy glow
            IgnorePointer(
              child: Container(
                width: s + 18,
                height: s + 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFFD4AF37,
                      ).withValues(alpha: 0.15 + v * 0.3),
                      blurRadius: 22,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: const Color(0xFF3D2B00).withValues(alpha: 0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            // Heavy gold ring
            IgnorePointer(
              child: Container(
                width: s + 10,
                height: s + 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD4AF37),
                    width: 3 + v * 1,
                  ),
                ),
              ),
            ),
            // Chain-link dots
            IgnorePointer(
              child: CustomPaint(
                size: Size(s + 10, s + 10),
                painter: _ChainLinkPainter(alpha: 0.4 + v * 0.6),
              ),
            ),
            // Inner thin ring
            IgnorePointer(
              child: Container(
                width: s + 3,
                height: s + 3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
              ),
            ),
            _CircleMask(size: s + 2),
            widget.child,
          ],
        );
      },
    );
  }
}

class _ChainLinkPainter extends CustomPainter {
  final double alpha;
  const _ChainLinkPainter({required this.alpha});
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final paint = Paint()
      ..color = const Color(0xFFFFF5C3).withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    // 16 small chain oval-links
    for (int i = 0; i < 16; i++) {
      final a = (i / 16) * 2 * pi;
      final x = c.dx + r * cos(a);
      final y = c.dy + r * sin(a);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(a + pi / 2);
      canvas.drawOval(const Rect.fromLTWH(-2, -3.5, 4, 7), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ChainLinkPainter old) => old.alpha != alpha;
}

// ─────────────────────────────────────────────────────────────────────────────
// B19 — NIGHTFALL ASSASSIN
// Gothic: razor-thin appear/disappear knife-edge arcs, near-invisible
// ─────────────────────────────────────────────────────────────────────────────
class _NightfallAssassinBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _NightfallAssassinBorder({required this.child, required this.radius});
  @override
  State<_NightfallAssassinBorder> createState() =>
      _NightfallAssassinBorderState();
}

class _NightfallAssassinBorderState extends State<_NightfallAssassinBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IgnorePointer(
              child: Container(
                width: s + 10,
                height: s + 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(
                        alpha: sin(_ctrl.value * 2 * pi).abs() * 0.15,
                      ),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => Transform.rotate(
                  angle: _ctrl.value * 2 * pi,
                  child: CustomPaint(
                    size: Size(s + 10, s + 10),
                    painter: _KnifeEdgePainter(progress: _ctrl.value),
                  ),
                ),
              ),
            ),
            _CircleMask(size: s + 2),
            widget.child,
          ],
        );
      },
    );
  }
}

class _KnifeEdgePainter extends CustomPainter {
  final double progress;
  const _KnifeEdgePainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    // 3 thin razor arcs that appear/fade
    for (int i = 0; i < 3; i++) {
      final phase = (progress + i / 3) % 1.0;
      final alpha = sin(phase * pi).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.7)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      final startAngle = (i / 3) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r - 2),
        startAngle,
        pi / 5,
        false,
        paint,
      );
    }
    // Inner narrow ring
    canvas.drawCircle(
      c,
      r - 5,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _KnifeEdgePainter old) =>
      old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// B20 — INFERNAL PACT
// Villain: hellfire radial blaze, rotating orange-red-yellow burst
// ─────────────────────────────────────────────────────────────────────────────
class _InfernalPactBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _InfernalPactBorder({required this.child, required this.radius});
  @override
  State<_InfernalPactBorder> createState() => _InfernalPactBorderState();
}

class _InfernalPactBorderState extends State<_InfernalPactBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.radius * 2;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final flicker = sin(_ctrl.value * 2 * pi * 3) * 0.15;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Hell-fire glow
            IgnorePointer(
              child: Container(
                width: s + 18,
                height: s + 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFFFF4400,
                      ).withValues(alpha: 0.45 + flicker),
                      blurRadius: 22,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: const Color(
                        0xFFFF8800,
                      ).withValues(alpha: 0.3 + flicker),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
            // Rotating radial blaze
            IgnorePointer(
              child: RotationTransition(
                turns: _ctrl,
                child: Container(
                  width: s + 12,
                  height: s + 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Color(0xFF1A0000),
                        Color(0xFFFF2200),
                        Color(0xFFFF8800),
                        Color(0xFFFFDD00),
                        Color(0xFFFF8800),
                        Color(0xFFFF2200),
                        Color(0xFF1A0000),
                      ],
                      stops: [0.0, 0.12, 0.25, 0.5, 0.75, 0.88, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // Fire ray painter
            IgnorePointer(
              child: CustomPaint(
                size: Size(s + 12, s + 12),
                painter: _FireRayPainter(phase: _ctrl.value),
              ),
            ),
            _CircleMask(size: s + 2),
            widget.child,
          ],
        );
      },
    );
  }
}

class _FireRayPainter extends CustomPainter {
  final double phase;
  const _FireRayPainter({required this.phase});
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    // 12 flame rays with jitter
    final rng = Random(42);
    for (int i = 0; i < 12; i++) {
      final a = (i / 12) * 2 * pi + phase * 2 * pi;
      final len = 5.0 + rng.nextDouble() * 6;
      final alpha = 0.3 + rng.nextDouble() * 0.5;
      final paint = Paint()
        ..color = const Color(0xFFFFAA00).withValues(alpha: alpha)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(c.dx + (r - 2) * cos(a), c.dy + (r - 2) * sin(a)),
        Offset(c.dx + (r + len) * cos(a), c.dy + (r + len) * sin(a)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FireRayPainter old) => old.phase != phase;
}
