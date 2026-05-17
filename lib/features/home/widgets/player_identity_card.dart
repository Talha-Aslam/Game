import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/rank_badge.dart';

/// Glassmorphic player identity card (top-left)
class PlayerIdentityCard extends ConsumerWidget {
  const PlayerIdentityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.white05,
              border: Border.all(color: AppColors.glassBorder, width: 0.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              // Avatar
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.purpleNeon, width: 1.5),
                  color: AppColors.surfaceLight,
                ),
                child: Center(child: Text(
                  user?.username.isNotEmpty == true ? user!.username[0].toUpperCase() : 'G',
                  style: AppTextStyles.headlineSmall.copyWith(color: AppColors.purpleGlow, fontSize: 16),
                )),
              ),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user?.username ?? 'Guest', style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  RankBadge(tier: user?.rankTier ?? 0, size: 12, showLabel: false),
                  const SizedBox(width: 3),
                  Text(user?.rankName ?? 'Bronze', style: const TextStyle(
                    color: AppColors.white30, fontSize: 9, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 6),
                  // Online pulse
                  Container(width: 6, height: 6, decoration: BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.online,
                    boxShadow: [BoxShadow(color: AppColors.online.withValues(alpha: 0.4), blurRadius: 4)])),
                ]),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
