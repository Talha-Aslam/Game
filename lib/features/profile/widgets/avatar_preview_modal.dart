import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/avatar_model.dart';
import '../../../../models/user_model.dart';

class AvatarPreviewModal extends StatelessWidget {
  final AvatarModel avatar;
  final UserModel user;
  final bool isOwned;
  final VoidCallback onEquipOrBuy;

  const AvatarPreviewModal({
    super.key,
    required this.avatar,
    required this.user,
    required this.isOwned,
    required this.onEquipOrBuy,
  });

  Color _getRarityColor(AvatarRarity rarity) {
    switch (rarity) {
      case AvatarRarity.common:
        return AppColors.cyan;
      case AvatarRarity.rare:
        return AppColors.purpleNeon;
      case AvatarRarity.epic:
        return AppColors.mintGreen;
      case AvatarRarity.legendary:
        return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEquipped = user.premiumAvatarId == avatar.id;
    Color rarityColor = _getRarityColor(avatar.rarity);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: rarityColor.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Simulated Avatar Preview
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
              border: Border.all(color: rarityColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: rarityColor.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                avatar.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, size: 80, color: rarityColor),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(avatar.name, style: AppTextStyles.displaySmall),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: rarityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: rarityColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              avatar.rarity.displayName.toUpperCase(),
              style: TextStyle(
                color: rarityColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            avatar.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white70),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: onEquipOrBuy,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isEquipped
                    ? AppColors.darkGrey
                    : isOwned
                    ? AppColors.purpleNeon
                    : AppColors.gold,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                isEquipped
                    ? 'UNEQUIP'
                    : isOwned
                    ? 'EQUIP AVATAR'
                    : 'PURCHASE — ${avatar.priceSyndicateCoins} SC',
                style: TextStyle(
                  color: isEquipped ? AppColors.white50 : AppColors.background,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
