import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// MOTD announcement banner with glow animation
class FamilyAnnouncementBanner extends StatefulWidget {
  final String motd;
  final DateTime? updatedAt;
  const FamilyAnnouncementBanner({super.key, required this.motd, this.updatedAt});

  @override
  State<FamilyAnnouncementBanner> createState() => _FamilyAnnouncementBannerState();
}

class _FamilyAnnouncementBannerState extends State<FamilyAnnouncementBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(duration: const Duration(seconds: 2), vsync: this)
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _glow.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (widget.motd.isEmpty) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, _) {
        final g = _glow.value;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.gold.withValues(alpha: 0.05 + g * 0.03),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.2 + g * 0.1)),
            boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.05 + g * 0.05), blurRadius: 12)],
          ),
          child: Row(children: [
            Icon(Icons.campaign, color: AppColors.gold.withValues(alpha: 0.7 + g * 0.3), size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(widget.motd,
              style: TextStyle(color: AppColors.gold.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w500))),
            Icon(Icons.push_pin, color: AppColors.gold.withValues(alpha: 0.3), size: 14),
          ]),
        );
      },
    );
  }
}
