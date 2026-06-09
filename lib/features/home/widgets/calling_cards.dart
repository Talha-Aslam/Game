import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CARD 1: "Neon Overdrive" (Cyberpunk / Hacker Theme)
// ─────────────────────────────────────────────────────────────────────────────
class CallingCardNeonOverdrive extends StatelessWidget {
  final Widget? child;
  const CallingCardNeonOverdrive({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0221),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.12),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _NeonGridPainter())),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.transparent, width: 1.5),
                gradient: LinearGradient(
                  colors: [Colors.cyanAccent, Colors.pinkAccent],
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0221).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20.5),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeonGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i - 40, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD 2: "Syndicate Executive" (Gold / Luxury Mafia Theme)
// ─────────────────────────────────────────────────────────────────────────────
class CallingCardSyndicateExecutive extends StatelessWidget {
  final Widget? child;
  const CallingCardSyndicateExecutive({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A), Color(0xFF121212)],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
            blurRadius: 25,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.transparent, width: 2.0),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFD4AF37),
                  Color(0xFFFFFDD0),
                  Color(0xFF996515),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          ),
          IgnorePointer(
            child: Opacity(
              opacity: 0.02,
              child: CustomPaint(painter: _CarbonFiberPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarbonFiberPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (double i = 0; i < size.width; i += 4) {
      for (double j = 0; j < size.height; j += 4) {
        if ((i + j) % 8 == 0) canvas.drawRect(Rect.fromLTWH(i, j, 2, 2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD 3: "Crimson Vendetta" (Tactical / Bloodlust Theme)
// ─────────────────────────────────────────────────────────────────────────────
class CallingCardCrimsonVendetta extends StatelessWidget {
  final Widget? child;
  const CallingCardCrimsonVendetta({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _TacticalStripePainter()),
            ),
            Positioned.fill(
              child: CustomPaint(painter: _HazardBracketPainter()),
            ),
            if (child != null) Positioned.fill(child: child!),
          ],
        ),
      ),
    );
  }
}

class _TacticalStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.05)
      ..strokeWidth = 10;
    for (double i = -50; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i + 60, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

class _HazardBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.6)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    const len = 35.0;
    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, 0)
        ..lineTo(len, 0),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - len)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width - len, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD 4: "Cosmic Shadow" (Abyss / Nebula Theme)
// ─────────────────────────────────────────────────────────────────────────────
class CallingCardCosmicShadow extends StatelessWidget {
  final Widget? child;
  const CallingCardCosmicShadow({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const RadialGradient(
          center: Alignment(0.6, -0.4),
          radius: 1.4,
          colors: [Color(0xFF2E1A47), Color(0xFF0B0B1A)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurpleAccent.withValues(alpha: 0.3),
            blurRadius: 30,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.0),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.white.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            const Positioned.fill(child: _StarField()),
            if (child != null) Positioned.fill(child: child!),
          ],
        ),
      ),
    );
  }
}

class _StarField extends StatelessWidget {
  const _StarField();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StarPainter());
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.4);
    for (int i = 0; i < 40; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 1.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD 5: "Toxic Underworld" (Radioactive / Biohazard Theme)
// ─────────────────────────────────────────────────────────────────────────────
class CallingCardToxicUnderworld extends StatelessWidget {
  final Widget? child;
  const CallingCardToxicUnderworld({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: _ToxicClipper(),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF333333), Color(0xFF1A1A1A)],
              ),
            ),
            child: CustomPaint(painter: _ToxicHexPainter(), child: child),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _ToxicBorderPainter()),
          ),
        ),
      ],
    );
  }
}

class _ToxicClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(20, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - 20)
      ..lineTo(size.width - 20, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, 20)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper old) => false;
}

class _ToxicHexPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF39FF14).withValues(alpha: 0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (double i = 0; i < size.width + 30; i += 30) {
      for (double j = 0; j < size.height + 30; j += 30) {
        canvas.drawCircle(Offset(i, j), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

class _ToxicBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = _ToxicClipper().getClip(size);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF39FF14).withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF39FF14).withValues(alpha: 0.8)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}
