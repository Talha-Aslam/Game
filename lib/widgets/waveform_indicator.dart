import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Audio waveform bars for voice activity indicator
class WaveformIndicator extends StatefulWidget {
  final bool isActive;
  final Color color;
  final int barCount;
  final double width;
  final double height;

  const WaveformIndicator({
    super.key,
    this.isActive = false,
    this.color = AppColors.cyan,
    this.barCount = 5,
    this.width = 30,
    this.height = 16,
  });

  @override
  State<WaveformIndicator> createState() => _WaveformIndicatorState();
}

class _WaveformIndicatorState extends State<WaveformIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.barCount, (i) {
              final phase = i / widget.barCount;
              final value = widget.isActive
                  ? (sin((_controller.value + phase) * pi) + 1) / 2
                  : 0.15;
              return Container(
                width: widget.width / (widget.barCount * 2),
                height: widget.height * value.clamp(0.15, 1.0),
                decoration: BoxDecoration(
                  color: widget.color.withValues(
                    alpha: widget.isActive ? 0.8 : 0.2,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
