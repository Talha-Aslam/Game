import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/social/friend_model.dart';
import '../../../widgets/rank_badge.dart';
import '../../home/widgets/avatar_borders.dart';
import 'online_status_indicator.dart';
import 'popularity_badge_widget.dart';
import '../../home/widgets/card_backgrounds.dart';

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
  final bool hasUnreadMessages;

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
    this.hasUnreadMessages = false,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = friend.isOnline;
    final borderColor = isOnline
        ? AppColors.online.withValues(alpha: 0.3)
        : AppColors.glassBorder;

    final cardStyleId = friend.equippedCosmetics?['background']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: PremiumCardBackground(
        cardStyleId: cardStyleId,
        borderRadius: 16.0,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: cardStyleId == null
                ? AppColors.glassBackground
                : Colors.transparent,
            border: Border.all(
              color: cardStyleId == null ? borderColor : Colors.transparent,
            ),
            boxShadow: isOnline && cardStyleId == null
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
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final borderId =
        friend.equippedCosmetics?['card_border'] ??
        friend.equippedCosmetics?['cardBorder'];

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(
            4.0,
          ), // Padding to fit the glowing border
          child: PremiumAvatarBorder(
            borderId: borderId,
            radius: 24,
            child: Container(
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
              child: ClipOval(
                child: friend.avatarUrl.isNotEmpty
                    ? Image.network(
                        friend.avatarUrl.startsWith('/')
                            ? '${AppConstants.apiBaseUrl}${friend.avatarUrl}'
                            : friend.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackAvatar(),
                      )
                    : _buildFallbackAvatar(),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: OnlineStatusIndicator(status: friend.onlineStatus, size: 14),
        ),
      ],
    );
  }

  Widget _buildFallbackAvatar() {
    return Center(
      child: Text(
        friend.username.isNotEmpty ? friend.username[0].toUpperCase() : '?',
        style: AppTextStyles.headlineSmall.copyWith(
          color: friend.isOnline ? AppColors.online : AppColors.white50,
        ),
      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
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
            Text(friend.rankName, style: AppTextStyles.labelSmall),
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
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _ActionChip(
                  icon: Icons.person_add,
                  label: 'Add Friend',
                  color: AppColors.cyan,
                  onTap: onAddFriend,
                ),
                _ActionChip(
                  icon: Icons.visibility,
                  label: 'Profile',
                  color: AppColors.white50,
                  onTap: onViewProfile,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (onInvite != null)
                _ActionChip(
                  icon: Icons.sports_esports,
                  label: 'Invite',
                  color: AppColors.cyan,
                  onTap: onInvite,
                ),
              if (onMessage != null)
                _ActionChip(
                  icon: Icons.chat_bubble_outline,
                  label: 'Msg',
                  color: AppColors.purpleGlow,
                  onTap: onMessage,
                  showRedDot: hasUnreadMessages,
                ),
              if (onSendPopularity != null)
                _ActionChip(
                  icon: Icons.card_giftcard,
                  label: 'Gift',
                  color: AppColors.gold,
                  onTap: onSendPopularity,
                ),
              if (onRemove != null)
                _ActionChip(
                  icon: Icons.person_remove,
                  label: 'Remove',
                  color: AppColors.crimsonRed,
                  onTap: onRemove,
                ),
            ],
          ),
        ),
        const SizedBox(width: 6),
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
  final bool showRedDot;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.showRedDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
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
          if (showRedDot)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.crimsonRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
