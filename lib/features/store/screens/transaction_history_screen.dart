import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/payment_provider.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('Transaction History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: history.isEmpty
          ? const Center(child: Text('No transactions yet.', style: TextStyle(color: AppColors.white50)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, i) {
                final tx = history[i];
                final isSuccess = tx['status'] == 'SUCCESS';
                final date = DateTime.parse(tx['timestamp']).toLocal();
                final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tx['package_id'].toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('\$${tx['price']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formattedDate, style: const TextStyle(color: AppColors.white50, fontSize: 12)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSuccess ? AppColors.online.withValues(alpha: 0.1) : AppColors.crimsonRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(tx['status'], style: TextStyle(color: isSuccess ? AppColors.online : AppColors.crimsonRed, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('TX ID: ${tx['transaction_id']}', style: const TextStyle(color: AppColors.white30, fontSize: 10)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
