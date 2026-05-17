import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/family_provider.dart';
import '../widgets/family_search_card.dart';

/// Search and discover families
class FamilySearchScreen extends ConsumerStatefulWidget {
  const FamilySearchScreen({super.key});
  @override
  ConsumerState<FamilySearchScreen> createState() => _FamilySearchScreenState();
}

class _FamilySearchScreenState extends ConsumerState<FamilySearchScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load all families on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(familyProvider.notifier).searchFamilies('');
    });
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(familyProvider).searchResults;
    return Scaffold(body: Container(
      decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
      child: SafeArea(child: Column(children: [
        // Header
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          GestureDetector(onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: AppColors.white70)),
          const SizedBox(width: 16),
          Text('Find Families', style: AppTextStyles.headlineMedium),
        ])),
        // Search bar
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: TextField(
          controller: _searchCtrl,
          onChanged: (q) => ref.read(familyProvider.notifier).searchFamilies(q),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search by name or tag...', hintStyle: const TextStyle(color: AppColors.white30),
            prefixIcon: const Icon(Icons.search, color: AppColors.white30, size: 20),
            filled: true, fillColor: AppColors.white05,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.glassBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.purpleNeon)),
          ),
        )),
        const SizedBox(height: 12),
        // Results
        Expanded(child: results.isEmpty
          ? Center(child: Text('No families found', style: AppTextStyles.bodyMedium))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.length,
              itemBuilder: (_, i) => FamilySearchCard(family: results[i], onJoin: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Applied to ${results[i].name}'),
                  behavior: SnackBarBehavior.floating));
              }),
            )),
      ])),
    ));
  }
}
