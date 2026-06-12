import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../widgets/neon_text.dart';
import '../../../providers/payment_provider.dart';
import 'package:uuid/uuid.dart';
import '../widgets/payment_checkout_dialog.dart';

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
    PaymentCheckoutDialog.show(
      context,
      packageId: id,
      packageData: pack,
      onConfirm: () async {
        // Show processing
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        );

        final transactionId = const Uuid().v4();
        // Simulate a tiny delay for payment gateway
        await Future.delayed(const Duration(seconds: 2));

        final result = await ref.read(paymentProvider.notifier).processPayment(
          packageId: id,
          price: (pack['price'] as num).toDouble(),
          transactionId: transactionId,
          statusCode: 'SUCCESS',
        );

        if (mounted) {
          Navigator.of(context).pop(); // pop processing
          if (result != null) {
            _showSuccess(pack);
          } else {
            _showError('Payment failed or declined.', id, pack);
          }
        }
      }
    );
  }

  void _showSuccess(Map<String, dynamic> pack) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5))),
        title: const Center(child: Icon(Icons.check_circle, color: AppColors.gold, size: 64)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('PAYMENT SUCCESSFUL', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('You received ${pack['amount'] + pack['bonus']} ${pack['currency'] == 'syndicate_coins' ? 'SC' : 'IP'}', style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('AWESOME', style: TextStyle(color: AppColors.gold)))
        ],
      )
    );
  }

  void _showError(String msg, String packageId, Map<String, dynamic> pack) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: AppColors.crimsonRed.withValues(alpha: 0.5))),
        title: const Center(child: Icon(Icons.error_outline, color: AppColors.crimsonRed, size: 64)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('PAYMENT FAILED', style: TextStyle(color: AppColors.crimsonRed, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 12),
            Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.crimsonRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  Navigator.of(context).pop();
                  _onBuyPackage(packageId, pack); // Retry
                },
                child: const Text('RETRY PAYMENT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.white30), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CHANGE PAYMENT METHOD', style: TextStyle(color: AppColors.white70)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Contact Support', style: TextStyle(color: AppColors.white30, decoration: TextDecoration.underline)),
            )
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    
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
                          const SizedBox(height: 24),
                        ],

                        // Syndicate Coins
                        Row(children: [
                          const Icon(Icons.diamond, color: AppColors.gold, size: 16),
                          const SizedBox(width: 8),
                          const Text('SYNDICATE COINS', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ]),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85,
                          ),
                          itemCount: scPacks.length,
                          itemBuilder: (_, i) => _CurrencyCard(
                            id: scPacks[i].key,
                            pack: scPacks[i].value,
                            color: AppColors.gold,
                            onTap: () => _onBuyPackage(scPacks[i].key, scPacks[i].value),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Influence Points
                        Row(children: [
                          const Icon(Icons.toll, color: AppColors.cyan, size: 16),
                          const SizedBox(width: 8),
                          const Text('GOLD COINS (IP)', style: TextStyle(color: AppColors.cyan, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ]),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85,
                          ),
                          itemCount: ipPacks.length,
                          itemBuilder: (_, i) => _CurrencyCard(
                            id: ipPacks[i].key,
                            pack: ipPacks[i].value,
                            color: AppColors.cyan,
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
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)]),
          boxShadow: [BoxShadow(color: const Color(0xFF8E2DE2).withValues(alpha: 0.4), blurRadius: 15)],
        ),
        child: Row(
          children: [
            const Expanded(
              flex: 2,
              child: Center(child: Icon(Icons.star, color: Colors.white, size: 64)),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
                      child: const Text('STARTER BUNDLE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(height: 8),
                    Text('${pack['amount']} SC + ${pack['bonus']} BONUS', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Text('\$${pack['price']}', style: const TextStyle(color: Color(0xFF4A00E0), fontSize: 14, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
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
  final VoidCallback onTap;

  const _CurrencyCard({required this.id, required this.pack, required this.color, required this.onTap});

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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(color == AppColors.gold ? Icons.diamond : Icons.toll, color: color, size: 48),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$amount', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
                    if (hasBonus) ...[
                      const SizedBox(width: 4),
                      Text('+$bonus', style: const TextStyle(color: AppColors.mintGreen, fontSize: 12, fontWeight: FontWeight.w800)),
                    ]
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('\$${price.toStringAsFixed(2)}', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            if (hasBonus)
              Positioned(
                top: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.mintGreen,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(18), bottomLeft: Radius.circular(10)),
                  ),
                  child: const Text('BONUS', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
