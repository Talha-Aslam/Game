import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/social_provider.dart';
import '../../../providers/notification_provider.dart';

/// Enhanced Friends menu card with glow, online count, and notification badges
class FriendsMenuCard extends ConsumerStatefulWidget {
  final VoidCallback? onTap;
  const FriendsMenuCard({super.key, this.onTap});

  @override
  ConsumerState<FriendsMenuCard> createState() => _FriendsMenuCardState();
}

class _FriendsMenuCardState extends ConsumerState<FriendsMenuCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onlineCount = ref.watch(onlineFriendCountProvider);
    final hasNotifications = ref.watch(hasNotificationsProvider);
    final hasInvites = ref.watch(hasActiveInvitesProvider);
    final pendingCount = ref.watch(pendingRequestCountProvider);
    final shouldGlow = hasNotifications || hasInvites;

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        final glowValue = shouldGlow ? _glowController.value : 0.0;
        final glowColor = hasInvites ? AppColors.cyan : AppColors.mintGreen;

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: glowColor.withValues(alpha: 0.04 + glowValue * 0.04),
              border: Border.all(
                color: shouldGlow
                    ? glowColor.withValues(alpha: 0.3 + glowValue * 0.2)
                    : AppColors.cyan.withValues(alpha: 0.2),
              ),
              boxShadow: shouldGlow
                  ? [
                      BoxShadow(
                        color: glowColor.withValues(
                          alpha: 0.1 + glowValue * 0.1,
                        ),
                        blurRadius: 15 + glowValue * 10,
                        spreadRadius: -2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.cyan.withValues(alpha: 0.05),
                        blurRadius: 15,
                      ),
                    ],
            ),
            child: Stack(
              children: [
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon with badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.cyan.withValues(alpha: 0.12),
                              border: Border.all(
                                color: AppColors.cyan.withValues(
                                  alpha: 0.3 + glowValue * 0.15,
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.people,
                              color: AppColors.cyan.withValues(
                                alpha: 0.8 + glowValue * 0.2,
                              ),
                              size: 22,
                            ),
                          ),
                          // Notification badge
                          if (pendingCount > 0)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.crimsonRed,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.crimsonRed
                                          .withValues(alpha: 0.5),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '$pendingCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Friends',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.cyan,
                        ),
                      ),
                    ],
                  ),
                ),
                // Online count pill
                if (onlineCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.online.withValues(alpha: 0.15),
                        border: Border.all(
                          color: AppColors.online.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.online,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$onlineCount',
                            style: const TextStyle(
                              color: AppColors.online,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
