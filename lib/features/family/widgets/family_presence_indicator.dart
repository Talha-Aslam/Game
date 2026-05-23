import 'package:flutter/material.dart';
import '../../../models/family_model.dart';

/// Activity status indicator with animated pulse
class FamilyPresenceIndicator extends StatefulWidget {
  final MemberActivity activity;
  final double size;
  const FamilyPresenceIndicator({super.key, required this.activity, this.size = 10});

  @override
  State<FamilyPresenceIndicator> createState() => _FamilyPresenceIndicatorState();
}

class _FamilyPresenceIndicatorState extends State<FamilyPresenceIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    if (widget.activity.isAvailable) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(FamilyPresenceIndicator old) {
    super.didUpdateWidget(old);
    if (widget.activity.isAvailable && !_pulse.isAnimating) _pulse.repeat(reverse: true);
    if (!widget.activity.isAvailable && _pulse.isAnimating) _pulse.stop();
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _pulse, builder: (_, _) {
      final p = widget.activity.isAvailable ? _pulse.value : 0.0;
      return Container(
        width: widget.size, height: widget.size,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: widget.activity.statusColor,
          boxShadow: widget.activity.isAvailable ? [BoxShadow(
            color: widget.activity.statusColor.withValues(alpha: 0.3 + p * 0.3),
            blurRadius: 4 + p * 4)] : null),
      );
    });
  }
}
