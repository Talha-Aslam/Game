import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/social/family_invite_model.dart';

/// Bottom sheet modal for family invites with full details
class FamilyInviteModal extends StatelessWidget {
  final FamilyInviteModel invite;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const FamilyInviteModal({
    super.key,
    required this.invite,
    required this.onAccept,
    required this.onReject,
  });

  static Future<void> show(
    BuildContext context, {
    required FamilyInviteModel invite,
    required VoidCallback onAccept,
    required VoidCallback onReject,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FamilyInviteModal(
        invite: invite,
        onAccept: onAccept,
        onReject: onReject,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.surface,
        border: Border.all(color: AppColors.purpleNeon.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.purpleNeon.withValues(alpha: 0.1),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: AppColors.white30,
            ),
          ),
          const SizedBox(height: 20),
          // Family emblem
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.purpleNeon.withValues(alpha: 0.3),
                  AppColors.purpleDeep.withValues(alpha: 0.2),
                ],
              ),
              border: Border.all(
                color: AppColors.purpleNeon.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purpleNeon.withValues(alpha: 0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(Icons.groups, color: AppColors.purpleGlow, size: 36),
          ),
          const SizedBox(height: 16),
          // Family name
          Text(invite.familyName, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: AppColors.purpleNeon.withValues(alpha: 0.15),
            ),
            child: Text(
              invite.familyTag,
              style: TextStyle(
                color: AppColors.purpleGlow,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Invited by
          Text(
            'Invited by ${invite.fromUser.username}',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),
          // Stats row
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.white05,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Members',
                  value: '${invite.memberCount}/${invite.maxMembers}',
                  icon: Icons.people,
                ),
                _StatItem(
                  label: 'Wins',
                  value: '${invite.familyTotalWins}',
                  icon: Icons.emoji_events,
                ),
                _StatItem(
                  label: 'Rep',
                  value: '${invite.familyReputation}',
                  icon: Icons.star,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onReject();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.white05,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Center(
                      child: Text(
                        'Decline',
                        style: TextStyle(
                          color: AppColors.white50,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    onAccept();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [AppColors.purpleNeon, AppColors.purpleDeep],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purpleNeon.withValues(alpha: 0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'JOIN FAMILY',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.white30, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.labelLarge,
        ),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}
