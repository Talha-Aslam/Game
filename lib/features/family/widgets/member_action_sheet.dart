import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/family_model.dart';

/// Bottom sheet action menu for interacting with a family member
class MemberActionSheet extends StatelessWidget {
  final FamilyMember member;
  final FamilyRole myRole;
  final VoidCallback? onInviteMatch;
  final VoidCallback? onInviteParty;
  final VoidCallback? onViewProfile;
  final VoidCallback? onSendPopularity;
  final VoidCallback? onPromote;
  final VoidCallback? onDemote;
  final VoidCallback? onKick;
  final VoidCallback? onMute;

  const MemberActionSheet({
    super.key, required this.member, required this.myRole,
    this.onInviteMatch, this.onInviteParty, this.onViewProfile,
    this.onSendPopularity, this.onPromote, this.onDemote,
    this.onKick, this.onMute,
  });

  static void show(BuildContext context, {
    required FamilyMember member, required FamilyRole myRole,
    VoidCallback? onInviteMatch, VoidCallback? onInviteParty,
    VoidCallback? onViewProfile, VoidCallback? onSendPopularity,
    VoidCallback? onPromote, VoidCallback? onDemote,
    VoidCallback? onKick, VoidCallback? onMute,
  }) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => MemberActionSheet(
        member: member, myRole: myRole,
        onInviteMatch: onInviteMatch, onInviteParty: onInviteParty,
        onViewProfile: onViewProfile, onSendPopularity: onSendPopularity,
        onPromote: onPromote, onDemote: onDemote,
        onKick: onKick, onMute: onMute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManage = myRole.hierarchyLevel < member.role.hierarchyLevel;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), color: AppColors.surface,
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2), color: AppColors.white30)),
        const SizedBox(height: 16),
        Text(member.username, style: AppTextStyles.headlineMedium),
        const SizedBox(height: 4),
        Text('${member.role.displayName} • ${member.activity.displayName}',
          style: AppTextStyles.bodySmall),
        const SizedBox(height: 16),
        // Social actions
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _ActionBtn(Icons.sports_esports, 'Match', AppColors.cyan, onInviteMatch),
          _ActionBtn(Icons.groups, 'Party', AppColors.partyBlue, onInviteParty),
          _ActionBtn(Icons.card_giftcard, 'Gift', AppColors.gold, onSendPopularity),
          _ActionBtn(Icons.visibility, 'Profile', AppColors.white50, onViewProfile),
        ]),
        // Admin actions
        if (canManage && myRole.canKick) ...[
          const SizedBox(height: 12),
          const Divider(color: AppColors.glassBorder),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            if (myRole.canPromote)
              _ActionBtn(Icons.arrow_upward, 'Promote', AppColors.gold, onPromote),
            if (myRole.canPromote)
              _ActionBtn(Icons.arrow_downward, 'Demote', AppColors.inGame, onDemote),
            _ActionBtn(Icons.volume_off, member.isMuted ? 'Unmute' : 'Mute',
              AppColors.idleYellow, onMute),
            _ActionBtn(Icons.person_remove, 'Kick', AppColors.crimsonRed, onKick),
          ]),
        ],
        const SizedBox(height: 8),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _ActionBtn(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { 
        Navigator.of(context).pop();
        onTap?.call(); 
      },
      child: Column(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
