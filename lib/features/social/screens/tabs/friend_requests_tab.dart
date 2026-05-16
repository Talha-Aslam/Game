import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/social/friend_request_model.dart';
import '../../../../providers/social_provider.dart';

/// Friend Requests tab — incoming/outgoing with accept/reject
class FriendRequestsTab extends ConsumerWidget {
  const FriendRequestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(friendsProvider);
    final requests = state.pendingRequests;

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purpleNeon),
      );
    }

    final incoming = requests.where((r) => r.isIncoming).toList();
    final outgoing = requests.where((r) => !r.isIncoming).toList();

    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add_disabled, color: AppColors.white10, size: 56),
            const SizedBox(height: 12),
            Text(
              'No pending requests',
              style: TextStyle(color: AppColors.white30, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (incoming.isNotEmpty) ...[
          Text(
            'INCOMING — ${incoming.length}',
            style: const TextStyle(
              color: AppColors.cyan,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          ...incoming.map((r) => _RequestCard(
            request: r,
            onAccept: () =>
                ref.read(friendsProvider.notifier).acceptRequest(r.id),
            onReject: () =>
                ref.read(friendsProvider.notifier).rejectRequest(r.id),
          )),
        ],
        if (outgoing.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'SENT — ${outgoing.length}',
            style: const TextStyle(
              color: AppColors.white30,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          ...outgoing.map((r) => _RequestCard(
            request: r,
            isOutgoing: true,
            onCancel: () =>
                ref.read(friendsProvider.notifier).cancelRequest(r.id),
          )),
        ],
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  final FriendRequestModel request;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;
  final bool isOutgoing;

  const _RequestCard({
    required this.request,
    this.onAccept,
    this.onReject,
    this.onCancel,
    this.isOutgoing = false,
  });

  @override
  Widget build(BuildContext context) {
    final user = request.fromUser;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.glassBackground,
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceLight,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Center(
              child: Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.purpleGlow,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.username,
                        style: AppTextStyles.labelLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.familyTag != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        user.familyTag!,
                        style: const TextStyle(
                          color: AppColors.purpleGlow,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(user.rankName, style: AppTextStyles.labelSmall),
                    if (request.mutualFriendCount > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${request.mutualFriendCount} mutual',
                        style: TextStyle(
                          color: AppColors.cyan.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Actions
          if (!isOutgoing) ...[
            _ActionBtn(
              icon: Icons.check,
              color: AppColors.mintGreen,
              onTap: onAccept,
            ),
            const SizedBox(width: 6),
            _ActionBtn(
              icon: Icons.close,
              color: AppColors.crimsonRed,
              onTap: onReject,
            ),
          ] else
            _ActionBtn(
              icon: Icons.undo,
              color: AppColors.white30,
              onTap: onCancel,
              label: 'Cancel',
            ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? label;

  const _ActionBtn({
    required this.icon,
    required this.color,
    this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: label != null
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
            : const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label!,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
