import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/family_model.dart';

/// Premium family member card with role badge, presence, and action trigger
class FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback? onTap;
  final bool showActions;

  const FamilyMemberCard({super.key, required this.member, this.onTap, this.showActions = true});

  @override
  Widget build(BuildContext context) {
    final roleColor = member.role.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: member.isOnline
              ? AppColors.online.withValues(alpha: 0.04)
              : AppColors.glassBackground,
          border: Border.all(color: member.isOnline
              ? AppColors.online.withValues(alpha: 0.2) : AppColors.glassBorder),
        ),
        child: Row(
          children: [
            // Avatar with status
            Stack(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.surfaceLight,
                  border: Border.all(color: roleColor, width: 2),
                ),
                child: Center(child: Text(member.username[0].toUpperCase(),
                  style: TextStyle(color: roleColor, fontWeight: FontWeight.w700, fontSize: 16))),
              ),
              Positioned(right: 0, bottom: 0,
                child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, color: member.activity.statusColor,
                    border: Border.all(color: AppColors.background, width: 1.5),
                    boxShadow: member.isOnline ? [BoxShadow(
                      color: member.activity.statusColor.withValues(alpha: 0.5), blurRadius: 4)] : null,
                  ),
                ),
              ),
            ]),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(child: Text(member.username, style: AppTextStyles.labelLarge,
                    overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: roleColor.withValues(alpha: 0.15),
                    ),
                    child: Text(member.role.displayName,
                      style: TextStyle(color: roleColor, fontSize: 8, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  Text(member.rankName, style: AppTextStyles.labelSmall),
                  const SizedBox(width: 6),
                  Text('• ${member.activity.displayName}',
                    style: TextStyle(color: member.activity.statusColor, fontSize: 10)),
                ]),
              ],
            )),
            if (showActions) ...[
              Column(children: [
                Text('${member.contributedPoints}',
                  style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w700)),
                Text('contrib', style: AppTextStyles.labelSmall),
              ]),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.white30, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
