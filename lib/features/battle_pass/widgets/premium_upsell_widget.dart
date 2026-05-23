import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Premium upsell widget — Premium vs Premium+ comparison
class PremiumUpsellWidget extends StatelessWidget {
  final int premiumCost;
  final int premiumPlusCost;
  final VoidCallback? onBuyPremium;
  final VoidCallback? onBuyPremiumPlus;

  const PremiumUpsellWidget({
    super.key, this.premiumCost = 999, this.premiumPlusCost = 1999,
    this.onBuyPremium, this.onBuyPremiumPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Premium
      _PlanCard(
        title: 'PREMIUM PASS', cost: premiumCost,
        color: AppColors.gold,
        features: const ['All Premium rewards', 'Exclusive cosmetics', 'Season exclusive items'],
        onTap: onBuyPremium,
      ),
      const SizedBox(height: 12),
      // Premium+
      _PlanCard(
        title: 'PREMIUM+ BUNDLE', cost: premiumPlusCost,
        color: AppColors.purpleGlow, isHighlighted: true,
        features: const [
          'All Premium rewards',
          '+20 Instant Tier Unlock',
          'Exclusive animated avatar',
          'Unique Premium+ border',
          'Bonus 500 SC',
        ],
        onTap: onBuyPremiumPlus,
      ),
    ]);
  }
}

class _PlanCard extends StatefulWidget {
  final String title; final int cost; final Color color;
  final List<String> features; final bool isHighlighted;
  final VoidCallback? onTap;
  const _PlanCard({required this.title, required this.cost, required this.color,
    required this.features, this.isHighlighted = false, this.onTap});
  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> with SingleTickerProviderStateMixin {
  late AnimationController _glow;
  @override
  void initState() { super.initState(); _glow = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true); }
  @override
  void dispose() { _glow.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _glow, builder: (_, _) {
      final g = _glow.value;
      return GestureDetector(onTap: widget.onTap, child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: widget.color.withValues(alpha: 0.04 + (widget.isHighlighted ? g * 0.03 : 0)),
          border: Border.all(color: widget.color.withValues(alpha: 0.2 + (widget.isHighlighted ? g * 0.15 : 0)), width: widget.isHighlighted ? 1.5 : 1),
          boxShadow: widget.isHighlighted ? [BoxShadow(
            color: widget.color.withValues(alpha: 0.08 + g * 0.06), blurRadius: 16)] : null,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(widget.title, style: TextStyle(color: widget.color, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1)),
            const Spacer(),
            if (widget.isHighlighted) Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),
                color: widget.color.withValues(alpha: 0.15)),
              child: const Text('BEST VALUE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 10),
          ...widget.features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              Icon(Icons.check, color: widget.color, size: 14),
              const SizedBox(width: 6),
              Text(f, style: AppTextStyles.labelSmall.copyWith(color: AppColors.white70)),
            ]),
          )),
          const SizedBox(height: 12),
          Container(width: double.infinity, height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(colors: [widget.color, widget.color.withValues(alpha: 0.7)])),
            child: Center(child: Text('${widget.cost} SC', style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)))),
        ]),
      ));
    });
  }
}
