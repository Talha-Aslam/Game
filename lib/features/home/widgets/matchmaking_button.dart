import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Massive cinematic matchmaking capsule button with mode toggle
class MatchmakingButton extends StatefulWidget {
  final VoidCallback? onPlay;
  final ValueChanged<int>? onModeChange;
  const MatchmakingButton({super.key, this.onPlay, this.onModeChange});

  @override
  State<MatchmakingButton> createState() => _MatchmakingButtonState();
}

class _MatchmakingButtonState extends State<MatchmakingButton>
    with TickerProviderStateMixin {
  late AnimationController _breathe;
  late AnimationController _ring;
  int _selectedMode = 0;

  static const _modes = ['RANKED', 'CUSTOM'];
  static const _modeIcons = [Icons.military_tech, Icons.tune];
  static const _modeColors = [AppColors.gold, AppColors.purpleGlow];

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);
    _ring = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _breathe.dispose();
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mode toggle
        _buildModeToggle(),
        const SizedBox(height: 14),
        // Main play button
        _buildPlayButton(),
      ],
    );
  }

  Widget _buildModeToggle() {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.white05,
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: List.generate(_modes.length, (i) {
          final isActive = _selectedMode == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedMode = i);
                widget.onModeChange?.call(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  color: isActive
                      ? _modeColors[i].withValues(alpha: 0.15)
                      : Colors.transparent,
                  border: Border.all(
                    color: isActive
                        ? _modeColors[i].withValues(alpha: 0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _modeIcons[i],
                          size: 12,
                          color: isActive ? _modeColors[i] : AppColors.white30,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _modes[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isActive
                                ? _modeColors[i]
                                : AppColors.white30,
                            fontSize: 8,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: widget.onPlay,
      child: AnimatedBuilder(
        animation: _breathe,
        builder: (_, _) {
          final b = _breathe.value;
          final scale = 1.0 + b * 0.02;
          final modeColor = _modeColors[_selectedMode];

          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipPath(
                    clipper: ShapeBorderClipper(
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        height: 64,
                        width: double.infinity,
                        decoration: ShapeDecoration(
                          color: modeColor.withValues(
                            alpha: 0.15,
                          ), // Glassy transparent
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: modeColor.withValues(alpha: 0.6 + b * 0.4),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 28,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _selectedMode == 0
                                  ? 'ENTER THE CITY'
                                  : _modes[_selectedMode],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
