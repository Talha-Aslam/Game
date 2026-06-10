import 'dart:math';
import 'package:flutter/material.dart';

/// Style enum for premium avatar borders
enum PremiumBorderStyle {
  none,
  neonOverdrive,
  syndicateBoss,
  crimsonVendetta,
  cosmicVoid,
  radioactiveUnderworld,
}

/// Unified wrapper for premium animated avatar borders
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
        return _NeonOverdriveBorder(radius: radius, child: child);
      case 'b2':
        return _SyndicateBossBorder(radius: radius, child: child);
      case 'b3':
        return _CrimsonVendettaBorder(radius: radius, child: child);
      case 'b4':
        return _CosmicVoidBorder(radius: radius, child: child);
      case 'b5':
        return _RadioactiveUnderworldBorder(radius: radius, child: child);
      default:
        return child;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BORDER 1: "Neon Overdrive" (Cyberpunk Spin)
// ─────────────────────────────────────────────────────────────────────────────
class _NeonOverdriveBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _NeonOverdriveBorder({required this.child, required this.radius});

  @override
  State<_NeonOverdriveBorder> createState() => _NeonOverdriveBorderState();
}

class _NeonOverdriveBorderState extends State<_NeonOverdriveBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2;
    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          child: RotationTransition(
            turns: _controller,
            child: Container(
              width: size + 6,
              height: size + 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Colors.cyanAccent,
                    Colors.pinkAccent,
                    Colors.deepPurpleAccent,
                    Colors.cyanAccent,
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),
        ),
        // Mask to keep center clear
        IgnorePointer(
          child: Container(
            width: size + 1,
            height: size + 1,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Child (Avatar)
        widget.child,
        // Glow Overlay
        IgnorePointer(
          child: Container(
            width: size + 8,
            height: size + 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BORDER 2: "Syndicate Boss" (Royal Gold VIP)
// ─────────────────────────────────────────────────────────────────────────────
class _SyndicateBossBorder extends StatelessWidget {
  final Widget child;
  final double radius;
  const _SyndicateBossBorder({required this.child, required this.radius});

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 1.02),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, scale, _) {
        return Transform.scale(
          scale: scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              IgnorePointer(
                child: Container(
                  width: size + 8,
                  height: size + 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFD4AF37), // Gold
                        Color(0xFFFFFDD0), // Cream
                        Color(0xFF996515), // Bronze
                        Color(0xFFD4AF37),
                      ],
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: Container(
                  width: size + 2,
                  height: size + 2,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A0A0A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              child,
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BORDER 3: "Crimson Vendetta" (Bloodlust / Danger)
// ─────────────────────────────────────────────────────────────────────────────
class _CrimsonVendettaBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _CrimsonVendettaBorder({required this.child, required this.radius});

  @override
  State<_CrimsonVendettaBorder> createState() => _CrimsonVendettaBorderState();
}

class _CrimsonVendettaBorderState extends State<_CrimsonVendettaBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.1, end: 0.5).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2;
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IgnorePointer(
              child: Container(
                width: size + 6,
                height: size + 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withValues(alpha: _glow.value),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ],
                  gradient: const SweepGradient(
                    colors: [
                      Colors.black,
                      Color(0xFF8B0000),
                      Colors.redAccent,
                      Color(0xFF8B0000),
                      Colors.black,
                    ],
                    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
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

// ─────────────────────────────────────────────────────────────────────────────
// BORDER 4: "Cosmic Void" (Ethereal / Galactic)
// ─────────────────────────────────────────────────────────────────────────────
class _CosmicVoidBorder extends StatelessWidget {
  final Widget child;
  final double radius;
  const _CosmicVoidBorder({required this.child, required this.radius});

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Aura
        IgnorePointer(
          child: Container(
            width: size + 10,
            height: size + 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.4),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ),
        // Main Ring
        IgnorePointer(
          child: Container(
            width: size + 6,
            height: size + 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Color(0xFF001220),
                  Color(0xFF4B0082),
                  Color(0xFF9B59FF),
                  Color(0xFF001220),
                ],
              ),
            ),
          ),
        ),
        // Starlight Dotted Ring
        IgnorePointer(
          child: CustomPaint(
            size: Size(size + 8, size + 8),
            painter: _DottedStarPainter(),
          ),
        ),
        // Child
        child,
      ],
    );
  }
}

class _DottedStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < 360; i += 15) {
      final angle = i * pi / 180;
      canvas.drawCircle(
        Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)),
        0.8,
        paint,
      );
    }
  }
  @override
  bool shouldRepaint(CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// BORDER 5: "Radioactive Underworld" (Toxic / Biohazard)
// ─────────────────────────────────────────────────────────────────────────────
class _RadioactiveUnderworldBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  const _RadioactiveUnderworldBorder({required this.child, required this.radius});

  @override
  State<_RadioactiveUnderworldBorder> createState() =>
      _RadioactiveUnderworldBorderState();
}

class _RadioactiveUnderworldBorderState
    extends State<_RadioactiveUnderworldBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final blur = 4.0 + (sin(_controller.value * pi * 2).abs() * 8.0);
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer Radioactive Glow
            IgnorePointer(
              child: Container(
                width: size + 8,
                height: size + 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF39FF14).withValues(alpha: 0.3),
                      blurRadius: blur,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            // Rotating Segment
            IgnorePointer(
              child: RotationTransition(
                turns: _controller,
                child: Container(
                  width: size + 6,
                  height: size + 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xFF39FF14),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.1, 0.2],
                    ),
                  ),
                ),
              ),
            ),
            // Static Thin Ring
            IgnorePointer(
              child: Container(
                width: size + 4,
                height: size + 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF39FF14).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Avatar
            widget.child,
          ],
        );
      },
    );
  }
}
