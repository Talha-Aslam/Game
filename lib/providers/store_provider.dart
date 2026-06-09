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

    // NEW PREMIUM CALLING CARDS
    StoreItemModel(id: 'cc1', name: 'Neon Overdrive', description: 'High-tech synthwave style', category: StoreCategory.cardStyles, priceSyndicate: 1200),
    StoreItemModel(id: 'cc2', name: 'Syndicate Executive', description: 'Carbon fiber elite style', category: StoreCategory.cardStyles, priceSyndicate: 1500),
    StoreItemModel(id: 'cc3', name: 'Crimson Vendetta', description: 'Tactical hazard style', category: StoreCategory.cardStyles, priceSyndicate: 1100),
    StoreItemModel(id: 'cc4', name: 'Cosmic Shadow', description: 'Interstellar nebula style', category: StoreCategory.cardStyles, priceSyndicate: 1300),
    StoreItemModel(id: 'cc5', name: 'Toxic Underworld', description: 'Biohazard industrial style', category: StoreCategory.cardStyles, priceSyndicate: 1000),

    // NEW PREMIUM ANIMATED BORDERS
    StoreItemModel(id: 'b1', name: 'Neon Overdrive', description: 'Animated synthwave border', category: StoreCategory.borders, priceSyndicate: 800),
    StoreItemModel(id: 'b2', name: 'Syndicate Boss', description: 'Pulsing gold VIP border', category: StoreCategory.borders, priceSyndicate: 1200),
    StoreItemModel(id: 'b3', name: 'Crimson Vendetta', description: 'Heartbeat tactical border', category: StoreCategory.borders, priceSyndicate: 750),
    StoreItemModel(id: 'b4', name: 'Cosmic Void', description: 'Nebula starlight border', category: StoreCategory.borders, priceSyndicate: 900),
    StoreItemModel(id: 'b5', name: 'Radioactive Underworld', description: 'Glowing toxic border', category: StoreCategory.borders, priceSyndicate: 850),
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

