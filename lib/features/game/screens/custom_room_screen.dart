import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/matchmaking_provider.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neon_text.dart';
import '../../../widgets/glass_button.dart';
import '../../../models/player_model.dart';
import '../widgets/lobby_player_card.dart';

class CustomRoomState {
  final String? roomId;
  final String? creatorId;
  final List<PlayerModel> players;
  final bool isStarted;

  CustomRoomState({
    this.roomId,
    this.creatorId,
    this.players = const [],
    this.isStarted = false,
  });

  CustomRoomState copyWith({
    String? roomId,
    String? creatorId,
    List<PlayerModel>? players,
    bool? isStarted,
  }) {
    return CustomRoomState(
      roomId: roomId ?? this.roomId,
      creatorId: creatorId ?? this.creatorId,
      players: players ?? this.players,
      isStarted: isStarted ?? this.isStarted,
    );
  }
}

class CustomRoomNotifier extends Notifier<CustomRoomState> {
  @override
  CustomRoomState build() {
    final ws = ref.read(webSocketServiceProvider);
    ws.eventStream.listen((msg) {
      if (msg.event == 'custom_room_update') {
        final data = msg.data;
        final List<dynamic> pIds = data['players'] ?? [];
        
        // We'd ideally fetch player details here, but for now we'll map them 
        // using what we have in the lobby payload structure
        final List<PlayerModel> players = pIds.map((id) => PlayerModel(
          id: id.toString(),
          name: 'Player ${id.toString().substring(0, 4)}',
        )).toList();

        state = state.copyWith(
          roomId: data['room_id'],
          creatorId: data['creator_id'],
          players: players,
          isStarted: data['is_started'] ?? false,
        );
      }
    });
    return CustomRoomState();
  }

  void createRoom() {
    ref.read(webSocketServiceProvider).send('create_custom');
  }

  void joinRoom(String roomId) {
    ref.read(webSocketServiceProvider).send('join_custom', {'room_id': roomId});
  }

  void startMatch() {
    if (state.roomId != null) {
      ref.read(webSocketServiceProvider).send('start_custom', {'room_id': state.roomId});
    }
  }
}

final customRoomProvider = NotifierProvider<CustomRoomNotifier, CustomRoomState>(CustomRoomNotifier.new);

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
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.arrow_back, color: AppColors.white70),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.white05,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Text(
                          'ID: ${roomState.roomId!.split('_').last}',
                          style: const TextStyle(color: AppColors.cyan, fontSize: 12, fontWeight: FontWeight.bold),
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
                      return LobbyPlayerCard(
                        player: player,
                        size: 60,
                        isLocalPlayer: player.id == user?.id,
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
                        onPressed: () => _showInviteSheet(context, ref),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassButton(
                        label: isHost ? 'START MATCH' : 'WAITING...',
                        glowColor: isHost ? AppColors.mintGreen : AppColors.white30,
                        onPressed: isHost && roomState.players.length >= 4 
                          ? () => ref.read(customRoomProvider.notifier).startMatch()
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
    );
  }

  void _showInviteSheet(BuildContext context, WidgetRef ref) {
    // Reuse friend list logic to send room invites
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
            border: Border.all(color: AppColors.white10, style: BorderStyle.none),
          ),
          child: Center(
            child: Text(
              '$index',
              style: const TextStyle(color: AppColors.white10, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text('EMPTY', style: TextStyle(color: AppColors.white10, fontSize: 8)),
      ],
    );
  }
}