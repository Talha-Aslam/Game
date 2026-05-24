import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/social/friend_model.dart';
import '../../../widgets/rank_badge.dart';
import 'online_status_indicator.dart';
import 'popularity_badge_widget.dart';

/// Premium glassmorphic friend card with actions
class FriendCardWidget extends StatelessWidget {
  final FriendModel friend;
  final VoidCallback? onInvite;
  final VoidCallback? onMessage;
  final VoidCallback? onViewProfile;
  final VoidCallback? onSendPopularity;
  final VoidCallback? onAddFriend;
  final VoidCallback? onRemove;
  final bool showActions;
  final bool showAddFriend;

  const FriendCardWidget({
    super.key,
    required this.friend,
    this.onInvite,
    this.onMessage,
    this.onViewProfile,
    this.onSendPopularity,
    this.onAddFriend,
    this.onRemove,
    this.showActions = true,
    this.showAddFriend = false,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = friend.isOnline;
    final borderColor = isOnline
        ? AppColors.online.withValues(alpha: 0.3)
        : AppColors.glassBorder;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.glassBackground,
        border: Border.all(color: borderColor),
        boxShadow: isOnline
            ? [
                BoxShadow(
                  color: AppColors.online.withValues(alpha: 0.06),
                  blurRadius: 15,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Main row: avatar + info
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(child: _buildInfo()),
              if (friend.popularityScore > 0)
                PopularityBadgeWidget(
                  score: friend.popularityScore,
                  compact: true,
                ),
            ],
          ),
          // Action buttons
          if (showActions || showAddFriend) ...[
            const SizedBox(height: 10),
            _buildActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceLight,
            border: Border.all(
              color: friend.isOnline
                  ? AppColors.online.withValues(alpha: 0.5)
                  : AppColors.glassBorder,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              friend.username.isNotEmpty
                  ? friend.username[0].toUpperCase()
                  : '?',
              style: AppTextStyles.headlineSmall.copyWith(
                color: friend.isOnline ? AppColors.online : AppColors.white50,
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: OnlineStatusIndicator(
            status: friend.onlineStatus,
            size: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                friend.username,
                style: AppTextStyles.labelLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (friend.familyTag != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.purpleNeon.withValues(alpha: 0.15),
                ),
                child: Text(
                  friend.familyTag!,
                  style: const TextStyle(
                    color: AppColors.purpleGlow,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            RankBadge(tier: friend.rankTier, size: 14, showLabel: false),
            const SizedBox(width: 4),
            Text(
              friend.rankName,
              style: AppTextStyles.labelSmall,
            ),
            const SizedBox(width: 8),
            Text(
              '• ${friend.statusText}',
              style: TextStyle(
                color: friend.isOnline
                    ? AppColors.online.withValues(alpha: 0.8)
                    : AppColors.white30,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    if (showAddFriend) {
      return Row(
        children: [
          _ActionChip(
            icon: Icons.person_add,
            label: 'Add Friend',
            color: AppColors.cyan,
            onTap: onAddFriend,
          ),
          const SizedBox(width: 8),
          _ActionChip(
            icon: Icons.visibility,
            label: 'Profile',
            color: AppColors.white50,
            onTap: onViewProfile,
          ),
        ],
      );
    }

    return Row(
      children: [
        _ActionChip(
          icon: Icons.sports_esports,
          label: 'Invite',
          color: AppColors.cyan,
          onTap: onInvite,
        ),
        const SizedBox(width: 6),
        _ActionChip(
          icon: Icons.chat_bubble_outline,
          label: 'Msg',
          color: AppColors.purpleGlow,
          onTap: onMessage,
        ),
        const SizedBox(width: 6),
        _ActionChip(
          icon: Icons.card_giftcard,
          label: 'Gift',
          color: AppColors.gold,
          onTap: onSendPopularity,
        ),
        if (onRemove != null) ...[
          const SizedBox(width: 6),
          _ActionChip(
            icon: Icons.person_remove,
            label: 'Remove',
            color: AppColors.crimsonRed,
            onTap: onRemove,
          ),
        ],
        const Spacer(),
        GestureDetector(
          onTap: onViewProfile,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white05,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Icon(
              Icons.chevron_right,
              color: AppColors.white50,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
