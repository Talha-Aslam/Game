import '../../../services/http_service.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mafia_wars/providers/custom_room_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/social_provider.dart';
import '../../../widgets/neon_text.dart';
import '../../../widgets/glass_button.dart';
import '../widgets/lobby_player_card.dart';
import '../../../models/player_model.dart';
import '../../../providers/matchmaking_provider.dart';

class CustomRoomScreen extends ConsumerWidget {
  const CustomRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomState = ref.watch(customRoomProvider);
    final user = ref.watch(authProvider).user;
    final isHost = roomState.creatorId == user?.id;

    ref.listen(customRoomProvider, (prev, next) {
      if (next.isStarted && next.roomId != null) {
        ref.read(gameProvider.notifier).connectToGame(next.roomId!);
        context.go('/game');
      } else if (next.wasKicked) {
        context.go('/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have been kicked from the custom room.'),
            backgroundColor: AppColors.crimsonRed,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(webSocketServiceProvider).send('leave_custom');
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.white70,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: NeonText(
                          text: 'CUSTOM ROOM',
                          fontSize: 22,
                          color: AppColors.cyan,
                          glowRadius: 15,
                        ),
                      ),
                      if (roomState.roomId != null)
                        GestureDetector(
                          onTap: () {
                            final code = roomState.roomId!.split('_').last;
                            Clipboard.setData(ClipboardData(text: code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Room ID copied!'),
                                backgroundColor: AppColors.cyan,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white05,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'ID: ${roomState.roomId!.split('_').last}',
                                  style: const TextStyle(
                                    color: AppColors.cyan,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.copy, color: AppColors.cyan, size: 12),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: 15,
                    itemBuilder: (context, index) {
                      if (index < roomState.players.length) {
                        final player = roomState.players[index];
                        final isMe = player.id == user?.id;
                        final isPlayerHost = roomState.creatorId == player.id;
                        
                        return LobbyPlayerCard(
                          player: player,
                          size: 60,
                          isLocalPlayer: isMe,
                          isHost: isPlayerHost,
                          onTap: (isHost && !isMe) ? () {
                            _showKickSheet(context, ref, player);
                          } : null,
                        );
                      }
                      return _EmptySlot(index: index + 1);
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: 'INVITE FRIENDS',
                          isOutlined: true,
                          glowColor: AppColors.cyan,
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => const _InviteSheet(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassButton(
                          label: isHost ? 'START MATCH' : 'WAITING...',
                          glowColor: isHost
                              ? AppColors.mintGreen
                              : AppColors.white30,
                          onPressed: isHost && roomState.players.length >= 5
                              ? () => ref
                                    .read(customRoomProvider.notifier)
                                    .startMatch()
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showKickSheet(BuildContext context, WidgetRef ref, PlayerModel target) {
     showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.crimsonRed.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('REMOVE PLAYER?', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.crimsonRed)),
              const SizedBox(height: 16),
              Text('Do you want to kick ${target.name} from the room?', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 24),
              GlassButton(
                label: 'KICK PLAYER',
                glowColor: AppColors.crimsonRed,
                onPressed: () {
                  ref.read(webSocketServiceProvider).send('kick_custom', {'target_id': target.id});
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteSheet extends ConsumerStatefulWidget {
  const _InviteSheet();
  @override
  ConsumerState<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<_InviteSheet> {
  List<PlayerModel> _globalPlayers = [];
  bool _isLoadingGlobal = true;

  @override
  void initState() {
    super.initState();
    _fetchGlobal();
  }

  Future<void> _fetchGlobal() async {
    setState(() => _isLoadingGlobal = true);
    try {
      final http = HttpService();
      final res = await http.get('/social/online-global');
      if (res is List) {
        _globalPlayers = res.map((e) => PlayerModel(
          id: e['id'] ?? '',
          name: e['username'] ?? 'Unknown',
          avatarUrl: e['avatarUrl'] ?? '',
        )).toList();
      }
    } catch (e) {
       // Ignore
    } finally {
      if (mounted) setState(() => _isLoadingGlobal = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendsState = ref.watch(friendsProvider);
    final roomState = ref.watch(customRoomProvider);
    
    // Filter out people already in room
    final inRoomIds = roomState.players.map((p) => p.id).toSet();
    final availableFriends = friendsState.onlineFriends.where((f) => !inRoomIds.contains(f.id)).toList();
    final availableGlobal = _globalPlayers.where((p) => !inRoomIds.contains(p.id)).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.white10),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 16, bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.white10,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const TabBar(
              indicatorColor: AppColors.cyan,
              labelColor: AppColors.cyan,
              unselectedLabelColor: AppColors.white30,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: 'FRIENDS'),
                Tab(text: 'GLOBAL'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Friends Tab
                  availableFriends.isEmpty
                      ? const Center(
                          child: Text(
                            'No available friends online.',
                            style: TextStyle(color: AppColors.white30),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: availableFriends.length,
                          itemBuilder: (ctx, i) {
                            final friend = availableFriends[i];
                            return ListTile(
                              leading: ClipOval(
                                child: CircleAvatar(
                                  backgroundImage: friend.avatarUrl.isNotEmpty
                                      ? NetworkImage(friend.avatarUrl)
                                      : null,
                                  backgroundColor: AppColors.purpleNeon
                                      .withValues(alpha: 0.2),
                                  child: friend.avatarUrl.isEmpty
                                      ? Text(
                                          friend.username[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: AppColors.purpleNeon,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              title: Text(
                                friend.username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: const Text(
                                'Online',
                                style: TextStyle(
                                  color: AppColors.mintGreen,
                                  fontSize: 10,
                                ),
                              ),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.cyan.withValues(
                                    alpha: 0.1,
                                  ),
                                  foregroundColor: AppColors.cyan,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: AppColors.cyan.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  final roomId = roomState.roomId;
                                  if (roomId != null) {
                                    ref.read(webSocketServiceProvider).send(
                                      'invite_custom',
                                      {
                                        'target_id': friend.id,
                                        'room_id': roomId,
                                      },
                                    );
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Invite sent to ${friend.username}',
                                        ),
                                        backgroundColor: AppColors.cyan,
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'INVITE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  // Global Tab
                  _isLoadingGlobal 
                    ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                    : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: availableGlobal.length,
                    itemBuilder: (ctx, i) {
                      final player = availableGlobal[i];
                      return ListTile(
                        leading: ClipOval(
                          child: CircleAvatar(
                            backgroundImage: player.avatarUrl.isNotEmpty
                                ? NetworkImage(player.avatarUrl)
                                : null,
                            backgroundColor: AppColors.gold.withValues(
                              alpha: 0.2,
                            ),
                            child: player.avatarUrl.isEmpty 
                                ? Text(
                              player.name[0].toUpperCase(),
                              style: const TextStyle(color: AppColors.gold),
                            ) : null,
                          ),
                        ),
                        title: Text(
                          player.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'In Lobby',
                          style: TextStyle(
                            color: AppColors.white30,
                            fontSize: 10,
                          ),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold.withValues(
                              alpha: 0.1,
                            ),
                            foregroundColor: AppColors.gold,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: AppColors.gold.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          onPressed: () {
                            final roomId = roomState.roomId;
                            if (roomId != null) {
                              ref.read(webSocketServiceProvider).send(
                                'invite_custom',
                                {'target_id': player.id, 'room_id': roomId},
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Invite sent to ${player.name}',
                                  ),
                                  backgroundColor: AppColors.gold,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'INVITE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final int index;
  const _EmptySlot({required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white05,
            border: Border.all(
              color: AppColors.white10,
              style: BorderStyle.none,
            ),
          ),
          child: Center(
            child: Text(
              '$index',
              style: const TextStyle(
                color: AppColors.white10,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'EMPTY',
          style: TextStyle(color: AppColors.white10, fontSize: 8),
        ),
      ],
    );
  }
}
