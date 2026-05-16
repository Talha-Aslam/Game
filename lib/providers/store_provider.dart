import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/store_item_model.dart';

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
