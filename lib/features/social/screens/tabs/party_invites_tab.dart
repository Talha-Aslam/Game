import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/social/party_model.dart';
import '../../../../providers/party_provider.dart';

/// Party Invites tab
class PartyInvitesTab extends ConsumerWidget {
  const PartyInvitesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(partyProvider);
    final invites = state.incomingInvites
        .where((i) => i.status == PartyInviteStatus.pending)
        .toList();

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purpleNeon),
      );
    }

    if (invites.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_outlined, color: AppColors.white10, size: 56),
            const SizedBox(height: 12),
            Text(
              'No party invites',
              style: TextStyle(color: AppColors.white30, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invites.length,
      itemBuilder: (context, index) {
        final invite = invites[index];
        return _PartyInviteCard(
          invite: invite,
          onAccept: () =>
              ref.read(partyProvider.notifier).acceptInvite(invite.id),
          onReject: () =>
              ref.read(partyProvider.notifier).rejectInvite(invite.id),
        );
      },
    );
  }
}

class _PartyInviteCard extends StatelessWidget {
  final PartyInviteModel invite;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _PartyInviteCard({
    required this.invite,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.cyan.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withValues(alpha: 0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cyan.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.cyan.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    invite.fromUser.username[0].toUpperCase(),
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.cyan,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invite.fromUser.username,
                      style: AppTextStyles.labelLarge,
                    ),
                    Text(
                      '${invite.gameMode.toUpperCase()} • ${invite.currentPartySize}/${invite.maxPartySize} players',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.cyan.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onReject,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.white05,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Center(
                      child: Text(
                        'Decline',
                        style: TextStyle(
                          color: AppColors.white50,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onAccept,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [AppColors.cyan, AppColors.cyanDeep],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'JOIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
