import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/family/family_application_model.dart';

/// Application card showing applicant stats with accept/reject
class FamilyInviteCard extends StatelessWidget {
  final FamilyApplication application;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  const FamilyInviteCard({super.key, required this.application, this.onAccept, this.onReject});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), color: AppColors.cyan.withValues(alpha: 0.04),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(
            shape: BoxShape.circle, color: AppColors.surfaceLight,
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
          ), child: Center(child: Text(application.applicantName[0].toUpperCase(),
            style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w700, fontSize: 16)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(application.applicantName, style: AppTextStyles.labelLarge),
            Text('${application.rankName} • ${application.winRate.toStringAsFixed(1)}% WR',
              style: AppTextStyles.labelSmall),
          ])),
        ]),
        const SizedBox(height: 10),
        // Stats row
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: AppColors.white05),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _Stat('Games', '${application.totalGames}'),
            _Stat('Trust', '${application.trustRating.toStringAsFixed(1)}'),
            _Stat('Pop.', '${application.popularityScore}'),
            if (application.mostPlayedRole != null) _Stat('Role', application.mostPlayedRole!),
          ]),
        ),
        if (application.previousFamilyName != null) ...[
          const SizedBox(height: 6),
          Text('Previously: ${application.previousFamilyName}',
            style: TextStyle(color: AppColors.white30, fontSize: 10, fontStyle: FontStyle.italic)),
        ],
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: GestureDetector(onTap: onReject, child: Container(height: 34,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
              color: AppColors.white05, border: Border.all(color: AppColors.glassBorder)),
            child: const Center(child: Text('Reject',
              style: TextStyle(color: AppColors.white50, fontWeight: FontWeight.w600, fontSize: 12)))))),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: GestureDetector(onTap: onAccept, child: Container(height: 34,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(colors: [AppColors.cyan, AppColors.cyanDeep])),
            child: const Center(child: Text('Accept',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)))))),
        ]),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label; final String value;
  const _Stat(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: AppTextStyles.labelMedium),
      Text(label, style: AppTextStyles.labelSmall),
    ]);
  }
}
