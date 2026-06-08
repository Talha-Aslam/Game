import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/http_service.dart';

class MatchHistoryModel {
  final String id;
  final bool won;
  final String mode;
  final String role;
  final DateTime timestamp;
  final int xpGained;

  MatchHistoryModel({
    required this.id,
    required this.won,
    required this.mode,
    required this.role,
    required this.timestamp,
    required this.xpGained,
  });

  factory MatchHistoryModel.fromJson(Map<String, dynamic> json) {
    return MatchHistoryModel(
      id: json['id'] ?? '',
      won: json['won'] ?? false,
      mode: json['mode'] ?? 'Unknown',
      role: json['role'] ?? 'Unknown',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      xpGained: json['xp_gained'] ?? 0,
    );
  }
}

final recentMatchesProvider = FutureProvider<List<MatchHistoryModel>>((ref) async {
  final http = HttpService();
  final response = await http.get('/user/recent-matches');
  if (response is List) {
    return response.map((e) => MatchHistoryModel.fromJson(e)).toList();
  }
  return [];
});
