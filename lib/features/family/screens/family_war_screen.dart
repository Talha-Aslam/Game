import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/family_provider.dart';
import '../../../models/family/family_war_model.dart';
import '../widgets/war_lobby_card.dart';
import '../widgets/rivalry_history_card.dart';

/// Syndicate Wars screen — 7v7 default
class FamilyWarScreen extends ConsumerWidget {
  const FamilyWarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(familyProvider);
    final active = state.wars.where((w) => w.status != WarStatus.completed).toList();
    final past = state.wars.where((w) => w.status == WarStatus.completed).toList();

    return Scaffold(body: Container(
      decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
      child: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          GestureDetector(onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: AppColors.white70)),
          const SizedBox(width: 16),
          Text('Syndicate Wars', style: AppTextStyles.headlineMedium),
          const Spacer(),
          Text('7v7', style: TextStyle(color: AppColors.crimsonRed, fontSize: 12, fontWeight: FontWeight.w700)),
        ])),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (active.isNotEmpty) ...[
              Text('ACTIVE / PENDING', style: TextStyle(color: AppColors.crimsonRed, fontSize: 10,
                fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              ...active.map((w) => WarLobbyCard(war: w)),
            ],
            if (past.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('PAST WARS', style: TextStyle(color: AppColors.white30, fontSize: 10,
                fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              ...past.map((w) => WarLobbyCard(war: w)),
            ],
            if (state.rivalries.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('RIVALRIES', style: TextStyle(color: AppColors.white30, fontSize: 10,
                fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              ...state.rivalries.map((r) => RivalryHistoryCard(rivalry: r)),
            ],
          ],
        ))),
      ])),
    ));
  }
}
