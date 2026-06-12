import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Premium bottom navigation bar matching MAFIA AT CITY theme
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
      iconPath: 'assets/images/icons/navbar_icons/friends.png',
      label: 'Friends',
    ),
    (iconPath: 'assets/images/icons/navbar_icons/family.png', label: 'Family'),
    (iconPath: 'assets/images/icons/navbar_icons/store.png', label: 'Store'),
    (
      iconPath: 'assets/images/icons/navbar_icons/ranking.png',
      label: 'Rankings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, _) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          height: 75,
          decoration: ShapeDecoration(
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            shadows: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.15),
                blurRadius: 15,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipPath(
            clipper: ShapeBorderClipper(
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: ShapeDecoration(
                  color: const Color.fromARGB(
                    118,
                    42,
                    8,
                    69,
                  ).withValues(alpha: 0.1), // Purplish transparent glass
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: AppColors.gold.withValues(alpha: 0.8),
                      width: 0.8,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_tabs.length, (i) {
                    final bool isFriendsTab = _tabs[i].label == 'Friends';
                    return Expanded(
                      child: _NavTab(
                        iconPath: _tabs[i].iconPath,
                        label: _tabs[i].label,
                        isActive: widget.currentIndex == i,
                        glowValue: _glow.value,
                        hasBadge:
                            isFriendsTab && widget.friendsNotificationCount > 0,
                        onTap: () => widget.onTap(i),
                      ),
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
  final String iconPath;
  final String label;
  final bool isActive;
  final double glowValue;
  final bool hasBadge;
  final VoidCallback onTap;

  const _NavTab({
    required this.iconPath,
    required this.label,
    required this.isActive,
    required this.glowValue,
    this.hasBadge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppColors.gold
        : AppColors.gold.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                if (isActive)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.identity()
                      ..scaleByDouble(1.1, 1.1, 1.0, 1.0),
                    transformAlignment: Alignment.center,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Image.asset(
                        iconPath,
                        width: 28,
                        height: 28,
                        color: AppColors.gold.withValues(
                          alpha: 0.5 + glowValue * 0.3,
                        ),
                      ),
                    ),
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..scaleByDouble(
                      isActive ? 1.1 : 1.0,
                      isActive ? 1.1 : 1.0,
                      1.0,
                      1.0,
                    ),
                  transformAlignment: Alignment.center,
                  child: Image.asset(
                    iconPath,
                    width: 28,
                    height: 28,
                    color: color,
                  ),
                ),
                if (hasBadge)
                  Positioned(
                    top: -6,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF8A2BE2), // Purple badge
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF8A2BE2),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.priority_high,
                        color: Colors.white,
                        size: 12,
                        weight: 900,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                style: GoogleFonts.cinzel(
                  color: color,
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 1.2,
                  shadows: isActive
                      ? [
                          Shadow(
                            color: AppColors.gold.withValues(
                              alpha: 0.4 + glowValue * 0.3,
                            ),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
