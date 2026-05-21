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
      return data.map((json) => _messageFromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      final data = await _api.sendChatMessage(content);
      final msg = _messageFromJson(data);
      if (!_controller.isClosed) _controller.add(msg);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pinMessage(String messageId) async {
    // TODO: Implement backend endpoint for pinning
  }

  /// Poll for new messages every 5 seconds
  void startSimulation() {
    _pollTimer?.cancel();
    int lastCount = 0;
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final messages = await getMessages();
        if (messages.length > lastCount) {
          for (final msg in messages.skip(lastCount)) {
            if (!_controller.isClosed) _controller.add(msg);
          }
          lastCount = messages.length;
        }
      } catch (_) {}
    });
  }

  FamilyChatMessage _messageFromJson(Map<String, dynamic> json) {
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
