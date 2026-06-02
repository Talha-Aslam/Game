import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/family_model.dart';

/// Search result card for discovering families
class FamilySearchCard extends StatelessWidget {
  final FamilyModel family;
  final VoidCallback? onJoin;
  const FamilySearchCard({super.key, required this.family, this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
        color: AppColors.glassBackground, border: Border.all(color: AppColors.glassBorder)),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(
          shape: BoxShape.circle, color: family.themeColor.withValues(alpha: 0.12),
          border: Border.all(color: family.themeColor.withValues(alpha: 0.3))),
          child: Icon(Icons.groups, color: family.themeColor, size: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(family.name, style: AppTextStyles.labelLarge, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 6),
            Text(family.tag, style: TextStyle(color: family.themeColor, fontSize: 10, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 2),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(family.privacy.icon, color: AppColors.white30, size: 10),
              const SizedBox(width: 3),
              Text(family.privacy.displayName, style: AppTextStyles.labelSmall),
              const SizedBox(width: 8),
              Text('Lv.${family.level}', style: TextStyle(
                color: AppColors.purpleGlow, fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text('${family.memberCount} members', style: AppTextStyles.labelSmall),
            ],
          ),
        ])),
        GestureDetector(onTap: onJoin, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
            color: family.privacy == FamilyPrivacy.inviteOnly ? AppColors.white05
                : AppColors.cyan.withValues(alpha: 0.12),
            border: Border.all(color: family.privacy == FamilyPrivacy.inviteOnly
                ? AppColors.glassBorder : AppColors.cyan.withValues(alpha: 0.3))),
          child: Text(
            family.privacy == FamilyPrivacy.public ? 'JOIN'
                : family.privacy == FamilyPrivacy.approvalRequired ? 'APPLY' : 'INVITE',
            style: TextStyle(
              color: family.privacy == FamilyPrivacy.inviteOnly ? AppColors.white30 : AppColors.cyan,
              fontSize: 10, fontWeight: FontWeight.w700)),
        )),
      ]),
    );
  }
}
