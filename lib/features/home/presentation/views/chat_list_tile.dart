import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatListTile extends StatelessWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserPhotoURL;
  final String lastMessage;
  final Timestamp? lastMessageTime;
  final VoidCallback onTap;

  const ChatListTile({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserPhotoURL,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: otherUserPhotoURL.isNotEmpty
              ? NetworkImage(otherUserPhotoURL)
              : null,
          backgroundColor: Colors.white.withOpacity(0.3),
          child: otherUserPhotoURL.isEmpty
              ? Text(
            otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          )
              : null,
        ),
        title: Text(
          otherUserName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          lastMessage.isNotEmpty ? lastMessage : 'No messages yet',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: lastMessageTime != null
            ? Text(
          _formatTimestamp(lastMessageTime!),
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        )
            : null,
        onTap: onTap,
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final messageTime = timestamp.toDate();
    final difference = now.difference(messageTime);

    if (difference.inDays == 0) {
      // Same day - show time
      return DateFormat('HH:mm').format(messageTime);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      return DateFormat('EEEE').format(messageTime);
    } else if (difference.inDays < 365) {
      // This year - show month and day
      return DateFormat('MMM d').format(messageTime);
    } else {
      // Different year - show year
      return DateFormat('MMM d, yyyy').format(messageTime);
    }
  }
}