/// Store item model for premium cosmetics
class StoreItemModel {
  final String id;
  final String name;
  final String description;
  final StoreCategory category;
  final int priceInfluence; // 0 if not purchasable with influence
  final int priceSyndicate; // 0 if not purchasable with coins
  final String previewImageUrl;
  final bool isOwned;
  final bool isEquipped;
  final bool isLimited;
  final DateTime? expiresAt;

  const StoreItemModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.category,
    this.priceInfluence = 0,
    this.priceSyndicate = 0,
    this.previewImageUrl = '',
    this.isOwned = false,
    this.isEquipped = false,
    this.isLimited = false,
    this.expiresAt,
  });

  bool get isFree => priceInfluence == 0 && priceSyndicate == 0;
}

/// Store categories
enum StoreCategory {
  cardStyles,
  borders,
  eliminationEffects,
  voicePacks,
  avatars,
  bundles;

  String get displayName {
    switch (this) {
      case StoreCategory.cardStyles:
        return 'Card Styles';
      case StoreCategory.borders:
        return 'Borders';
      case StoreCategory.eliminationEffects:
        return 'Elimination FX';
      case StoreCategory.voicePacks:
        return 'Voice Packs';
      case StoreCategory.avatars:
        return 'Avatars';
      case StoreCategory.bundles:
        return 'Bundles';
    }
  }
}
