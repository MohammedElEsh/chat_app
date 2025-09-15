import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/chat_service.dart';
import 'message_bubble.dart';

class ChatMessagesList extends StatelessWidget {
  final String chatId;
  final String currentUserId;
  final ScrollController scrollController;
  final String otherUserName;
  final Color chatBubbleColor;

  const ChatMessagesList({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.scrollController,
    required this.otherUserName,
    required this.chatBubbleColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: ChatService.getChatMessages(chatId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading messages',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Send the first message to start the conversation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        final messages = snapshot.data!.docs;

        // Auto-scroll to bottom when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.withOpacity(0.05),
                Colors.blue.withOpacity(0.05),
              ],
            ),
          ),
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final messageDoc = messages[index];
              final messageData = messageDoc.data() as Map<String, dynamic>;

              final text = messageData['text'] ?? '';
              final senderId = messageData['senderId'] ?? '';
              final timestamp = messageData['timestamp'] as Timestamp?;

              final isCurrentUser = senderId == currentUserId;

              return MessageBubble(
                text: text,
                isCurrentUser: isCurrentUser,
                timestamp: timestamp,
                otherUserName: otherUserName,
                chatBubbleColor: chatBubbleColor,
              );
            },
          ),
        );
      },
    );
  }
}