class PrivateChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;

  const PrivateChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  factory PrivateChatMessage.fromJson(Map<String, dynamic> json) {
    return PrivateChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
    );
  }
}
