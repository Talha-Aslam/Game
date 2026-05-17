import 'dart:async';
import 'dart:math';
import '../models/family/family_chat_model.dart';

/// Mock family chat service with real-time simulation
class FamilyChatService {
  final _rng = Random();
  final _controller = StreamController<FamilyChatMessage>.broadcast();
  final List<FamilyChatMessage> _messages = [];
  Timer? _simTimer;

  Stream<FamilyChatMessage> get messageStream => _controller.stream;

  FamilyChatService() {
    _messages.addAll(_buildMockHistory());
  }

  Future<List<FamilyChatMessage>> getMessages() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_messages);
  }

  Future<void> sendMessage(String content) async {
    final msg = FamilyChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'local_user', senderName: 'You',
      content: content, timestamp: DateTime.now(),
    );
    _messages.add(msg);
    if (!_controller.isClosed) _controller.add(msg);
  }

  Future<void> pinMessage(String messageId) async {
    final idx = _messages.indexWhere((m) => m.id == messageId);
    if (idx != -1) _messages[idx] = _messages[idx].copyWith(isPinned: true);
  }

  void startSimulation() {
    _simTimer?.cancel();
    final names = ['ShadowKing','NightViper','IronFist','GhostWalker','CrimsonEye'];
    final msgs = ['gg last match 🔥','anyone for ranked?','war tonight don\'t forget',
      'lol nice play','who\'s online?','let\'s queue up','need 1 more for party'];
    _simTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      final name = names[_rng.nextInt(names.length)];
      final msg = FamilyChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'u${_rng.nextInt(5) + 1}', senderName: name,
        content: msgs[_rng.nextInt(msgs.length)], timestamp: DateTime.now(),
      );
      _messages.add(msg);
      if (!_controller.isClosed) _controller.add(msg);
    });
  }

  List<FamilyChatMessage> _buildMockHistory() {
    final now = DateTime.now();
    return [
      FamilyChatMessage(id: 'h1', senderId: 'system', senderName: 'System',
        content: 'ShadowKing updated the MOTD', type: ChatMessageType.system,
        timestamp: now.subtract(const Duration(hours: 3))),
      FamilyChatMessage(id: 'h2', senderId: 'u1', senderName: 'ShadowKing',
        content: 'War tonight at 8 PM — everyone be ready! 🔥',
        timestamp: now.subtract(const Duration(hours: 2)), isPinned: true),
      FamilyChatMessage(id: 'h3', senderId: 'u2', senderName: 'NightViper',
        content: 'I\'m in, let\'s go', timestamp: now.subtract(const Duration(hours: 1, minutes: 45))),
      FamilyChatMessage(id: 'h4', senderId: 'u4', senderName: 'GhostWalker',
        content: '@NightViper party up?', timestamp: now.subtract(const Duration(hours: 1, minutes: 30)),
        mentions: ['NightViper']),
      FamilyChatMessage(id: 'h5', senderId: 'u3', senderName: 'IronFist',
        content: 'just hit Diamond rank 💎', timestamp: now.subtract(const Duration(hours: 1))),
      FamilyChatMessage(id: 'h6', senderId: 'u2', senderName: 'NightViper',
        content: 'nice! gg', timestamp: now.subtract(const Duration(minutes: 45))),
    ];
  }

  void dispose() {
    _simTimer?.cancel();
    if (!_controller.isClosed) _controller.close();
  }
}
