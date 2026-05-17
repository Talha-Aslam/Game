import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/family/family_treasury_model.dart';

/// Treasury vault widget with balance, boosts, and donate
class TreasuryWidget extends StatelessWidget {
  final FamilyTreasury treasury;
  final VoidCallback? onDonate;
  const TreasuryWidget({super.key, required this.treasury, this.onDonate});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Vault balance
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.gold.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
      ), child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(
          shape: BoxShape.circle, gradient: LinearGradient(
            colors: [AppColors.gold, AppColors.goldDark]),
          boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.3), blurRadius: 12)],
        ), child: const Icon(Icons.account_balance, color: Colors.white, size: 24)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('SYNDICATE VAULT', style: TextStyle(
            color: AppColors.white30, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
          Text('${treasury.balance}', style: TextStyle(
            color: AppColors.gold, fontSize: 28, fontWeight: FontWeight.w800)),
        ])),
        GestureDetector(onTap: onDonate, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(colors: [AppColors.gold, AppColors.goldDark])),
          child: const Text('DONATE', style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1)),
        )),
      ])),
      // Active boosts
      if (treasury.currentActiveBoosts.isNotEmpty) ...[
        const SizedBox(height: 16),
        Text('ACTIVE BOOSTS', style: TextStyle(
          color: AppColors.white30, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        ...treasury.currentActiveBoosts.map((b) => Container(
          margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
            color: b.type.color.withValues(alpha: 0.06),
            border: Border.all(color: b.type.color.withValues(alpha: 0.2))),
          child: Row(children: [
            Icon(b.type.icon, color: b.type.color, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(b.type.displayName,
              style: TextStyle(color: b.type.color, fontSize: 12, fontWeight: FontWeight.w600))),
            Text(b.remainingText, style: AppTextStyles.labelSmall),
          ]),
        )),
      ],
      // Top contributors
      if (treasury.topContributors.isNotEmpty) ...[
        const SizedBox(height: 16),
        Text('TOP CONTRIBUTORS', style: TextStyle(
          color: AppColors.white30, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        ...treasury.topContributors.asMap().entries.map((e) {
          final c = e.value; final i = e.key;
          final medal = i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '  ';
          return Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [
            Text(medal, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Expanded(child: Text(c.username, style: AppTextStyles.labelMedium)),
            Text('${c.totalDonated}', style: TextStyle(
              color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w700)),
          ]));
        }),
      ],
    ]);
  }
}
