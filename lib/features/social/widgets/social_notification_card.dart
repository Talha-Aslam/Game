import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/social/social_notification_model.dart';

/// Cinematic social notification card
class SocialNotificationCard extends StatelessWidget {
  final SocialNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const SocialNotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  Color get _typeColor {
    switch (notification.type) {
      case SocialNotificationType.friendOnline:
        return AppColors.online;
      case SocialNotificationType.friendRequest:
        return AppColors.cyan;
      case SocialNotificationType.familyInvite:
        return AppColors.purpleNeon;
      case SocialNotificationType.letsPlay:
        return AppColors.mintGreen;
      case SocialNotificationType.giftReceived:
        return AppColors.gold;
      case SocialNotificationType.matchReady:
        return AppColors.crimsonRed;
      case SocialNotificationType.seasonalEvent:
        return AppColors.gold;
    }
  }

  IconData get _typeIcon {
    switch (notification.type) {
      case SocialNotificationType.friendOnline:
        return Icons.circle;
      case SocialNotificationType.friendRequest:
        return Icons.person_add;
      case SocialNotificationType.familyInvite:
        return Icons.shield;
      case SocialNotificationType.letsPlay:
        return Icons.sports_esports;
      case SocialNotificationType.giftReceived:
        return Icons.card_giftcard;
      case SocialNotificationType.matchReady:
        return Icons.play_circle;
      case SocialNotificationType.seasonalEvent:
        return Icons.celebration;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: AppColors.crimsonRed),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: notification.isRead
                ? AppColors.white05
                : _typeColor.withValues(alpha: 0.06),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.glassBorder
                  : _typeColor.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _typeColor.withValues(alpha: 0.12),
                  border: Border.all(color: _typeColor.withValues(alpha: 0.3)),
                ),
                child: Icon(_typeIcon, color: _typeColor, size: 18),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: notification.isRead
                            ? AppColors.white50
                            : AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.body,
                      style: AppTextStyles.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Timestamp
              Text(
                _formatTime(notification.timestamp),
                style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
              ),
              if (!notification.isRead) ...[
                const SizedBox(width: 6),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _typeColor,
                    boxShadow: [
                      BoxShadow(
                        color: _typeColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
