import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/store_provider.dart';
import '../../../providers/auth_provider.dart';
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
    final items = ref.watch(storeItemsProvider);
    final user = ref.watch(authProvider).user;
    final filtered = items.where((i) => i.category == _selectedCategory).toList();

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final success = await ref.read(storeProvider.notifier).purchase(item);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Purchase successful!' : 'Purchase failed. Check balance.'),
              backgroundColor: success ? AppColors.cyan : AppColors.crimsonRed,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.white05,
          border: Border.all(color: item.isLimited ? AppColors.gold.withValues(alpha: 0.4) : AppColors.glassBorder),
        ),
        child: Column(
          children: [
            // Preview area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  gradient: LinearGradient(colors: [AppColors.purpleDeep.withValues(alpha: 0.2), AppColors.cyan.withValues(alpha: 0.1)]),
                ),
                child: Stack(
                  children: [
                    Center(child: Icon(Icons.auto_awesome, color: AppColors.purpleGlow.withValues(alpha: 0.4), size: 40)),
                    if (item.isLimited)
                      Positioned(
                        top: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: AppColors.crimsonRed),
                          child: const Text('LIMITED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                        ),
                      ),
                  ],
                ),
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
      ),
    );
  }
}
