import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/store_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/glass_button.dart';
import '../../../models/store_item_model.dart';
import '../../../widgets/neon_text.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});
  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  StoreCategory _selectedCategory = StoreCategory.cardStyles;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(ownedStoreItemsProvider);
    final user = ref.watch(authProvider).user;
    
    // Sort logic: Unowned first, Owned last
    final filtered = items.where((i) => i.category == _selectedCategory).toList();
    filtered.sort((a, b) {
      if (a.isOwned && !b.isOwned) return 1;
      if (!a.isOwned && b.isOwned) return -1;
      return 0;
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back, color: AppColors.white70)),
                    const SizedBox(width: 16),
                    const Expanded(child: NeonText(text: 'STORE', fontSize: 22, color: AppColors.cyan, glowRadius: 15)),
                    // Currency
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.cyan.withValues(alpha: 0.1), border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3))),
                      child: Row(children: [
                        const Icon(Icons.toll, color: AppColors.cyan, size: 14),
                        const SizedBox(width: 4),
                        Text('${user?.influencePoints ?? 0}', style: const TextStyle(color: AppColors.cyan, fontSize: 11, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.gold.withValues(alpha: 0.1), border: Border.all(color: AppColors.gold.withValues(alpha: 0.3))),
                      child: Row(children: [
                        const Icon(Icons.diamond, color: AppColors.gold, size: 14),
                        const SizedBox(width: 4),
                        Text('${user?.syndicateCoins ?? 0}', style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ],
                ),
              ),

              // Category tabs
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: StoreCategory.values.map((c) {
                    final isActive = c == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategory = c),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: isActive ? AppColors.cyan.withValues(alpha: 0.15) : AppColors.white05,
                            border: Border.all(color: isActive ? AppColors.cyan.withValues(alpha: 0.4) : AppColors.glassBorder),
                          ),
                          child: Center(child: Text(c.displayName, style: TextStyle(
                            color: isActive ? AppColors.cyan : AppColors.white50,
                            fontSize: 12, fontWeight: FontWeight.w600,
                          ))),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Items grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.75,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _StoreItemCard(item: filtered[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreItemCard extends ConsumerWidget {
  final StoreItemModel item;
  const _StoreItemCard({required this.item});

  void _showEquipSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: AppColors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: AppGradients.cardGradient,
                  boxShadow: [BoxShadow(color: AppColors.purpleNeon.withValues(alpha: 0.3), blurRadius: 20)],
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 16),
              Text(item.name, style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              Text(item.description, style: AppTextStyles.labelMedium.copyWith(color: AppColors.white70)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.isEquipped ? AppColors.white10 : AppColors.cyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: item.isEquipped ? null : () async {
                    final error = await ref.read(storeProvider.notifier).equip(item);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error ?? 'Item equipped successfully!'),
                          backgroundColor: error == null ? AppColors.cyan : AppColors.crimsonRed,
                        ),
                      );
                    }
                  },
                  child: Text(item.isEquipped ? 'EQUIPPED' : 'EQUIP NOW', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showPurchaseConfirmation(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider).user;
    final currency = item.priceSyndicate > 0 ? 'syndicate' : 'influence';
    final price = item.priceSyndicate > 0 ? item.priceSyndicate : item.priceInfluence;
    final balance = item.priceSyndicate > 0 ? (user?.syndicateCoins ?? 0) : (user?.influencePoints ?? 0);
    final canAfford = balance >= price;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: AppColors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60, height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(2)),
              ),
              Text('CONFIRM PURCHASE', style: AppTextStyles.labelMedium.copyWith(color: AppColors.white50, letterSpacing: 2)),
              const SizedBox(height: 20),
              Text(item.name, style: AppTextStyles.headlineMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Price: ', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white50)),
                  Icon(currency == 'syndicate' ? Icons.diamond : Icons.toll, color: currency == 'syndicate' ? AppColors.gold : AppColors.cyan, size: 16),
                  const SizedBox(width: 4),
                  Text('$price', style: TextStyle(color: currency == 'syndicate' ? AppColors.gold : AppColors.cyan, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Your Balance: $balance', style: AppTextStyles.labelSmall.copyWith(color: canAfford ? AppColors.white30 : AppColors.crimsonRed)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'CANCEL',
                      isOutlined: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GlassButton(
                      label: 'BUY NOW',
                      glowColor: canAfford ? AppColors.cyan : AppColors.white10,
                      onPressed: !canAfford ? null : () async {
                        Navigator.pop(context);
                        final error = await ref.read(storeProvider.notifier).purchase(item);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error ?? 'Purchase successful!'),
                              backgroundColor: error == null ? AppColors.cyan : AppColors.crimsonRed,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        if (item.isOwned) {
          _showEquipSheet(context, ref);
          return;
        }
        _showPurchaseConfirmation(context, ref);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.white05,
          border: Border.all(color: item.isEquipped ? AppColors.cyan : (item.isLimited ? AppColors.gold.withValues(alpha: 0.4) : AppColors.glassBorder)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Column(
                children: [
                  // Preview area
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.purpleDeep.withValues(alpha: 0.2), AppColors.cyan.withValues(alpha: 0.1)]),
                      ),
                      child: Center(child: Icon(Icons.auto_awesome, color: AppColors.purpleGlow.withValues(alpha: 0.4), size: 40)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: AppTextStyles.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(item.description, style: AppTextStyles.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (item.priceSyndicate > 0) ...[
                              Icon(Icons.diamond, color: AppColors.gold, size: 12),
                              const SizedBox(width: 2),
                              Text('${item.priceSyndicate}', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600)),
                            ] else if (item.priceInfluence > 0) ...[
                              Icon(Icons.toll, color: AppColors.cyan, size: 12),
                              const SizedBox(width: 2),
                              Text('${item.priceInfluence}', style: TextStyle(color: AppColors.cyan, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (item.isOwned)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.4),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.5)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: AppColors.cyan, size: 14),
                              SizedBox(width: 6),
                              Text('OWNED', style: TextStyle(color: AppColors.cyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              if (item.isLimited && !item.isOwned)
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: AppColors.crimsonRed),
                    child: const Text('LIMITED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                  ),
                ),
                
              if (item.isEquipped)
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: AppColors.cyan),
                    child: const Text('EQUIPPED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
