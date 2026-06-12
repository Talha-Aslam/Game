import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/payment_api_service.dart';
import 'auth_provider.dart';

class PaymentNotifier extends Notifier<List<dynamic>> {
  final _api = PaymentApiService();

  @override
  List<dynamic> build() {
    _fetchHistory();
    return [];
  }

  Future<void> _fetchHistory() async {
    final history = await _api.getHistory();
    if (history != null) {
      state = history;
    }
  }

  Future<Map<String, dynamic>?> processPayment({
    required String packageId,
    required double price,
    required String transactionId,
    required String statusCode,
  }) async {
    final result = await _api.processPayment(
      packageId: packageId,
      price: price,
      transactionId: transactionId,
      statusCode: statusCode,
    );
    
    if (result != null) {
      // Sync profile to update coins
      final authService = ref.read(authServiceProvider);
      final user = await authService.fetchProfile();
      if (user != null) {
        ref.read(authProvider.notifier).updateUserLocal(user);
      }
      _fetchHistory();
    }
    return result;
  }

  Future<Map<String, dynamic>?> getPackages() async {
    return await _api.getPackages();
  }
}

final paymentProvider = NotifierProvider<PaymentNotifier, List<dynamic>>(PaymentNotifier.new);
