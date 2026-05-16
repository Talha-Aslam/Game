import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/social/friend_model.dart';

/// Animated pulsing online status indicator
class OnlineStatusIndicator extends StatefulWidget {
  final OnlineStatus status;
  final double size;
  final bool showLabel;

  const OnlineStatusIndicator({
    super.key,
    required this.status,
    this.size = 12,
    this.showLabel = false,
  });

  @override
  State<OnlineStatusIndicator> createState() => _OnlineStatusIndicatorState();
}

class _OnlineStatusIndicatorState extends State<OnlineStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    if (widget.status == OnlineStatus.online ||
        widget.status == OnlineStatus.inFamilyLobby) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(OnlineStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != oldWidget.status) {
      if (widget.status == OnlineStatus.online ||
          widget.status == OnlineStatus.inFamilyLobby) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.status) {
      case OnlineStatus.online:
      case OnlineStatus.inFamilyLobby:
        return AppColors.online;
      case OnlineStatus.inMatch:
        return AppColors.inGame;
      case OnlineStatus.busy:
      case OnlineStatus.doNotDisturb:
        return AppColors.crimsonRed;
      case OnlineStatus.offline:
        return AppColors.offline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = widget.status.isAvailable
                ? 1.0 + _pulseController.value * 0.3
                : 1.0;
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _statusColor,
                border: Border.all(
                  color: AppColors.background,
                  width: widget.size * 0.15,
                ),
                boxShadow: widget.status.isAvailable
                    ? [
                        BoxShadow(
                          color: _statusColor.withValues(alpha: 0.5 * scale),
                          blurRadius: 6 * scale,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            );
          },
        ),
        if (widget.showLabel) ...[
          const SizedBox(width: 6),
          Text(
            widget.status.displayName,
            style: TextStyle(
              color: _statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
