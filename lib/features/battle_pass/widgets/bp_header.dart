import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/battle_pass_model.dart';

/// Premium Battle Pass header with season info, XP bar, buttons
class BPHeader extends StatelessWidget {
  final BattlePassModel bp;
  final VoidCallback? onBuyPremium;
  final VoidCallback? onBuyTiers;
  final VoidCallback? onBoost;

  const BPHeader({super.key, required this.bp, this.onBuyPremium, this.onBuyTiers, this.onBoost});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AppColors.background, AppColors.background.withValues(alpha: 0.0)],
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Season + Timer
        Row(children: [
          Expanded(child: Text(bp.seasonName, style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.gold, letterSpacing: 1))),
          CountdownChip(endDate: bp.seasonEndDate),
        ]),
        const SizedBox(height: 10),
        // Tier + XP
        Row(children: [
          _TierBadge(tier: bp.currentTier),
          const SizedBox(width: 12),
          Expanded(child: _XPBar(xp: bp.currentXP, max: bp.xpToNextTier, hasBoost: bp.hasActiveBoost)),
          if (bp.hasActiveBoost) ...[
            const SizedBox(width: 8),
            _BoostBadge(boost: bp.activeBoost!),
          ],
        ]),
        const SizedBox(height: 10),
        // Action buttons
        Row(children: [
          if (!bp.isPremium) Expanded(child: _PremiumButton(onTap: onBuyPremium, cost: bp.premiumCost)),
          if (bp.isPremium) _PremiumBadge(isPlus: bp.isPremiumPlus),
          const SizedBox(width: 8),
          _ActionChip(Icons.shopping_cart, 'BUY TIERS', AppColors.cyan, onBuyTiers),
          const SizedBox(width: 8),
          _ActionChip(Icons.bolt, 'XP BOOST', AppColors.mintGreen, onBoost),
        ]),
      ]),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final int tier;
  const _TierBadge({required this.tier});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFFF8F00)]),
        boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.3), blurRadius: 12)],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('TIER', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w700, letterSpacing: 1)),
        Text('$tier', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
      ]),
    );
  }
}

class _XPBar extends StatelessWidget {
  final int xp; final int max; final bool hasBoost;
  const _XPBar({required this.xp, required this.max, this.hasBoost = false});
  @override
  Widget build(BuildContext context) {
    final p = max > 0 ? (xp / max).clamp(0.0, 1.0) : 0.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(hasBoost ? '2X XP ACTIVE' : 'XP Progress', style: TextStyle(
          color: hasBoost ? AppColors.mintGreen : AppColors.white30, fontSize: 9, fontWeight: FontWeight.w600)),
        Text('$xp / $max', style: const TextStyle(color: AppColors.white30, fontSize: 9)),
      ]),
      const SizedBox(height: 4),
      Container(height: 6, decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3), color: AppColors.white05,
        border: Border.all(color: AppColors.glassBorder)),
        child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: p,
          child: Container(decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: LinearGradient(colors: hasBoost
              ? [AppColors.mintGreen, const Color(0xFF00E5FF)]
              : [AppColors.gold, const Color(0xFFFF8F00)]),
            boxShadow: [BoxShadow(
              color: (hasBoost ? AppColors.mintGreen : AppColors.gold).withValues(alpha: 0.4), blurRadius: 6)])))),
    ]);
  }
}

class _BoostBadge extends StatefulWidget {
  final XPBoost boost;
  const _BoostBadge({required this.boost});
  @override
  State<_BoostBadge> createState() => _BoostBadgeState();
}

class _BoostBadgeState extends State<_BoostBadge> with SingleTickerProviderStateMixin {
  late AnimationController _glow;
  @override
  void initState() { super.initState(); _glow = AnimationController(duration: const Duration(seconds: 1), vsync: this)..repeat(reverse: true); }
  @override
  void dispose() { _glow.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _glow, builder: (_, _) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
        color: AppColors.mintGreen.withValues(alpha: 0.1 + _glow.value * 0.05),
        border: Border.all(color: AppColors.mintGreen.withValues(alpha: 0.3 + _glow.value * 0.2))),
      child: Text('2X', style: TextStyle(
        color: AppColors.mintGreen, fontSize: 12, fontWeight: FontWeight.w900)),
    ));
  }
}

class _PremiumButton extends StatefulWidget {
  final VoidCallback? onTap; final int cost;
  const _PremiumButton({this.onTap, required this.cost});
  @override
  State<_PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<_PremiumButton> with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;
  @override
  void initState() { super.initState(); _shimmer = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(); }
  @override
  void dispose() { _shimmer.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: widget.onTap, child: AnimatedBuilder(animation: _shimmer, builder: (_, _) {
      return Container(height: 36, decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFFF8F00), AppColors.gold]),
        boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.2 + _shimmer.value * 0.15), blurRadius: 12)]),
        child: Center(child: Text('⭐ PREMIUM — ${widget.cost} SC',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5))));
    }));
  }
}

class _PremiumBadge extends StatelessWidget {
  final bool isPlus;
  const _PremiumBadge({this.isPlus = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
        color: AppColors.gold.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3))),
      child: Text(isPlus ? '⭐ PREMIUM+' : '⭐ PREMIUM', style: const TextStyle(
        color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback? onTap;
  const _ActionChip(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.25))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 13), const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700)),
      ]),
    ));
  }
}

/// Countdown chip widget
class CountdownChip extends StatefulWidget {
  final DateTime endDate;
  const CountdownChip({super.key, required this.endDate});
  @override
  State<CountdownChip> createState() => _CountdownChipState();
}

class _CountdownChipState extends State<CountdownChip> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    final r = widget.endDate.difference(DateTime.now());
    setState(() => _remaining = r.isNegative ? Duration.zero : r);
  }

  @override
  void dispose() { _timer.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isUrgent = _remaining.inDays < 3;
    final color = isUrgent ? AppColors.crimsonRed : AppColors.white50;
    final d = _remaining.inDays;
    final h = _remaining.inHours % 24;
    final m = _remaining.inMinutes % 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.25))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.timer, color: color, size: 11),
        const SizedBox(width: 4),
        Text('${d}d ${h}h ${m}m', style: TextStyle(
          color: color, fontSize: 10, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
