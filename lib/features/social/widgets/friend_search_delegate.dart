import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/social/friend_model.dart';
import 'friend_card_widget.dart';

/// Search delegate for finding friends/users by ID or username
class FriendSearchDelegate extends SearchDelegate<FriendModel?> {
  final Future<List<FriendModel>> Function(String query) onSearch;
  final void Function(FriendModel)? onAddFriend;

  FriendSearchDelegate({
    required this.onSearch,
    this.onAddFriend,
  }) : super(
          searchFieldLabel: 'Search by username or ID...',
          searchFieldStyle: AppTextStyles.bodyMedium,
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: AppColors.white30),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: AppColors.white50),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.white),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearch();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearch();

  Widget _buildSearch() {
    if (query.trim().isEmpty) {
      return Container(
        color: AppColors.background,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, color: AppColors.white10, size: 64),
              const SizedBox(height: 16),
              Text(
                'Search for players',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white30,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: AppColors.background,
      child: FutureBuilder<List<FriendModel>>(
        future: onSearch(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.purpleNeon),
            );
          }
          final results = snapshot.data ?? [];
          if (results.isEmpty) {
            return Center(
              child: Text(
                'No players found',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white30,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final player = results[index];
              return FriendCardWidget(
                friend: player,
                showActions: false,
                showAddFriend: true,
                onAddFriend: () => onAddFriend?.call(player),
                onViewProfile: () => close(context, player),
              );
            },
          );
        },
      ),
    );
  }
}
