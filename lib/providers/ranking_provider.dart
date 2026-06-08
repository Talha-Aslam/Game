import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/http_service.dart';

class RankingModel {
  final int rank;
  final String username;
  final String avatarUrl;
  final int level;
  final int mmr;
  final bool isMe;

  RankingModel({
    required this.rank,
    required this.username,
    required this.avatarUrl,
    required this.level,
    required this.mmr,
    this.isMe = false,
  });

  factory RankingModel.fromJson(Map<String, dynamic> json) {
    return RankingModel(
      rank: json['rank'] ?? 0,
      username: json['username'] ?? 'Unknown',
      avatarUrl: json['avatarUrl'] ?? '',
      level: json['level'] ?? 1,
      mmr: json['mmr'] ?? 0,
      isMe: json['is_me'] ?? false,
    );
  }
}

final rankingsProvider = FutureProvider<List<RankingModel>>((ref) async {
  final http = HttpService();
  final response = await http.get('/rankings');
  if (response is List) {
    return response.map((e) => RankingModel.fromJson(e)).toList();
  }
  return [];
});
