import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/social/family_invite_model.dart';

/// Mock family invites provider for demo
final _familyInvitesProvider = Provider<List<FamilyInviteModel>>((ref) {
  return [];
});

/// Family Invites tab
class FamilyInvitesTab extends ConsumerWidget {
  const FamilyInvitesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invites = ref.watch(_familyInvitesProvider);

    if (invites.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_outlined, color: AppColors.white10, size: 56),
            const SizedBox(height: 12),
            Text(
              'No family invites',
              style: TextStyle(color: AppColors.white30, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to family create screen
                GoRouter.of(context).push('/family/create');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purpleNeon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Create Family',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
        return _FamilyInviteCard(invite: invite);
      },
    );
  }
}

class _FamilyInviteCard extends StatelessWidget {
  final FamilyInviteModel invite;
  const _FamilyInviteCard({required this.invite});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.purpleNeon.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.purpleNeon.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.purpleNeon.withValues(alpha: 0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Family emblem
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.purpleNeon.withValues(alpha: 0.2),
                      AppColors.purpleDeep.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.purpleNeon.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.groups,
                  color: AppColors.purpleGlow,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          invite.familyName,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.purpleGlow,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: AppColors.purpleNeon.withValues(alpha: 0.2),
                          ),
                          child: Text(
                            invite.familyTag,
                            style: const TextStyle(
                              color: AppColors.purpleGlow,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Invited by ${invite.fromUser.username}',
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stats row
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.white05,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(
                  icon: Icons.people,
                  value: '${invite.memberCount}/${invite.maxMembers}',
                  label: 'Members',
                ),
                _Stat(
                  icon: Icons.emoji_events,
                  value: '${invite.familyTotalWins}',
                  label: 'Wins',
                ),
                _Stat(
                  icon: Icons.star,
                  value: '${invite.familyReputation}',
                  label: 'Rep',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
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
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [AppColors.purpleNeon, AppColors.purpleDeep],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purpleNeon.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'JOIN FAMILY',
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

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.white30, size: 14),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.labelMedium),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}
