import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../models/rank_model.dart';
import '../../../models/social/friend_model.dart';
import '../../home/widgets/avatar_borders.dart';
import '../../../services/social_service.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  final FriendModel friend;

  const PublicProfileScreen({super.key, required this.friend});

  @override
  ConsumerState<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen> {
  late FriendModel _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _profile = widget.friend;
    _fetchRealData();
  }

  Future<void> _fetchRealData() async {
    final svc = SocialService();
    final realProfile = await svc.getPublicProfile(_profile.id);
    if (mounted && realProfile != null) {
      setState(() {
        _profile = realProfile;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyId() {
    Clipboard.setData(ClipboardData(text: _profile.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ID copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildAvatar() {
    final rank = RankModel.fromTier(_profile.rankTier);
    final url = _profile.avatarUrl;
    final resolvedUrl = url.startsWith('/') ? '${AppConstants.apiBaseUrl}$url' : url;
    final borderId = _profile.equippedCosmetics?['card_border'] ?? _profile.equippedCosmetics?['cardBorder'];

    Widget avatarContent;
    if (resolvedUrl.isNotEmpty) {
      avatarContent = Image.network(
        resolvedUrl,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => _fallbackAvatar(),
      );
    } else {
      avatarContent = _fallbackAvatar();
    }

    return PremiumAvatarBorder(
      borderId: borderId,
      radius: 50,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceLight,
          border: Border.all(color: AppColors.background, width: 2.5),
        ),
        child: ClipOval(child: avatarContent),
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Center(
      child: Text(
        _profile.username.isNotEmpty ? _profile.username[0].toUpperCase() : '?',
        style: const TextStyle(fontSize: 40, color: AppColors.white50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rank = RankModel.fromTier(_profile.rankTier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppGradients.backgroundGradient,
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: rank.glowColor.withValues(alpha: 0.2),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.glassBackgroundDark,
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('Player Profile', style: AppTextStyles.headlineSmall),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: AppColors.purpleNeon))
                    : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Avatar
                        _buildAvatar(),
                        const SizedBox(height: 16),
                        
                        Text(
                          _profile.username,
                          style: AppTextStyles.headlineMedium,
                        ),
                        if (_profile.equippedTitle != null && _profile.equippedTitle!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.purpleNeon.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.purpleNeon.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              _profile.equippedTitle!,
                              style: const TextStyle(
                                color: AppColors.purpleNeon,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        
                        // Copyable ID
                        GestureDetector(
                          onTap: _copyId,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ID: ${_profile.id.length >= 8 ? _profile.id.substring(0, 8).toUpperCase() : _profile.id.toUpperCase()}',
                                style: const TextStyle(
                                  color: AppColors.white50,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.copy, size: 14, color: AppColors.cyan),
                            ],
                          ),
                        ),
                        
                        if (_profile.familyTag != null && _profile.familyTag!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            '[${_profile.familyTag}] ${_profile.familyName ?? ""}',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                        
                        // Rank and Popularity Card
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatBox(
                                title: 'Rank',
                                value: rank.name,
                                color: rank.color,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatBox(
                                title: 'Popularity',
                                value: _profile.popularityScore.toString(),
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Overall Stats
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'OVERALL STATS',
                            style: TextStyle(
                              color: AppColors.white50,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.glassBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMiniStat('Games', '${_profile.gamesPlayed}'),
                              Container(height: 30, width: 1, color: AppColors.white10),
                              _buildMiniStat('Win Rate', '${_profile.winRate.toStringAsFixed(1)}%'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Role Stats
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ROLE STATS',
                            style: TextStyle(
                              color: AppColors.white50,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.glassBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Center(
                            child: Text(
                              'Detailed role statistics are private.',
                              style: TextStyle(color: AppColors.white50, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: AppColors.white50, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String title, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: AppColors.white50, fontSize: 12)),
      ],
    );
  }
}
