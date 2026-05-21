import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Animated family crest with glow border and level indicator
class FamilyCrestWidget extends StatefulWidget {
  final String crestIcon;
  final Color themeColor;
  final int level;
  final double size;

  const FamilyCrestWidget({
    super.key, this.crestIcon = 'groups',
    this.themeColor = AppColors.purpleNeon, this.level = 1, this.size = 72,
  });

  @override
  State<FamilyCrestWidget> createState() => _FamilyCrestWidgetState();
}

class _FamilyCrestWidgetState extends State<FamilyCrestWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(duration: const Duration(seconds: 2), vsync: this)
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _glow.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, _) {
        final g = _glow.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: widget.size, height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  widget.themeColor.withValues(alpha: 0.2 + g * 0.1),
                  widget.themeColor.withValues(alpha: 0.05),
                ]),
                border: Border.all(
                  color: widget.themeColor.withValues(alpha: 0.5 + g * 0.2), width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(color: widget.themeColor.withValues(alpha: 0.2 + g * 0.15),
                    blurRadius: 15 + g * 10, spreadRadius: -2),
                ],
              ),
              child: Icon(Icons.groups, color: widget.themeColor, size: widget.size * 0.45),
            ),
            if (widget.level > 0) Positioned(
              bottom: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: widget.themeColor,
                  boxShadow: [BoxShadow(color: widget.themeColor.withValues(alpha: 0.4), blurRadius: 6)],
                ),
                child: Text('Lv.${widget.level}',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        );
      },
    );
  }
}
