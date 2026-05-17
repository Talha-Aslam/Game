import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Premium glassmorphism bottom navigation bar with frosted blur
class BottomNavBarGlass extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int friendsNotificationCount; // Badge for friends tab

  const BottomNavBarGlass({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.friendsNotificationCount = 0,
  });

  @override
  State<BottomNavBarGlass> createState() => _BottomNavBarGlassState();
}

class _BottomNavBarGlassState extends State<BottomNavBarGlass>
    with SingleTickerProviderStateMixin {
  late AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  static const _tabs = [
    (
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Friends',
      color: AppColors.cyan,
    ),
    (
      icon: Icons.shield_outlined,
      activeIcon: Icons.shield,
      label: 'Family',
      color: AppColors.purpleGlow,
    ),
    (
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      label: 'Store',
      color: AppColors.gold,
    ),
    (
      icon: Icons.leaderboard_outlined,
      activeIcon: Icons.leaderboard,
      label: 'Rankings',
      color: AppColors.mintGreen,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: AppColors.white05,
                  border: Border.all(color: AppColors.glassBorder, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_tabs.length, (i) {
                    final bool isFriendsTab = _tabs[i].label == 'Friends';
                    return _NavTab(
                      icon: _tabs[i].icon,
                      activeIcon: _tabs[i].activeIcon,
                      label: _tabs[i].label,
                      color: _tabs[i].color,
                      isActive: widget.currentIndex == i,
                      glowValue: _glow.value,
                      badgeCount: isFriendsTab
                          ? widget.friendsNotificationCount
                          : 0,
                      onTap: () => widget.onTap(i),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final Color color;
  final bool isActive;
  final double glowValue;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
    required this.isActive,
    required this.glowValue,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()..scale(isActive ? 1.15 : 1.0),
                  transformAlignment: Alignment.center,
                  child: Icon(
                    isActive ? activeIcon : icon,
                    color: isActive ? color : AppColors.white30,
                    size: 22,
                    shadows: isActive
                        ? [
                            Shadow(
                              color: color.withValues(
                                alpha: 0.4 + glowValue * 0.2,
                              ),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent,
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        badgeCount > 9 ? '9+' : badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? color : AppColors.white30,
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
