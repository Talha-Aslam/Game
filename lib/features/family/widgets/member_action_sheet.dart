import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/family_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/family_provider.dart';

class MemberActionSheet extends ConsumerWidget {
  final FamilyMember member;
  final FamilyRole myRole;
  final VoidCallback? onPromote;
  final VoidCallback? onDemote;
  final VoidCallback? onKick;

  const MemberActionSheet({
    super.key,
    required this.member,
    required this.myRole,
    this.onPromote,
    this.onDemote,
    this.onKick,
  });

  static void show(
    BuildContext context, {
    required FamilyMember member,
    required FamilyRole myRole,
    VoidCallback? onPromote,
    VoidCallback? onDemote,
    VoidCallback? onKick,
    VoidCallback? onMute,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MemberActionSheet(
        member: member,
        myRole: myRole,
        onPromote: onPromote,
        onDemote: onDemote,
        onKick: onKick,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).user;
    final isMe = currentUser?.id == member.userId;
    final canManage = myRole.hierarchyLevel < member.role.hierarchyLevel;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.85),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: AppColors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.purpleNeon.withValues(alpha: 0.1),
                  child: Text(member.username[0].toUpperCase(), style: const TextStyle(color: AppColors.purpleNeon, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.username, style: AppTextStyles.headlineSmall),
                      Text(member.role.displayName.toUpperCase(), style: TextStyle(color: member.role.color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (!isMe) ...[
              _ActionButton(icon: Icons.card_giftcard, label: 'SEND GIFT', color: AppColors.gold, onTap: () {
                final notifier = ref.read(familyProvider.notifier);
                Navigator.pop(context);
                _showGiftDialog(context, (amt) => notifier.sendGift(member.userId, amt));
              }),
            ],

            _ActionButton(icon: Icons.person_outline, label: 'VIEW PROFILE', color: Colors.white, onTap: () {
              Navigator.pop(context);
              context.push('/public-profile', extra: member.toFriendModel());
            }),

            if (canManage && !isMe) ...[
              const Divider(color: AppColors.white10, height: 32),
              Row(
                children: [
                  if (member.role != FamilyRole.underboss)
                    Expanded(child: _AdminButton(label: 'PROMOTE', icon: Icons.arrow_upward, color: AppColors.mintGreen, onTap: () {
                      Navigator.pop(context);
                      onPromote?.call();
                    })),
                  if (member.role != FamilyRole.associate)
                    Expanded(child: _AdminButton(label: 'DEMOTE', icon: Icons.arrow_downward, color: AppColors.gold, onTap: () {
                      Navigator.pop(context);
                      onDemote?.call();
                    })),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _AdminButton(label: 'KICK', icon: Icons.person_remove, color: AppColors.crimsonRed, onTap: () {
                    Navigator.pop(context);
                    onKick?.call();
                  })),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showGiftDialog(BuildContext context, Future<bool> Function(int) onSendGift) {
    final ctrl = TextEditingController(text: '100');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Gift to ${member.username}', style: AppTextStyles.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter amount of Syndicate Coins to send:', style: TextStyle(color: AppColors.white70, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.diamond, color: AppColors.gold, size: 20),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.white10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: AppColors.white30))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            onPressed: () async {
              final amt = int.tryParse(ctrl.text) ?? 0;
              if (amt <= 0) return;
              final success = await onSendGift(amt);
              if (ctx.mounted) {
                final messenger = ScaffoldMessenger.of(ctx);
                Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Gift sent!' : 'Failed to send gift. Check balance.'),
                    backgroundColor: success ? AppColors.cyan : AppColors.crimsonRed,
                  ),
                );
              }
            },
            child: const Text('SEND GIFT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 16),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1.2)),
              const Spacer(),
              Icon(Icons.chevron_right, color: color.withValues(alpha: 0.3), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }
}