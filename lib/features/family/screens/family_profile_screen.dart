import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/family_provider.dart';
import '../widgets/family_crest_widget.dart';
import '../widgets/family_stat_card.dart';
import '../widgets/family_level_progress_bar.dart';
import '../widgets/family_achievement_card.dart';

/// Public-facing family profile screen
class FamilyProfileScreen extends ConsumerWidget {
  const FamilyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(familyProvider);
    final f = state.family;
    if (f == null) return const Scaffold(body: Center(child: Text('No family data')));
    return Scaffold(body: Container(
      decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
      child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Row(children: [
          GestureDetector(onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: AppColors.white70)),
          const SizedBox(width: 16),
          Text('Family Profile', style: AppTextStyles.headlineMedium),
        ]),
        const SizedBox(height: 24),
        FamilyCrestWidget(themeColor: f.themeColor, level: f.level, size: 80),
        const SizedBox(height: 12),
        Text(f.name, style: AppTextStyles.headlineLarge),
        Text(f.tag, style: TextStyle(color: f.themeColor, fontSize: 14, fontWeight: FontWeight.w600)),
        if (f.slogan.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4),
          child: Text('"${f.slogan}"', style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic))),
        const SizedBox(height: 16),
        FamilyLevelProgressBar(level: f.level, currentXP: f.currentXP, xpToNextLevel: f.xpToNextLevel, color: f.themeColor),
        const SizedBox(height: 16),
        GridView.count(crossAxisCount: 3, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.2, children: [
            FamilyStatCard(label: 'Members', value: '${f.memberCount}', icon: Icons.people, color: AppColors.cyan),
            FamilyStatCard(label: 'Wins', value: '${f.totalWins}', icon: Icons.emoji_events, color: AppColors.gold),
            FamilyStatCard(label: 'Win Rate', value: '${f.winRate.toStringAsFixed(1)}%', icon: Icons.trending_up, color: AppColors.mintGreen),
            FamilyStatCard(label: 'Wars Won', value: '${f.warWins}', icon: Icons.whatshot, color: AppColors.crimsonRed),
            FamilyStatCard(label: 'Treasury', value: '${f.treasuryBalance}', icon: Icons.account_balance, color: AppColors.gold),
            FamilyStatCard(label: 'Rank', value: '#${f.globalRank}', icon: Icons.leaderboard, color: AppColors.purpleGlow),
          ]),
        if (f.description.isNotEmpty) ...[
          const SizedBox(height: 16),
          Align(alignment: Alignment.centerLeft, child: Text(f.description, style: AppTextStyles.bodyMedium)),
        ],
        const SizedBox(height: 20),
        // Achievements preview
        if (state.achievements.isNotEmpty) ...[
          Align(alignment: Alignment.centerLeft, child: Text('ACHIEVEMENTS',
            style: TextStyle(color: AppColors.white30, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5))),
          const SizedBox(height: 8),
          ...state.achievements.where((a) => a.isUnlocked).take(3).map((a) =>
            FamilyAchievementCard(achievement: a)),
        ],
      ])))),
    );
  }
}
