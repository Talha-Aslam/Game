import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Shatter animation for player elimination — triangle shards scatter outward
class EliminationAnimation extends StatefulWidget {
  final bool isEliminating;
  final double size;
  final Widget child;

  const EliminationAnimation({
    super.key,
    required this.isEliminating,
    this.size = 52,
    required this.child,
  });

  @override
  State<EliminationAnimation> createState() => _EliminationAnimationState();
}

class _EliminationAnimationState extends State<EliminationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _shatter;
  late List<_Shard> _shards;
  final _rng = Random();
  bool _showShards = false;

  @override
  void initState() {
    super.initState();
    _shatter = AnimationController(
      duration: const Duration(milliseconds: 1200), vsync: this);
    _shards = _generateShards();
    _shatter.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showShards = false);
      }
    });
  }

  @override
  void didUpdateWidget(EliminationAnimation old) {
    super.didUpdateWidget(old);
    if (widget.isEliminating && !old.isEliminating) {
      setState(() {
        _shards = _generateShards();
        _showShards = true;
      });
      _shatter.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shatter.dispose();
    super.dispose();
  }

  List<_Shard> _generateShards() {
    return List.generate(12, (i) {
      final angle = (2 * pi * i / 12) + _rng.nextDouble() * 0.5;
      return _Shard(
        angle: angle,
        speed: 80 + _rng.nextDouble() * 120,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 8,
        size: 6 + _rng.nextDouble() * 10,
        color: [
          AppColors.crimsonRed,
          AppColors.purpleNeon,
          AppColors.gold,
          AppColors.crimsonDeep,
        ][_rng.nextInt(4)],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_showShards && !widget.isEliminating) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _shatter,
      builder: (_, __) {
        final t = Curves.easeOut.transform(_shatter.value);
        final opacity = (1.0 - t).clamp(0.0, 1.0);

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Original child fading out
            Opacity(
              opacity: widget.isEliminating ? (1.0 - t * 2).clamp(0.0, 1.0) : 1.0,
              child: widget.child,
            ),
            // Shard particles
            if (_showShards)
              ..._shards.map((shard) {
                final dx = cos(shard.angle) * shard.speed * t;
                final dy = sin(shard.angle) * shard.speed * t;
                final rotation = shard.rotationSpeed * t;

                return Positioned(
                  left: widget.size / 2 + dx - shard.size / 2,
                  top: widget.size / 2 + dy - shard.size / 2,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.rotate(
                      angle: rotation,
                      child: CustomPaint(
                        size: Size(shard.size, shard.size),
                        painter: _ShardPainter(color: shard.color),
                      ),
                    ),
                  ),
                );
              }),
            // Red flash
            if (_showShards && t < 0.3)
              Container(
                width: widget.size + 20,
                height: widget.size + 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.crimsonRed.withValues(alpha: (0.5 - t * 1.5).clamp(0.0, 0.5)),
                      blurRadius: 30,
                      spreadRadius: 10),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Shard {
  final double angle;
  final double speed;
  final double rotationSpeed;
  final double size;
  final Color color;

  _Shard({
    required this.angle,
    required this.speed,
    required this.rotationSpeed,
    required this.size,
    required this.color,
  });
}

class _ShardPainter extends CustomPainter {
  final Color color;
  _ShardPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height * 0.7)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ShardPainter old) => old.color != color;
}
