import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/store_item_model.dart';
import '../models/user_model.dart';
import '../services/store_api_service.dart';
import 'auth_provider.dart';

final storeItemsProvider = Provider<List<StoreItemModel>>((ref) {
  return [
    StoreItemModel(id: 's1', name: 'Crimson Flame', description: 'A fiery card border', category: StoreCategory.borders, priceSyndicate: 500),
    StoreItemModel(id: 's2', name: 'Neon Circuit', description: 'Cyberpunk card style', category: StoreCategory.cardStyles, priceSyndicate: 750),
    StoreItemModel(id: 's3', name: 'Shatter FX', description: 'Glass shatter elimination', category: StoreCategory.eliminationEffects, priceSyndicate: 1000),
    StoreItemModel(id: 's4', name: 'Deep Voice', description: 'Low pitch voice pack', category: StoreCategory.voicePacks, priceInfluence: 5000),
    StoreItemModel(id: 's5', name: 'Ghost Avatar', description: 'Spectral avatar frame', category: StoreCategory.avatars, priceInfluence: 3000),
    StoreItemModel(id: 's6', name: 'Syndicate Bundle', description: 'Premium elite bundle', category: StoreCategory.bundles, priceSyndicate: 2000, isLimited: true),
    StoreItemModel(id: 's7', name: 'Ice Aura', description: 'Frozen border effect', category: StoreCategory.borders, priceSyndicate: 600),
    StoreItemModel(id: 's8', name: 'Royal Gold', description: 'Gold plated card style', category: StoreCategory.cardStyles, priceSyndicate: 900),

    // PREMIUM CALLING CARDS (Backgrounds)
    StoreItemModel(id: 'cc1', name: 'Phantom Signal', description: 'Cyberpunk purple scan-line sweep', category: StoreCategory.cardStyles, priceSyndicate: 1100),
    StoreItemModel(id: 'cc2', name: 'Obsidian Don', description: 'Heavy black-gold embossed luxury', category: StoreCategory.cardStyles, priceSyndicate: 1600),
    StoreItemModel(id: 'cc3', name: 'Blood Contract', description: 'Dark crimson radial burn with vein texture', category: StoreCategory.cardStyles, priceSyndicate: 1200),
    StoreItemModel(id: 'cc4', name: 'Neon Underworld', description: 'Electric teal grid with neon pulse', category: StoreCategory.cardStyles, priceSyndicate: 950),
    StoreItemModel(id: 'cc5', name: 'Ash & Ember', description: 'Smouldering orange ember glow drift', category: StoreCategory.cardStyles, priceSyndicate: 1050),
    StoreItemModel(id: 'cc6', name: 'Chrome Syndicate', description: 'Chrome metallic diagonal sheen shimmer', category: StoreCategory.cardStyles, priceSyndicate: 1300),
    StoreItemModel(id: 'cc7', name: 'Void Protocol', description: 'Deep-space void with star-particle field', category: StoreCategory.cardStyles, priceSyndicate: 1400),
    StoreItemModel(id: 'cc8', name: 'Toxic Ledger', description: 'Acid-green data rain streaks', category: StoreCategory.cardStyles, priceSyndicate: 900),
    StoreItemModel(id: 'cc9', name: 'Gilded Throne', description: 'Animated three-stop gold shimmer sweep', category: StoreCategory.cardStyles, priceSyndicate: 1700),
    StoreItemModel(id: 'cc10', name: 'Shadow Masquerade', description: 'Violet gothic shimmer + corner filigree', category: StoreCategory.cardStyles, priceSyndicate: 1250),
    StoreItemModel(id: 'cc11', name: 'Ice Cartel', description: 'Cold frost shatter diagonal prism', category: StoreCategory.cardStyles, priceSyndicate: 1150),
    StoreItemModel(id: 'cc12', name: 'Infernal Blueprint', description: 'Hellfire red with scan-line grid overlay', category: StoreCategory.cardStyles, priceSyndicate: 1000),
    StoreItemModel(id: 'cc13', name: 'Digital Specter', description: 'Matrix code cascade rain', category: StoreCategory.cardStyles, priceSyndicate: 1100),
    StoreItemModel(id: 'cc14', name: 'Nocturne Silk', description: 'Indigo-midnight satin diagonal sheen', category: StoreCategory.cardStyles, priceSyndicate: 1350),
    StoreItemModel(id: 'cc15', name: 'Wraith Glass', description: 'Ghost-white breath on dark glass', category: StoreCategory.cardStyles, priceSyndicate: 1050),
    StoreItemModel(id: 'cc16', name: 'Crimson Frequency', description: 'Heartbeat EKG line across deep red', category: StoreCategory.cardStyles, priceSyndicate: 950),
    StoreItemModel(id: 'cc17', name: 'Copper Baron', description: 'Aged copper verdigris texture pulse', category: StoreCategory.cardStyles, priceSyndicate: 1200),
    StoreItemModel(id: 'cc18', name: 'Eclipse Sovereign', description: 'Solar-eclipse radial corona slow burn', category: StoreCategory.cardStyles, priceSyndicate: 1800),
    StoreItemModel(id: 'cc19', name: 'Storm Circuit', description: 'Lightning-arc diagonal electric sweep', category: StoreCategory.cardStyles, priceSyndicate: 1000),
    StoreItemModel(id: 'cc20', name: 'Onyx Serpent', description: 'Animated snake-scale hex mosaic', category: StoreCategory.cardStyles, priceSyndicate: 1500),

    // NEW PREMIUM ANIMATED BORDERS
    StoreItemModel(id: 'b1', name: 'Shadow Sovereign', description: 'Gothic pulsing dark-gold crown aura', category: StoreCategory.borders, priceSyndicate: 1200),
    StoreItemModel(id: 'b2', name: 'Neon Don', description: 'Cyberpunk purple-magenta spinning sweep', category: StoreCategory.borders, priceSyndicate: 900),
    StoreItemModel(id: 'b3', name: 'Phantom Protocol', description: 'Masked-villain rotating dashed circuit ring', category: StoreCategory.borders, priceSyndicate: 1000),
    StoreItemModel(id: 'b4', name: 'Bloodpact', description: 'Crimson heartbeat throb', category: StoreCategory.borders, priceSyndicate: 800),
    StoreItemModel(id: 'b5', name: 'Void Walker', description: 'Deep-void black-hole rotating rings', category: StoreCategory.borders, priceSyndicate: 1100),
    StoreItemModel(id: 'b6', name: 'Golden Cartel', description: 'Royal gold shimmer with corner ornaments', category: StoreCategory.borders, priceSyndicate: 1500),
    StoreItemModel(id: 'b7', name: 'Glitch Syndicate', description: 'RGB glitch offset triple ring', category: StoreCategory.borders, priceSyndicate: 850),
    StoreItemModel(id: 'b8', name: 'Wraith Signal', description: 'Ghost-white fade breath', category: StoreCategory.borders, priceSyndicate: 700),
    StoreItemModel(id: 'b9', name: 'Toxic Enforcer', description: 'Acid green biohazard spin', category: StoreCategory.borders, priceSyndicate: 750),
    StoreItemModel(id: 'b10', name: 'Eclipse Boss', description: 'Solar-eclipse corona slow burn', category: StoreCategory.borders, priceSyndicate: 1300),
    StoreItemModel(id: 'b11', name: 'Dark Masquerade', description: 'Violet sweep with ornate mask silhouette dots', category: StoreCategory.borders, priceSyndicate: 1050),
    StoreItemModel(id: 'b12', name: 'Thunder Capo', description: 'Electric arc lightning flash', category: StoreCategory.borders, priceSyndicate: 950),
    StoreItemModel(id: 'b13', name: 'Obsidian Throne', description: 'Still black-gold engraved octagon', category: StoreCategory.borders, priceSyndicate: 1250),
    StoreItemModel(id: 'b14', name: 'Revenant', description: 'Undead teal mist drift', category: StoreCategory.borders, priceSyndicate: 850),
    StoreItemModel(id: 'b15', name: 'Digital Overlord', description: 'Matrix green raining tick', category: StoreCategory.borders, priceSyndicate: 900),
    StoreItemModel(id: 'b16', name: 'Crimson Veil', description: 'Slow-burn dark red veil pulse', category: StoreCategory.borders, priceSyndicate: 800),
    StoreItemModel(id: 'b17', name: 'Specter of the City', description: 'Dual-ring counter-rotate cyan/purple', category: StoreCategory.borders, priceSyndicate: 1100),
    StoreItemModel(id: 'b18', name: 'Godfather\'s Seal', description: 'Heavy gold ring with chain dots', category: StoreCategory.borders, priceSyndicate: 1600),
    StoreItemModel(id: 'b19', name: 'Nightfall Assassin', description: 'Invisible-to-visible knife-edge appear', category: StoreCategory.borders, priceSyndicate: 950),
    StoreItemModel(id: 'b20', name: 'Infernal Pact', description: 'Hell-fire radial blaze', category: StoreCategory.borders, priceSyndicate: 1400),
  ];
});

