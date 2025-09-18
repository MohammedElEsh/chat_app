import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/message_entity.dart';
import 'voice_message_player.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  bool get _isCurrentUser => 
      FirebaseAuth.instance.currentUser?.uid == message.senderId;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: _isCurrentUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!_isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                message.senderName.isNotEmpty 
                    ? message.senderName[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: _isCurrentUser 
                    ? Colors.blue.shade500
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(_isCurrentUser ? 20 : 4),
                  bottomRight: Radius.circular(_isCurrentUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isCurrentUser && message.senderName.isNotEmpty) ...[
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  _buildMessageContent(),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: _isCurrentUser 
                          ? Colors.white70 
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade600,
              child: Text(
                message.senderName.isNotEmpty 
                    ? message.senderName[0].toUpperCase()
                    : 'M',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 14,
            color: _isCurrentUser ? Colors.white : Colors.black87,
          ),
        );
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.imageUrl!,
                  width: 200,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 150,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message.content,
                style: TextStyle(
                  fontSize: 14,
                  color: _isCurrentUser ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ],
        );
      case MessageType.voice:
        if (message.voiceUrl != null) {
          return VoiceMessagePlayer(
            voiceUrl: message.voiceUrl!,
            isCurrentUser: _isCurrentUser,
          );
        } else {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error,
                color: _isCurrentUser ? Colors.white : Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Voice message unavailable',
                style: TextStyle(
                  fontSize: 14,
                  color: _isCurrentUser ? Colors.white : Colors.black87,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          );
        }
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
