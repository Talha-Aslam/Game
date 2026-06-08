import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/store_item_model.dart';
import '../models/user_model.dart';
import '../services/store_api_service.dart';
import 'auth_provider.dart';

final storeItemsProvider = Provider<List<StoreItemModel>>((ref) {
  return const [
    StoreItemModel(id: 's1', name: 'Crimson Flame', description: 'A fiery card border', category: StoreCategory.borders, priceSyndicate: 500),
    StoreItemModel(id: 's2', name: 'Neon Circuit', description: 'Cyberpunk card style', category: StoreCategory.cardStyles, priceSyndicate: 750),
    StoreItemModel(id: 's3', name: 'Shatter FX', description: 'Glass shatter elimination', category: StoreCategory.eliminationEffects, priceSyndicate: 1000),
    StoreItemModel(id: 's4', name: 'Deep Voice', description: 'Low pitch voice pack', category: StoreCategory.voicePacks, priceInfluence: 5000),
    StoreItemModel(id: 's5', name: 'Ghost Avatar', description: 'Spectral avatar frame', category: StoreCategory.avatars, priceInfluence: 3000),
    StoreItemModel(id: 's6', name: 'Syndicate Bundle', description: 'Premium elite bundle', category: StoreCategory.bundles, priceSyndicate: 2000, isLimited: true),
    StoreItemModel(id: 's7', name: 'Ice Aura', description: 'Frozen border effect', category: StoreCategory.borders, priceSyndicate: 600),
    StoreItemModel(id: 's8', name: 'Royal Gold', description: 'Gold plated card style', category: StoreCategory.cardStyles, priceSyndicate: 900),
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
        // Fix the logout bug: Update user locally instead of ref.invalidate(authProvider)
        final updatedUser = currency == 'syndicate' 
            ? user.copyWith(syndicateCoins: (response['new_balance'] as num).toInt())
            : user.copyWith(influencePoints: (response['new_balance'] as num).toInt());
        
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

