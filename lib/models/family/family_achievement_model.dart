import 'package:flutter/material.dart';

/// Family achievement model
class FamilyAchievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int currentProgress;
  final int target;
  final bool isUnlocked;
  final String rewardDescription;

  const FamilyAchievement({
    required this.id,
    required this.title,
    required this.description,
    this.icon = Icons.emoji_events,
    this.currentProgress = 0,
    required this.target,
    this.isUnlocked = false,
    this.rewardDescription = '',
  });

  double get progressPercent =>
      target > 0 ? (currentProgress / target).clamp(0.0, 1.0) : 0.0;

  /// All available family achievements
  static const List<FamilyAchievement> allAchievements = [
    FamilyAchievement(
      id: 'fam_wins_10',
      title: 'First Blood',
      description: 'Win 10 matches as a Family',
      icon: Icons.emoji_events,
      target: 10,
      rewardDescription: 'Bronze Crest Border',
    ),
    FamilyAchievement(
      id: 'fam_wins_100',
      title: 'Syndicate Force',
      description: 'Win 100 matches as a Family',
      icon: Icons.military_tech,
      target: 100,
      rewardDescription: 'Silver Crest Border',
    ),
    FamilyAchievement(
      id: 'fam_wins_500',
      title: 'City Dominators',
      description: 'Win 500 matches as a Family',
      icon: Icons.workspace_premium,
      target: 500,
      rewardDescription: 'Gold Animated Crest',
    ),
    FamilyAchievement(
      id: 'fam_sweeps_10',
      title: 'Perfect Syndicate',
      description: 'Win 10 perfect Mafia sweeps',
      icon: Icons.whatshot,
      target: 10,
      rewardDescription: 'Crimson Glow Effect',
    ),
    FamilyAchievement(
      id: 'fam_daily_500',
      title: 'Daily Grinders',
      description: 'Complete 500 daily missions',
      icon: Icons.calendar_today,
      target: 500,
      rewardDescription: 'Family Chat Badge',
    ),
    FamilyAchievement(
      id: 'fam_top_10',
      title: 'Top 10 Global',
      description: 'Reach top 10 on global leaderboard',
      icon: Icons.leaderboard,
      target: 1,
      rewardDescription: 'Animated Family Tag',
    ),
    FamilyAchievement(
      id: 'fam_members_50',
      title: 'Growing Empire',
      description: 'Reach 50 Family members',
      icon: Icons.groups,
      target: 50,
      rewardDescription: 'Expanded Voice Channels',
    ),
    FamilyAchievement(
      id: 'fam_wars_won_25',
      title: 'War Machine',
      description: 'Win 25 Syndicate Wars',
      icon: Icons.shield,
      target: 25,
      rewardDescription: 'War Victory Animation',
    ),
    FamilyAchievement(
      id: 'fam_treasury_10k',
      title: 'Loaded Vault',
      description: 'Accumulate 10,000 treasury points',
      icon: Icons.account_balance,
      target: 10000,
      rewardDescription: 'Treasury Particle Effects',
    ),
    FamilyAchievement(
      id: 'fam_level_10',
      title: 'Established Dynasty',
      description: 'Reach Family Level 10',
      icon: Icons.star,
      target: 10,
      rewardDescription: 'Animated Crest Glow',
    ),
    FamilyAchievement(
      id: 'fam_level_20',
      title: 'Legendary Syndicate',
      description: 'Reach Family Level 20',
      icon: Icons.auto_awesome,
      target: 20,
      rewardDescription: 'Family Aura Effects',
    ),
    FamilyAchievement(
      id: 'fam_streak_10',
      title: 'Unstoppable',
      description: 'Win 10 matches in a row',
      icon: Icons.local_fire_department,
      target: 10,
      rewardDescription: 'Fire Trail Effect',
    ),
  ];
}
