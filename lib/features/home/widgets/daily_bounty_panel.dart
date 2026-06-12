import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/bounty_provider.dart';
import '../../../models/bounty_model.dart';

/// Floating daily missions/bounty panel
class DailyBountyPanel extends ConsumerStatefulWidget {
  const DailyBountyPanel({super.key});
  @override
  ConsumerState<DailyBountyPanel> createState() => _DailyBountyPanelState();
}

class _DailyBountyPanelState extends ConsumerState<DailyBountyPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'trophy':
        return Icons.emoji_events;
      case 'shield':
        return Icons.shield;
      case 'target':
        return Icons.my_location;
      case 'gamepad':
        return Icons.gamepad;
      case 'medical_services':
        return Icons.medical_services;
      default:
        return Icons.task_alt;
    }
  }

  Color _getColor(String iconName) {
    switch (iconName) {
      case 'trophy':
        return AppColors.gold;
      case 'shield':
        return AppColors.purpleGlow;
      case 'target':
        return AppColors.crimsonRed;
      case 'gamepad':
        return AppColors.cyan;
      case 'medical_services':
        return Colors.greenAccent;
      default:
        return AppColors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bountiesState = ref.watch(bountiesProvider);

    return bountiesState.when(
      data: (bounties) {
        if (bounties.isEmpty) return const SizedBox.shrink();
        final completedCount = bounties.where((m) => m.isCompleted).length;

        return AnimatedBuilder(
          animation: _pulse,
          builder: (_, _) {
            return GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipPath(
                    clipper: ShapeBorderClipper(
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.all(_expanded ? 12 : 10),
                        decoration: ShapeDecoration(
                          color: const Color(0xFF2A0845).withValues(alpha: 0.6),
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: completedCount > 0
                                  ? AppColors.gold.withValues(
                                      alpha: 0.6 + _pulse.value * 0.4,
                                    )
                                  : AppColors.gold.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: _expanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          sizeCurve: Curves.easeOut,
                          firstCurve: Curves.easeOut,
                          secondCurve: Curves.easeIn,
                          alignment: Alignment.topCenter,
                          firstChild: SizedBox(
                            width: 28,
                            height: 28,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: _buildCollapsed(completedCount),
                              ),
                            ),
                          ),
                          secondChild: SizedBox(
                            width: 260,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: 260,
                                child: _buildExpanded(bounties),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Top Flare
                  Positioned(
                    top: -1,
                    left: 0,
                    right: 0,
                    child: Center(child: _buildFlare(_pulse.value)),
                  ),
                  // Bottom Flare
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    child: Center(child: _buildFlare(_pulse.value)),
                  ),
                  // Left Flare
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: -1,
                    child: Center(child: _buildFlare(_pulse.value)),
                  ),
                  // Right Flare
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: -1,
                    child: Center(child: _buildFlare(_pulse.value)),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildFlare(double pulse) {
    return Transform.rotate(
      angle: 3.14159 / 4,
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD500F9), // Glowing purple/magenta
              blurRadius: 6 + (pulse * 6),
              spreadRadius: 1 + (pulse * 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsed(int completed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.assignment,
          color: completed > 0 ? AppColors.gold : AppColors.white30,
          size: 20,
        ),
        if (completed > 0) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: AppColors.gold.withValues(alpha: 0.15),
            ),
            child: Text(
              '$completed',
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExpanded(List<BountyModel> bounties) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text(
              'DAILY BOUNTIES',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Icon(Icons.close, color: AppColors.white30, size: 14),
          ],
        ),
        const SizedBox(height: 6),
        ...bounties.map((m) {
          final isClaimed = m.isClaimed;
          final isCompleted = m.isCompleted;
          final progress = (m.current / m.total).clamp(0.0, 1.0);
          final iconData = _getIcon(m.icon);
          final mColor = _getColor(m.icon);

          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isCompleted && !isClaimed
                  ? AppColors.gold.withValues(alpha: 0.06)
                  : AppColors.white05,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      iconData,
                      color: isCompleted ? AppColors.gold : mColor,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        m.description,
                        style: TextStyle(
                          color: isCompleted
                              ? AppColors.gold
                              : AppColors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          decoration: isClaimed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCompleted && !isClaimed)
                      GestureDetector(
                        onTap: () {
                          ref.read(bountiesProvider.notifier).claimBounty(m.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'CLAIM',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    else if (isClaimed)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.white30,
                        size: 12,
                      ),
                  ],
                ),
                if (!isClaimed) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1.5),
                            color: AppColors.white05,
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1.5),
                                color: isCompleted ? AppColors.gold : mColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${m.current}/${m.total}',
                        style: const TextStyle(
                          color: AppColors.white30,
                          fontSize: 7,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${m.xp}XP',
                        style: TextStyle(
                          color: isCompleted
                              ? AppColors.gold
                              : AppColors.white30,
                          fontSize: 7,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}
