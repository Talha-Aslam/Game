import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/family_model.dart';

/// Top families leaderboard
class FamilyLeaderboardWidget extends StatelessWidget {
  final List<FamilyModel> families;
  const FamilyLeaderboardWidget({super.key, required this.families});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TOP FAMILIES',
          style: TextStyle(
            color: AppColors.white30,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        ...families.asMap().entries.map((e) {
          final f = e.value;
          final i = e.key;
          final medal = i == 0
              ? '🥇'
              : i == 1
              ? '🥈'
              : i == 2
              ? '🥉'
              : '${i + 1}';
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.white05,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    medal,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.name, style: AppTextStyles.labelMedium),
                      Text(f.tag, style: AppTextStyles.labelSmall),
                    ],
                  ),
                ),
                Text(
                  'Lv.${f.level}',
                  style: TextStyle(
                    color: AppColors.purpleGlow,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
