import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/family_provider.dart';

/// Admin audit log — Boss/Underboss only
class FamilyAuditLogScreen extends ConsumerWidget {
  const FamilyAuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(familyProvider).auditLog;
    return Scaffold(body: Container(
      decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
      child: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          GestureDetector(onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: AppColors.white70)),
          const SizedBox(width: 16),
          Text('Audit Log', style: AppTextStyles.headlineMedium),
        ])),
        Expanded(child: log.isEmpty
          ? Center(child: Text('No activity yet', style: AppTextStyles.bodyMedium))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: log.length,
              itemBuilder: (_, i) {
                final entry = log[i];
                final timeAgo = DateTime.now().difference(entry.timestamp);
                final timeStr = timeAgo.inHours > 24
                    ? '${timeAgo.inDays}d ago'
                    : timeAgo.inHours > 0
                        ? '${timeAgo.inHours}h ago'
                        : '${timeAgo.inMinutes}m ago';
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                    color: AppColors.white05, border: Border.all(color: AppColors.glassBorder)),
                  child: Row(children: [
                    Container(width: 32, height: 32, decoration: BoxDecoration(
                      shape: BoxShape.circle, color: entry.action.color.withValues(alpha: 0.12)),
                      child: Icon(entry.action.icon, color: entry.action.color, size: 16)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(entry.description, style: AppTextStyles.labelMedium, maxLines: 2),
                      Text(timeStr, style: AppTextStyles.labelSmall),
                    ])),
                  ]),
                );
              },
            )),
      ])),
    ));
  }
}
