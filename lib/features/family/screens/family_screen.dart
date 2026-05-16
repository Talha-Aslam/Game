import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/family_provider.dart';
import '../../../models/family_model.dart';
import '../../../widgets/neon_text.dart';

class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final family = ref.watch(familyProvider);

    if (family == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
          child: Center(child: Text('No family joined', style: AppTextStyles.bodyMedium)),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back, color: AppColors.white70)),
                    const SizedBox(width: 16),
                    Expanded(child: NeonText(text: family.tag, fontSize: 20, color: AppColors.purpleNeon, glowRadius: 15)),
                  ],
                ),
              ),

              // Family header
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.white05,
                  border: Border.all(color: AppColors.purpleNeon.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(family.name, style: AppTextStyles.headlineLarge),
                    const SizedBox(height: 4),
                    Text(family.description, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatCol(label: 'Members', value: '${family.memberCount}/${family.maxMembers}'),
                        _StatCol(label: 'Wins', value: '${family.totalWins}'),
                        _StatCol(label: 'Season', value: '${family.seasonPoints}'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(alignment: Alignment.centerLeft, child: Text('Members', style: AppTextStyles.headlineSmall)),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: family.members.length,
                  itemBuilder: (context, i) {
                    final m = family.members[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.white05,
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceLight,
                              border: Border.all(color: _roleColor(m.role), width: 1.5),
                            ),
                            child: Center(child: Text(m.username[0], style: TextStyle(color: _roleColor(m.role), fontWeight: FontWeight.w700))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.username, style: AppTextStyles.labelLarge),
                                Text(m.role.displayName, style: AppTextStyles.labelSmall.copyWith(color: _roleColor(m.role))),
                              ],
                            ),
                          ),
                          // Online status
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: m.isOnline ? AppColors.online : AppColors.offline,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${m.contributedPoints}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.gold)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _roleColor(FamilyRole role) {
    switch (role) {
      case FamilyRole.boss: return AppColors.gold;
      case FamilyRole.underboss: return AppColors.purpleNeon;
      case FamilyRole.capo: return AppColors.cyan;
      case FamilyRole.associate: return AppColors.white50;
    }
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  const _StatCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.purpleGlow)),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}
