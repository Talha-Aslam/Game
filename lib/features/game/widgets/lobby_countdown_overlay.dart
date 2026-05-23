import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/neon_text.dart';

/// Cinematic lobby countdown: 10→0, ticking at ≤5s, "The Show Begins." at 0
class LobbyCountdownOverlay extends StatefulWidget {
  final int countdown;
  final bool tickingActive;
  final bool showBeginsCinematic;

  const LobbyCountdownOverlay({
    super.key,
    required this.countdown,
    this.tickingActive = false,
    this.showBeginsCinematic = false,
  });

  @override
  State<LobbyCountdownOverlay> createState() => _LobbyCountdownOverlayState();
}

class _LobbyCountdownOverlayState extends State<LobbyCountdownOverlay>
    with TickerProviderStateMixin {
  late AnimationController _tickPulse;
  late AnimationController _showBeginsReveal;
  late AnimationController _numberPop;

  @override
  void initState() {
    super.initState();
    _tickPulse = AnimationController(
      duration: const Duration(milliseconds: 500), vsync: this)
      ..repeat(reverse: true);
    _showBeginsReveal = AnimationController(
      duration: const Duration(milliseconds: 1500), vsync: this);
    _numberPop = AnimationController(
      duration: const Duration(milliseconds: 300), vsync: this);
  }

  @override
  void didUpdateWidget(LobbyCountdownOverlay old) {
    super.didUpdateWidget(old);
    if (widget.showBeginsCinematic && !old.showBeginsCinematic) {
      _showBeginsReveal.forward(from: 0);
    }
    // Pop animation on each countdown tick
    if (widget.countdown != old.countdown && widget.countdown > 0) {
      _numberPop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _tickPulse.dispose();
    _showBeginsReveal.dispose();
    _numberPop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showBeginsCinematic) {
      return _buildShowBegins();
    }

    if (widget.countdown <= 0) return const SizedBox.shrink();

    return _buildCountdown();
  }

  Widget _buildCountdown() {
    final isUrgent = widget.tickingActive;
    final color = isUrgent ? AppColors.crimsonRed : AppColors.gold;

    return AnimatedBuilder(
      animation: Listenable.merge([_tickPulse, _numberPop]),
      builder: (_, _) {
        final tickScale = isUrgent ? 1.0 + _tickPulse.value * 0.06 : 1.0;
        final popScale = 1.0 + (1.0 - _numberPop.value) * 0.15;
        final combinedScale = tickScale * (widget.countdown <= 5 ? popScale : 1.0);

        return IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: isUrgent ? 0.15 : 0.05),
                ],
                radius: 0.8,
              ),
            ),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // "Match starts in" label
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: widget.countdown > 5 ? 0.6 : 0.8,
                  child: Text('MATCH STARTS IN',
                    style: TextStyle(
                      color: color.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3)),
                ),
                const SizedBox(height: 8),
                // Big countdown number
                Transform.scale(
                  scale: combinedScale,
                  child: Text(
                    '${widget.countdown}',
                    style: GoogleFonts.outfit(
                      fontSize: isUrgent ? 72 : 60,
                      fontWeight: FontWeight.w900,
                      color: color,
                      shadows: [
                        Shadow(
                          color: color.withValues(alpha: isUrgent ? 0.6 : 0.3),
                          blurRadius: isUrgent ? 30 : 12),
                        if (isUrgent)
                          Shadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 50),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Ticking indicator
                if (isUrgent)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _tickPulse.value,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.timer,
                        color: AppColors.crimsonRed.withValues(alpha: 0.6), size: 14),
                      const SizedBox(width: 4),
                      Text('TICK',
                        style: TextStyle(
                          color: AppColors.crimsonRed.withValues(alpha: 0.6),
                          fontSize: 10, fontWeight: FontWeight.w800,
                          letterSpacing: 4)),
                    ]),
                  ),
                // Open mic indicator
                if (!isUrgent)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.mic,
                      color: AppColors.mintGreen.withValues(alpha: 0.5), size: 12),
                    const SizedBox(width: 4),
                    Text('Open microphones — talk freely',
                      style: TextStyle(
                        color: AppColors.white30, fontSize: 9)),
                  ]),
              ]),
            ),
          ),
        );
      },
    );
  }

  /// "The Show Begins." cinematic text
  Widget _buildShowBegins() {
    return AnimatedBuilder(
      animation: _showBeginsReveal,
      builder: (_, _) {
        final t = Curves.easeOutCubic.transform(
          _showBeginsReveal.value.clamp(0.0, 1.0));
        final fadeOut = _showBeginsReveal.value > 0.7
            ? 1.0 - ((_showBeginsReveal.value - 0.7) / 0.3)
            : 1.0;

        return IgnorePointer(
          child: Container(
            color: Colors.black.withValues(alpha: 0.6 * fadeOut),
            child: Center(
              child: Opacity(
                opacity: (t * fadeOut).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.8 + t * 0.2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 20 * fadeOut, sigmaY: 20 * fadeOut),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.2 * fadeOut)),
                        ),
                        child: NeonText(
                          text: 'The Show Begins.',
                          fontSize: 28,
                          color: AppColors.gold,
                          glowRadius: 20 + t * 10,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
