import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/family/family_chat_model.dart';

/// Neon dark chat bubble
class FamilyChatBubble extends StatelessWidget {
  final FamilyChatMessage message;
  final bool isMe;
  final String? role;
  const FamilyChatBubble({super.key, required this.message, this.isMe = false, this.role});

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) return _buildSystemMsg();
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bgColor = isMe ? AppColors.purpleNeon.withValues(alpha: 0.12)
        : AppColors.glassBackground;
    final borderColor = isMe ? AppColors.purpleNeon.withValues(alpha: 0.3)
        : AppColors.glassBorder;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: align, children: [
        if (!isMe) Padding(padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (role != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: _getRoleColor(role!).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _getRoleColor(role!).withValues(alpha: 0.5), width: 0.5),
                  ),
                  child: Text(
                    role!.toUpperCase(),
                    style: TextStyle(
                      color: _getRoleColor(role!), 
                      fontSize: 8, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
              Text(message.senderName, style: const TextStyle(
                color: AppColors.cyan, fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14).copyWith(
              bottomLeft: isMe ? null : const Radius.circular(4),
              bottomRight: isMe ? const Radius.circular(4) : null),
            color: bgColor, border: Border.all(color: borderColor)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (message.isPinned) Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.push_pin, color: AppColors.gold, size: 10),
              const SizedBox(width: 3),
              Text('Pinned', style: TextStyle(color: AppColors.gold, fontSize: 8, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
            ]),
            Text(message.content, style: const TextStyle(
              color: Colors.white, fontSize: 13, height: 1.3)),
            const SizedBox(height: 4),
            Text(_formatTime(message.timestamp),
              style: const TextStyle(color: AppColors.white30, fontSize: 9)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSystemMsg() {
    return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.white05),
        child: Text(message.content, style: const TextStyle(
          color: AppColors.white30, fontSize: 10, fontStyle: FontStyle.italic)),
      ),
    ));
  }

  String _formatTime(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Color _getRoleColor(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'boss':
        return const Color(0xFFFFD700); // Gold
      case 'underboss':
        return const Color(0xFF9B59FF); // Purple
      case 'capo':
        return const Color(0xFF00E5FF); // Cyan
      case 'associate':
      default:
        return const Color(0x80FFFFFF); // White50
    }
  }
}
