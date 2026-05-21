import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/social/popularity_model.dart';

/// Gift selection dialog for sending popularity
class PopularityGiftDialog extends StatefulWidget {
  final String targetUserId;
  final String targetUsername;
  final int dailyFreeRemaining;
  final int availableCoins;
  final Function(PopularityGift gift) onSendGift;

  const PopularityGiftDialog({
    super.key,
    required this.targetUserId,
    required this.targetUsername,
    required this.dailyFreeRemaining,
    required this.availableCoins,
    required this.onSendGift,
  });

  static Future<void> show(
    BuildContext context, {
    required String targetUserId,
    required String targetUsername,
    required int dailyFreeRemaining,
    required int availableCoins,
    required Function(PopularityGift) onSendGift,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => PopularityGiftDialog(
        targetUserId: targetUserId,
        targetUsername: targetUsername,
        dailyFreeRemaining: dailyFreeRemaining,
        availableCoins: availableCoins,
        onSendGift: onSendGift,
      ),
    );
  }

  @override
  State<PopularityGiftDialog> createState() => _PopularityGiftDialogState();
}

class _PopularityGiftDialogState extends State<PopularityGiftDialog> {
  PopularityGift? _selected;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.surface,
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.1),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Send Popularity',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'to ${widget.targetUsername}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            // Free gifts section
            _SectionHeader(
              title: 'Free Gifts',
              subtitle: '${widget.dailyFreeRemaining}/5 remaining today',
            ),
            const SizedBox(height: 8),
            _buildGiftGrid(PopularityGift.freeGifts),
            const SizedBox(height: 16),
            // Premium gifts section
            _SectionHeader(
              title: 'Premium Gifts',
              subtitle: '${widget.availableCoins} coins available',
            ),
            const SizedBox(height: 8),
            _buildGiftGrid(PopularityGift.premiumGifts),
            const SizedBox(height: 20),
            // Send button
            GestureDetector(
              onTap: _selected != null
                  ? () {
                      widget.onSendGift(_selected!);
                      Navigator.of(context).pop();
                    }
                  : null,
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: _selected != null
                      ? LinearGradient(colors: [
                          _selected!.color,
                          _selected!.color.withValues(alpha: 0.7),
                        ])
                      : null,
                  color: _selected == null ? AppColors.white05 : null,
                  border: _selected == null
                      ? Border.all(color: AppColors.glassBorder)
                      : null,
                  boxShadow: _selected != null
                      ? [
                          BoxShadow(
                            color: _selected!.color.withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _selected != null
                        ? 'SEND ${_selected!.name.toUpperCase()}'
                        : 'SELECT A GIFT',
                    style: TextStyle(
                      color: _selected != null
                          ? Colors.white
                          : AppColors.white30,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftGrid(List<PopularityGift> gifts) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: gifts.map((gift) {
        final isSelected = _selected?.id == gift.id;
        final canAfford = gift.isPremium
            ? widget.availableCoins >= gift.cost
            : widget.dailyFreeRemaining > 0;

        return GestureDetector(
          onTap: canAfford ? () => setState(() => _selected = gift) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isSelected
                  ? gift.color.withValues(alpha: 0.15)
                  : AppColors.white05,
              border: Border.all(
                color: isSelected
                    ? gift.color.withValues(alpha: 0.6)
                    : AppColors.glassBorder,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: gift.color.withValues(alpha: 0.2),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: Opacity(
              opacity: canAfford ? 1.0 : 0.4,
              child: Column(
                children: [
                  Icon(gift.icon, color: gift.color, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    gift.name,
                    style: TextStyle(
                      color: gift.color,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    gift.isPremium ? '${gift.cost} 💎' : '+${gift.value}',
                    style: TextStyle(
                      color: AppColors.white30,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.white70),
        ),
        Text(subtitle, style: AppTextStyles.labelSmall),
      ],
    );
  }
}
