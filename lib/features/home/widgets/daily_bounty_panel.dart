import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Floating daily missions/bounty panel
class DailyBountyPanel extends StatefulWidget {
  const DailyBountyPanel({super.key});
  @override
  State<DailyBountyPanel> createState() => _DailyBountyPanelState();
}

class _DailyBountyPanelState extends State<DailyBountyPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  bool _expanded = false;

  static final _missions = [
    _Mission(
      'Survive 1 night',
      Icons.dark_mode,
      2,
      3,
      100,
      AppColors.purpleGlow,
    ),
    _Mission(
      'Win a Ranked match',
      Icons.military_tech,
      1,
      2,
      200,
      AppColors.gold,
    ),
    _Mission(
      'Vote out 3 Mafia',
      Icons.how_to_vote,
      1,
      3,
      150,
      AppColors.crimsonRed,
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    final completedCount = _missions.where((m) => m.current >= m.total).length;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        return GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                padding: EdgeInsets.all(_expanded ? 10 : 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.white05,
                  border: Border.all(
                    color: completedCount > 0
                        ? AppColors.gold.withValues(
                            alpha: 0.25 + _pulse.value * 0.1,
                          )
                        : AppColors.glassBorder,
                    width: 0.5,
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
                    width: 26,
                    height: 38,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildCollapsed(completedCount),
                      ),
                    ),
                  ),
                  secondChild: SizedBox(
                    width: 260,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(width: 260, child: _buildExpanded()),
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

  Widget _buildExpanded() {
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
        ..._missions.map((m) {
          final done = m.current >= m.total;
          final progress = (m.current / m.total).clamp(0.0, 1.0);
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: done
                  ? AppColors.gold.withValues(alpha: 0.06)
                  : AppColors.white05,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      m.icon,
                      color: done ? AppColors.gold : m.color,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        m.label,
                        style: TextStyle(
                          color: done ? AppColors.gold : AppColors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
                              color: done ? AppColors.gold : m.color,
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
                        color: done ? AppColors.gold : AppColors.white30,
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Mission {
  final String label;
  final IconData icon;
  final int current, total, xp;
  final Color color;
  _Mission(
    this.label,
    this.icon,
    this.current,
    this.total,
    this.xp,
    this.color,
  );
}
