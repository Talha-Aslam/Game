import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Tier purchase dialog with slider
class TierPurchaseDialog extends StatefulWidget {
  final int currentTier;
  final int maxTier;
  final int costPerTier;
  final void Function(int count)? onPurchase;

  const TierPurchaseDialog({
    super.key, required this.currentTier, required this.maxTier,
    this.costPerTier = 100, this.onPurchase,
  });

  static void show(BuildContext context, {
    required int currentTier, required int maxTier,
    int costPerTier = 100, void Function(int)? onPurchase,
  }) {
    showDialog(context: context, builder: (_) => TierPurchaseDialog(
      currentTier: currentTier, maxTier: maxTier,
      costPerTier: costPerTier, onPurchase: onPurchase,
    ));
  }

  @override
  State<TierPurchaseDialog> createState() => _TierPurchaseDialogState();
}

class _TierPurchaseDialogState extends State<TierPurchaseDialog> {
  late int _count;
  int get _maxPurchasable => widget.maxTier - widget.currentTier;

  @override
  void initState() { super.initState(); _count = 1.clamp(1, _maxPurchasable); }

  @override
  Widget build(BuildContext context) {
    final cost = _count * widget.costPerTier;
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(padding: const EdgeInsets.all(24), child: Column(
        mainAxisSize: MainAxisSize.min, children: [
          Text('BUY TIERS', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.cyan)),
          const SizedBox(height: 8),
          Text('Skip ahead instantly', style: AppTextStyles.bodySmall),
          const SizedBox(height: 20),
          // Current → Target
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _TierNum(widget.currentTier, 'Current'),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.arrow_forward, color: AppColors.cyan, size: 20)),
            _TierNum(widget.currentTier + _count, 'Target'),
          ]),
          const SizedBox(height: 20),
          // Slider
          Row(children: [
            const Text('1', style: TextStyle(color: AppColors.white30, fontSize: 10)),
            Expanded(child: Slider(
              value: _count.toDouble(), min: 1, max: _maxPurchasable.toDouble(),
              divisions: _maxPurchasable > 1 ? _maxPurchasable - 1 : 1,
              activeColor: AppColors.cyan, inactiveColor: AppColors.white10,
              onChanged: (v) => setState(() => _count = v.round()),
            )),
            Text('$_maxPurchasable', style: const TextStyle(color: AppColors.white30, fontSize: 10)),
          ]),
          Text('$_count tiers', style: TextStyle(color: AppColors.cyan, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          // Cost + Purchase
          GestureDetector(
            onTap: () { widget.onPurchase?.call(_count); Navigator.of(context).pop(); },
            child: Container(
              width: double.infinity, height: 48,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(colors: [AppColors.cyan, Color(0xFF0091EA)])),
              child: Center(child: Text('PURCHASE — $cost SC',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.5))),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.white30))),
        ],
      )),
    );
  }
}

class _TierNum extends StatelessWidget {
  final int tier; final String label;
  const _TierNum(this.tier, this.label);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(
        shape: BoxShape.circle, color: AppColors.cyan.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3))),
        child: Center(child: Text('$tier', style: const TextStyle(
          color: AppColors.cyan, fontSize: 18, fontWeight: FontWeight.w800)))),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: AppColors.white30, fontSize: 9)),
    ]);
  }
}
