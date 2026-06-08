import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../providers/match_history_provider.dart';

class RecentMatchesTab extends ConsumerWidget {
  const RecentMatchesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(recentMatchesProvider);

    return matchesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.purpleNeon)),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
      data: (matches) {
        if (matches.isEmpty) {
          return const Center(child: Text('No matches found', style: TextStyle(color: AppColors.white30)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return _MatchCard(match: match);
          },
        );
      },
    );
  }
}

class _MatchCard extends StatelessWidget {
  final MatchHistoryModel match;
  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final accentColor = match.won ? AppColors.mintGreen : AppColors.crimsonRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white05,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              match.won ? Icons.emoji_events : Icons.close,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      match.won ? 'VICTORY' : 'DEFEAT',
                      style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${match.mode}',
                      style: const TextStyle(color: AppColors.white30, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Played as ${match.role}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${match.xpGained} XP',
                style: const TextStyle(color: AppColors.purpleGlow, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM d, HH:mm').format(match.timestamp),
                style: const TextStyle(color: AppColors.white10, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}