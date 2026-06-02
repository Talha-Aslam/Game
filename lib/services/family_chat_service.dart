import 'dart:async';
import '../models/family/family_chat_model.dart';
import 'family_api_service.dart';

/// Family chat service backed by FastAPI
class FamilyChatService {
  final FamilyApiService _api = FamilyApiService();
  final _controller = StreamController<FamilyChatMessage>.broadcast();
  Timer? _pollTimer;

  Stream<FamilyChatMessage> get messageStream => _controller.stream;

  Future<List<FamilyChatMessage>> getMessages() async {
    try {
      final data = await _api.getChatMessages();
      return data.map((json) => parseMessage(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      final data = await _api.sendChatMessage(content);
      final msg = parseMessage(data);
      if (!_controller.isClosed) _controller.add(msg);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pinMessage(String messageId) async {
    await _api.pinMessage(messageId);
  }

  /// Poll for new messages every 3 seconds
  void startSimulation() {
    _pollTimer?.cancel();
    int lastCount = 0;
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final messages = await getMessages();
        if (messages.length > lastCount) {
          // Send all messages as a single event to fully sync
          // Actually, we can just push the new messages. 
          // Since getMessages returns them in reverse chronological order (newest first).
          // We can just iterate the difference.
          final newMsgs = messages.skip(lastCount).toList();
          for (final msg in newMsgs) {
            if (!_controller.isClosed) _controller.add(msg);
          }
          lastCount = messages.length;
        }
      } catch (_) {}
    });
  }

  FamilyChatMessage parseMessage(Map<String, dynamic> json) {
    return FamilyChatMessage(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? '',
      senderName: json['sender_name'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] == 'system'
          ? ChatMessageType.system
          : ChatMessageType.text,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isPinned: json['is_pinned'] ?? false,
      mentions: List<String>.from(json['mentions'] ?? []),
    );
  }

  void dispose() {
    _pollTimer?.cancel();
    if (!_controller.isClosed) _controller.close();
  }
}
