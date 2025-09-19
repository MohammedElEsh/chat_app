import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/message_entity.dart';
import 'voice_message_bubble.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isCurrentUser;
  final Timestamp? timestamp;
  final String otherUserName;
  final Color chatBubbleColor;
  final MessageType messageType;
  final String? imageUrl;
  final String? voiceUrl;
  final int? voiceDuration;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isCurrentUser,
    required this.timestamp,
    required this.otherUserName,
    required this.chatBubbleColor,
    this.messageType = MessageType.text,
    this.imageUrl,
    this.voiceUrl,
    this.voiceDuration,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = screenWidth * 0.75; // 75% of screen width

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      // تم نقل الاسم والصورة إلى الجانب الأيسر في فقاعات الرسائل
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withOpacity(0.3),
              child: Text(
                otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBubbleWidth),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? chatBubbleColor
                      : AppColors.incomingMessageBubble,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: isCurrentUser
                        ? const Radius.circular(18)
                        : const Radius.circular(0),
                    bottomRight: isCurrentUser
                        ? const Radius.circular(0)
                        : const Radius.circular(18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isCurrentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (messageType == MessageType.image && imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl!,
                          width: maxBubbleWidth * 0.8, // Adjust image width
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: maxBubbleWidth * 0.8,
                              height: maxBubbleWidth * 0.8,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isCurrentUser
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: maxBubbleWidth * 0.8,
                                height: maxBubbleWidth * 0.8,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                        ),
                      )
                    else if (messageType == MessageType.voice &&
                        voiceUrl != null)
                      VoiceMessageBubble(
                        voiceUrl: voiceUrl!,
                        duration: voiceDuration ?? 0,
                        isCurrentUser: isCurrentUser,
                        bubbleColor: isCurrentUser
                            ? chatBubbleColor
                            : AppColors.incomingMessageBubble,
                        textColor: isCurrentUser
                            ? Colors.white
                            : Colors.black87,
                      )
                    else
                      Text(
                        text,
                        style: TextStyle(
                          color: isCurrentUser ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    if (timestamp != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(timestamp!),
                        style: TextStyle(
                          color: isCurrentUser
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withOpacity(0.3),
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE HH:mm').format(dateTime);
    } else {
      return DateFormat('MMM d, HH:mm').format(dateTime);
    }
  }
}
