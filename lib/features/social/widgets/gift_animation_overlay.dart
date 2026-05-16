import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/social/popularity_model.dart';

/// Full-screen gift animation overlay
class GiftAnimationOverlay extends StatefulWidget {
  final PopularityGift gift;
  final String senderName;
  final VoidCallback onComplete;

  const GiftAnimationOverlay({
    super.key,
    required this.gift,
    required this.senderName,
    required this.onComplete,
  });

  /// Show the gift animation as an overlay
  static void show(
    BuildContext context, {
    required PopularityGift gift,
    required String senderName,
  }) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => GiftAnimationOverlay(
        gift: gift,
        senderName: senderName,
        onComplete: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
  }

  @override
  State<GiftAnimationOverlay> createState() => _GiftAnimationOverlayState();
}

class _GiftAnimationOverlayState extends State<GiftAnimationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _glowAnim;
  final _rng = Random();
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeOut));

    _fadeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_mainController);

    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    // Generate particles
    _particles = List.generate(20, (_) => _Particle(
      dx: _rng.nextDouble() * 2 - 1,
      dy: -_rng.nextDouble() * 2 - 0.5,
      size: 3 + _rng.nextDouble() * 5,
      speed: 0.5 + _rng.nextDouble(),
    ));

    _mainController.forward();
    _particleController.repeat();

    // Auto dismiss
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final giftColor = widget.gift.color;

    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _particleController]),
      builder: (context, _) {
        return Material(
          color: Colors.transparent,
          child: Container(
            color: Colors.black.withValues(alpha: 0.6 * _fadeAnim.value),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gift icon with glow
                  Transform.scale(
                    scale: _scaleAnim.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow burst
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: giftColor.withValues(
                                  alpha: 0.4 * _glowAnim.value,
                                ),
                                blurRadius: 60 + _glowAnim.value * 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        // Particles
                        ..._buildParticles(giftColor),
                        // Main icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                giftColor.withValues(alpha: 0.3),
                                giftColor.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                          child: Icon(
                            widget.gift.icon,
                            color: giftColor,
                            size: 56,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Gift name
                  Opacity(
                    opacity: _fadeAnim.value,
                    child: Text(
                      widget.gift.name,
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: giftColor,
                        shadows: [
                          Shadow(
                            color: giftColor.withValues(alpha: 0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: _fadeAnim.value,
                    child: Text(
                      'from ${widget.senderName}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Opacity(
                    opacity: _fadeAnim.value,
                    child: Text(
                      '+${widget.gift.value} Popularity',
                      style: TextStyle(
                        color: giftColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildParticles(Color color) {
    return _particles.map((p) {
      final progress = _particleController.value;
      final x = p.dx * 80 * progress * p.speed;
      final y = p.dy * 120 * progress * p.speed;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      return Transform.translate(
        offset: Offset(x, y),
        child: Opacity(
          opacity: opacity * _fadeAnim.value,
          child: Container(
            width: p.size,
            height: p.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: p.size * 2,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _Particle {
  final double dx;
  final double dy;
  final double size;
  final double speed;
  const _Particle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.speed,
  });
}
