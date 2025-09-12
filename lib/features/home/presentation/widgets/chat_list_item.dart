import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../chat/domain/entities/chat_entity.dart';

class ChatListItem extends StatelessWidget {
  final ChatEntity chat;
  final UserEntity currentUser;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.currentUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final otherUserData = chat.getOtherUserData(currentUser.id);
    final displayName = otherUserData?['displayName'] ?? 'Unknown User';

    // Format last message time
    final lastMessageTime = _formatTime(chat.lastMessageTime);
    
    // Get avatar color based on user ID
    final avatarColor = _getAvatarColor(displayName);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: avatarColor,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  _getInitials(displayName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        lastMessageTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage.isNotEmpty 
                              ? chat.lastMessage 
                              : 'No messages yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: chat.lastMessage.isNotEmpty 
                                ? Colors.grey.shade600 
                                : Colors.grey.shade400,
                            fontStyle: chat.lastMessage.isNotEmpty 
                                ? FontStyle.normal 
                                : FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      // TODO: Add unread message count indicator here
                    ],
                  ),
                ],
              ),
            ),
            
            // Navigation arrow
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    
    return name[0].toUpperCase();
  }

  List<Color> _getAvatarColor(String name) {
    // Generate consistent colors based on name hash
    final hash = name.hashCode;
    
    final colors = [
      [Colors.blue.shade400, Colors.blue.shade600],
      [Colors.green.shade400, Colors.green.shade600],
      [Colors.purple.shade400, Colors.purple.shade600],
      [Colors.orange.shade400, Colors.orange.shade600],
      [Colors.red.shade400, Colors.red.shade600],
      [Colors.teal.shade400, Colors.teal.shade600],
      [Colors.indigo.shade400, Colors.indigo.shade600],
      [Colors.pink.shade400, Colors.pink.shade600],
    ];
    
    return colors[hash.abs() % colors.length];
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Same day - show time
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      return DateFormat('EEEE').format(dateTime);
    } else if (difference.inDays < 365) {
      // This year - show month and day
      return DateFormat('MMM d').format(dateTime);
    } else {
      // Different year - show year
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }
}