class StoreNotifier extends Notifier<bool> {
  final _api = StoreApiService();

  @override
  bool build() {
    return false; // isLoading state
  }

  Future<String?> purchase(StoreItemModel item) async {
    final user = ref.read(authProvider).user;
    if (user == null) return 'Session expired. Please log in.';

    final currency = item.priceSyndicate > 0 ? 'syndicate' : 'influence';
    final price = item.priceSyndicate > 0 ? item.priceSyndicate : item.priceInfluence;

    // Optimistic client-side validation
    if (currency == 'syndicate' && user.syndicateCoins < price) return 'Not enough Syndicate Coins';
    if (currency == 'influence' && user.influencePoints < price) return 'Not enough Influence Points';

    state = true;
    try {
      final response = await _api.purchaseItem(item.id, currency, price, item.category.name);
      
      if (response != null && response['new_balance'] != null) {
        // 1. Update Inventory locally
        final currentOwned = List<String>.from(user.inventory.getCategoryList(item.category.name));
        if (!currentOwned.contains(item.id)) {
          currentOwned.add(item.id);
        }

        // 2. Map back to InventoryModel
        InventoryModel updatedInventory = user.inventory;
        switch (item.category) {
          case StoreCategory.avatars:
            updatedInventory = user.inventory.copyWith(premiumAvatars: currentOwned);
            break;
          case StoreCategory.cardStyles:
            updatedInventory = user.inventory.copyWith(cardStyles: currentOwned);
            break;
          case StoreCategory.borders:
            updatedInventory = user.inventory.copyWith(borders: currentOwned);
            break;
          case StoreCategory.eliminationEffects:
            updatedInventory = user.inventory.copyWith(eliminationFx: currentOwned);
            break;
          case StoreCategory.voicePacks:
            updatedInventory = user.inventory.copyWith(voicePacks: currentOwned);
            break;
          case StoreCategory.bundles:
            updatedInventory = user.inventory.copyWith(bundles: currentOwned);
            break;
        }

        // 3. Update User locally with new balance AND inventory
        final updatedUser = user.copyWith(
          syndicateCoins: currency == 'syndicate' ? (response['new_balance'] as num).toInt() : user.syndicateCoins,
          influencePoints: currency == 'influence' ? (response['new_balance'] as num).toInt() : user.influencePoints,
          inventory: updatedInventory,
        );
        
        ref.read(authProvider.notifier).updateUserLocal(updatedUser);
        state = false;
        return null; // Success
      }
      state = false;
      return 'Unexpected server response';
    } catch (e) {
      state = false;
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> equip(StoreItemModel item) async {
    final user = ref.read(authProvider).user;
    if (user == null) return 'Session expired. Please log in.';

    state = true;
    try {
      final response = await _api.equipItem(item.id, item.category.name);
      
      if (response != null && response['equipped_cosmetics'] != null) {
        // Update user locally
        final updatedCosmetics = EquippedCosmeticsModel.fromJson(response['equipped_cosmetics']);
        UserModel updatedUser = user.copyWith(equippedCosmetics: updatedCosmetics);
        
        if (item.category == StoreCategory.avatars) {
           updatedUser = updatedUser.copyWith(
             premiumAvatarId: response['premium_avatar'],
             // using_premium_avatar logic? Maybe add to UserModel if needed, 
             // but for now avatarUrl/premiumAvatarId is enough.
           );
        }

        ref.read(authProvider.notifier).updateUserLocal(updatedUser);
        state = false;
        return null; // Success
      }
      state = false;
      return 'Unexpected server response';
    } catch (e) {
      state = false;
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}

final storeProvider = NotifierProvider<StoreNotifier, bool>(StoreNotifier.new);

/// Provider that combines store definitions with current user ownership state
final ownedStoreItemsProvider = Provider<List<StoreItemModel>>((ref) {
  final items = ref.watch(storeItemsProvider);
  final user = ref.watch(authProvider).user;
  
  if (user == null) return items;

  return items.map((item) {
    final ownedList = user.inventory.getCategoryList(item.category.name);
    final isOwned = ownedList.contains(item.id);
    
    bool isEquipped = false;
    final ec = user.equippedCosmetics;
    switch (item.category) {
      case StoreCategory.cardStyles:
        isEquipped = ec.background == item.id;
        break;
      case StoreCategory.borders:
        isEquipped = ec.cardBorder == item.id;
        break;
      case StoreCategory.voicePacks:
        isEquipped = ec.voicePack == item.id;
        break;
      case StoreCategory.avatars:
        isEquipped = user.premiumAvatarId == item.id;
        break;
      case StoreCategory.eliminationEffects:
        isEquipped = ec.nameplate == item.id;
        break;
      default:
        break;
    }

    return StoreItemModel(
      id: item.id,
      name: item.name,
      description: item.description,
      category: item.category,
      priceInfluence: item.priceInfluence,
      priceSyndicate: item.priceSyndicate,
      previewImageUrl: item.previewImageUrl,
      isOwned: isOwned,
      isEquipped: isEquipped,
      isLimited: item.isLimited,
    );
  }).toList();
});

