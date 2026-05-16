import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
// ignore: unused_import
import '../../../core/theme/app_text_styles.dart';
import '../../../models/user_model.dart';

class OverallStatsWidget extends StatelessWidget {
  final UserModel user;

  const OverallStatsWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final statCards = [
      _StatCardData(
        value: '${user.totalGames}',
        label: 'Games',
        color: AppColors.cyan,
      ),
      _StatCardData(
        value: '${user.wins}',
        label: 'Wins',
        color: AppColors.mintGreen,
      ),
      _StatCardData(
        value: '${user.winRate.toStringAsFixed(1)}%',
        label: 'Win Rate',
        color: AppColors.gold,
      ),
      _StatCardData(
        value: '${user.rankPoints}',
        label: 'Rank Points',
        color: AppColors.gold,
      ),
      _StatCardData(
        value: '${user.influencePoints}',
        label: 'Influence',
        color: AppColors.cyan,
      ),
      _StatCardData(
        value: '${user.syndicateCoins}',
        label: 'Syndicate',
        color: AppColors.gold,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overall Statistics'),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: statCards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final stat = statCards[index];
            return _buildStatCard(stat);
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(_StatCardData stat) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassBackgroundDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: stat.color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: stat.color.withValues(alpha: 0.08),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stat.value,
            style: TextStyle(
              color: stat.color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            stat.label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCardData {
  final String value;
  final String label;
  final Color color;

  const _StatCardData({
    required this.value,
    required this.label,
    required this.color,
  });
}

class RoleStatsWidget extends StatelessWidget {
  const RoleStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Role Statistics'),
        const SizedBox(height: 12),
        _buildRoleStatRow(
          'Mafia',
          82,
          AppColors.crimsonRed,
          Icons.local_fire_department,
        ),
        const SizedBox(height: 8),
        _buildRoleStatRow('Detective', 61, AppColors.purpleNeon, Icons.search),
        const SizedBox(height: 8),
        _buildRoleStatRow(
          'Doctor',
          74,
          AppColors.mintGreen,
          Icons.local_hospital,
        ),
        const SizedBox(height: 8),
        _buildRoleStatRow('Civilian', 45, AppColors.cyan, Icons.person),
      ],
    );
  }

  Widget _buildRoleStatRow(
    String role,
    int winRate,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              role,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  height: 6,
                  width: winRate * 1.5, // Mock width calculation
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [BoxShadow(color: color, blurRadius: 4)],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$winRate%',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class ReputationBadgeWidget extends StatelessWidget {
  const ReputationBadgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user, color: AppColors.gold, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Trust & Reputation'),
                Text(
                  'Elite Citizen — 98% Positive Feedback',
                  style: TextStyle(color: AppColors.gold, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
    );
  }
}
