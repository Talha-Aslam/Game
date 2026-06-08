import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_wars/features/profile/widgets/avatar_preview_modal.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/avatar_model.dart';
import '../../../providers/auth_provider.dart';
// import 'widgets/avatar_preview_modal.dart';

class AvatarInventoryScreen extends ConsumerStatefulWidget {
  const AvatarInventoryScreen({super.key});

  @override
  ConsumerState<AvatarInventoryScreen> createState() =>
      _AvatarInventoryScreenState();
}

class _AvatarInventoryScreenState extends ConsumerState<AvatarInventoryScreen> {
  // Mock Avatars
  final List<AvatarModel> _avatars = const [
    AvatarModel(
      id: 'a1',
      name: 'Mafia Boss',
      description: 'The ruler of the underworld.',
      imageUrl: 'https://via.placeholder.com/150',
      rarity: AvatarRarity.legendary,
      priceSyndicateCoins: 1500,
    ),
    AvatarModel(
      id: 'a2',
      name: 'Cyber Detective',
      description: 'Finding clues in the neon lights.',
      imageUrl: 'https://via.placeholder.com/150',
      rarity: AvatarRarity.epic,
      priceSyndicateCoins: 800,
    ),
    AvatarModel(
      id: 'a3',
      name: 'Shadow Assassin',
      description: 'Unseen. Unheard.',
      imageUrl: 'https://via.placeholder.com/150',
      rarity: AvatarRarity.rare,
      priceSyndicateCoins: 400,
    ),
    AvatarModel(
      id: 'a4',
      name: 'Street Merc',
      description: 'Ready for action.',
      imageUrl: 'https://via.placeholder.com/150',
      rarity: AvatarRarity.common,
      priceSyndicateCoins: 100,
    ),
  ];

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

  void _showAvatarPreview(AvatarModel avatar) {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    // For demo purposes, let's pretend a1 and a4 are owned if they aren't explicitly in ownedAvatars
    bool isOwned =
        user.inventory.premiumAvatars.contains(avatar.id) ||
        avatar.id == 'a1' ||
        avatar.id == 'a4';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AvatarPreviewModal(
          avatar: avatar,
          user: user,
          isOwned: isOwned,
          onEquipOrBuy: () {
            // Mock equipping logic
            if (user.premiumAvatarId == avatar.id) {
              // Unequip
              // Actually we'd call an api. For now, we pop.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Avatar Unequipped')),
              );
            } else if (isOwned) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Equipped ${avatar.name}')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Not enough Syndicate Coins!')),
              );
            }
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Premium Avatars', style: AppTextStyles.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Featured Collection', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = _avatars[index];
                    final color = _getRarityColor(avatar.rarity);
                    final isEquipped = user.premiumAvatarId == avatar.id;

                    return GestureDetector(
                      onTap: () => _showAvatarPreview(avatar),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.glassBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isEquipped ? color : AppColors.glassBorder,
                            width: isEquipped ? 2 : 1,
                          ),
                          boxShadow: isEquipped
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.2),
                                    blurRadius: 15,
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: color, width: 2),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  avatar.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Icon(
                                    Icons.person,
                                    color: color,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              avatar.name,
                              style: AppTextStyles.labelLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              avatar.rarity.displayName,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: color,
                              ),
                            ),
                            if (isEquipped) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'EQUIPPED',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
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
}
