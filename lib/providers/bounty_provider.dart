import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bounty_model.dart';
import '../services/bounty_api_service.dart';

final bountyApiServiceProvider = Provider((ref) => BountyApiService());

final bountiesProvider =
    AsyncNotifierProvider<BountiesNotifier, List<BountyModel>>(() {
      return BountiesNotifier();
    });

class BountiesNotifier extends AsyncNotifier<List<BountyModel>> {
  late final BountyApiService _apiService;

  @override
  FutureOr<List<BountyModel>> build() async {
    _apiService = ref.read(bountyApiServiceProvider);
    return _apiService.getDailyBounties();
  }

  Future<void> fetchBounties() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _apiService.getDailyBounties());
  }

  Future<bool> claimBounty(String bountyId) async {
    final success = await _apiService.claimBounty(bountyId);
    if (success) {
      // Refresh bounties
      await fetchBounties();
    }
    return success;
  }
}
