import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/http_service.dart';
import '../models/rank_model.dart';

class RankingModel {
  final int rank;
  final String username;
  final String avatarUrl;
  final int level;
  final int mmr;
  final bool isMe;
  final RankModel rankInfo;

  RankingModel({
    required this.rank,
    required this.username,
    required this.avatarUrl,
    required this.level,
    required this.mmr,
    required this.rankInfo,
    this.isMe = false,
  });

  factory RankingModel.fromJson(Map<String, dynamic> json) {
    final mmr = json['mmr'] ?? 0;
    return RankingModel(
      rank: json['rank'] ?? 0,
      username: json['username'] ?? 'Unknown',
      avatarUrl: json['avatarUrl'] ?? '',
      level: json['level'] ?? 1,
      mmr: mmr,
      isMe: json['is_me'] ?? false,
      rankInfo: RankModel.fromPoints(mmr),
    );
  }
}

final rankingsProvider = FutureProvider<List<RankingModel>>((ref) async {
  final http = HttpService();
  final response = await http.get('/user/rankings');
  if (response is List) {
    return response.map((e) => RankingModel.fromJson(e)).toList();
  }
  return [];
});
