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
    final data = await _api.getPackages();
    if (data != null && data.isNotEmpty) return data;
    
    // AAA standard: Always provide a local fallback if backend catalog fails to load
    // so the user does not see an empty store.
    return {
      "pack_ip_small": {"currency": "influence", "amount": 500, "price": 0.99, "bonus": 0},
      "pack_ip_medium": {"currency": "influence", "amount": 1000, "price": 1.99, "bonus": 200},
      "pack_ip_large": {"currency": "influence", "amount": 2500, "price": 4.99, "bonus": 500},
      "pack_ip_mega": {"currency": "influence", "amount": 6000, "price": 9.99, "bonus": 1000},
      "pack_sc_small": {"currency": "syndicate_coins", "amount": 100, "price": 0.99, "bonus": 0},
      "pack_sc_medium": {"currency": "syndicate_coins", "amount": 500, "price": 4.99, "bonus": 50},
      "pack_sc_large": {"currency": "syndicate_coins", "amount": 1000, "price": 9.99, "bonus": 200},
      "pack_sc_mega": {"currency": "syndicate_coins", "amount": 2000, "price": 19.99, "bonus": 500},
      "starter_pack": {"currency": "syndicate_coins", "amount": 1000, "price": 4.99, "bonus": 500, "limit": 1},
    };
  }
}

final paymentProvider = NotifierProvider<PaymentNotifier, List<dynamic>>(PaymentNotifier.new);
