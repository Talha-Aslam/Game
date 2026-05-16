class AvatarModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final AvatarRarity rarity;
  final int priceSyndicateCoins;
  final bool isAnimated;

  const AvatarModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rarity,
    this.priceSyndicateCoins = 0,
    this.isAnimated = false,
  });
}

enum AvatarRarity {
  common,
  rare,
  epic,
  legendary;

  String get displayName {
    switch (this) {
      case AvatarRarity.common:
        return 'Common';
      case AvatarRarity.rare:
        return 'Rare';
      case AvatarRarity.epic:
        return 'Epic';
      case AvatarRarity.legendary:
        return 'Legendary';
    }
  }
}
