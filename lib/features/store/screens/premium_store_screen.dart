import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../widgets/neon_text.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/payment_provider.dart';

class PremiumStoreScreen extends ConsumerStatefulWidget {
  const PremiumStoreScreen({super.key});

  @override
  ConsumerState<PremiumStoreScreen> createState() => _PremiumStoreScreenState();
}

class _PremiumStoreScreenState extends ConsumerState<PremiumStoreScreen> {
  Map<String, dynamic> _packages = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final packages = await ref.read(paymentProvider.notifier).getPackages();
    if (mounted) {
      setState(() {
        if (packages != null) _packages = packages;
        _isLoading = false;
      });
    }
  }

  void _onBuyPackage(String id, Map<String, dynamic> pack) {
    context.push('/premium-store/details', extra: {
      'id': id,
      'data': pack,
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authProvider).user;
    
    final scPacks = _packages.entries.where((e) => e.value['currency'] == 'syndicate_coins' && e.key != 'starter_pack').toList();
    final ipPacks = _packages.entries.where((e) => e.value['currency'] == 'influence').toList();
    final starterPack = _packages['starter_pack'];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back, color: AppColors.white70)),
                    const SizedBox(width: 16),
                    const Expanded(child: NeonText(text: 'PREMIUM STORE', fontSize: 20, color: AppColors.gold, glowRadius: 15)),
                    IconButton(
                      icon: const Icon(Icons.receipt_long, color: AppColors.white50),
                      onPressed: () => context.push('/transaction-history'),
                    ),
                  ],
                ),
              ),
              
              if (_isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.gold)))
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Starter Pack
                        if (starterPack != null) ...[
                          const Text('FEATURED OFFER', style: TextStyle(color: AppColors.white50, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          const SizedBox(height: 12),
                          _FeaturedCard(
                            id: 'starter_pack',
                            pack: starterPack,
                            onTap: () => _onBuyPackage('starter_pack', starterPack),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Syndicate Coins
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.diamond, color: AppColors.gold, size: 16)
                          ),
                          const SizedBox(width: 12),
                          const Text('SYNDICATE COINS', style: TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ]),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.80,
                          ),
                          itemCount: scPacks.length,
                          itemBuilder: (_, i) => _CurrencyCard(
                            id: scPacks[i].key,
                            pack: scPacks[i].value,
                            color: AppColors.gold,
                            icon: Icons.diamond,
                            onTap: () => _onBuyPackage(scPacks[i].key, scPacks[i].value),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Influence Points
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AppColors.cyan.withValues(alpha: 0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.toll, color: AppColors.cyan, size: 16)
                          ),
                          const SizedBox(width: 12),
                          const Text('GOLD COINS (IP)', style: TextStyle(color: AppColors.cyan, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ]),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.80,
                          ),
                          itemCount: ipPacks.length,
                          itemBuilder: (_, i) => _CurrencyCard(
                            id: ipPacks[i].key,
                            pack: ipPacks[i].value,
                            color: AppColors.cyan,
                            icon: Icons.toll,
                            onTap: () => _onBuyPackage(ipPacks[i].key, ipPacks[i].value),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> pack;
  final VoidCallback onTap;

  const _FeaturedCard({required this.id, required this.pack, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF5A189A), Color(0xFF1D2671)],
            begin: Alignment.topLeft, end: Alignment.bottomRight
          ),
          border: Border.all(color: AppColors.purpleNeon.withValues(alpha: 0.6), width: 1.5),
          boxShadow: [BoxShadow(color: AppColors.purpleNeon.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30, bottom: -30,
              child: Icon(Icons.auto_awesome, color: Colors.white.withValues(alpha: 0.1), size: 150),
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1), boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.2), blurRadius: 20)]),
                      child: const Icon(Icons.star, color: AppColors.gold, size: 54)
                    )
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(6)),
                          child: const Text('STARTER BUNDLE', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                        const SizedBox(height: 12),
                        Text('${pack['amount']} SC + ${pack['bonus']} BONUS', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))])),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]),
                          child: Text('\$${pack['price']}', style: const TextStyle(color: Color(0xFF1D2671), fontSize: 14, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> pack;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _CurrencyCard({required this.id, required this.pack, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final amount = pack['amount'] as int;
    final bonus = pack['bonus'] as int;
    final price = pack['price'] as num;
    final hasBonus = bonus > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.surface, color.withValues(alpha: 0.05)]
          ),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 6))],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.1)),
                  child: Icon(icon, color: color, size: 40)
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$amount', style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
                  ],
                ),
                if (hasBonus) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.mintGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                    child: Text('+$bonus BONUS', style: const TextStyle(color: AppColors.mintGreen, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  ),
                ] else const SizedBox(height: 18),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                    border: Border(top: BorderSide(color: color.withValues(alpha: 0.2)))
                  ),
                  child: Center(child: Text('\$${price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                ),
              ],
            ),
            if (hasBonus)
              Positioned(
                top: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.mintGreen,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(23), bottomLeft: Radius.circular(16)),
                  ),
                  child: const Text('HOT', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
