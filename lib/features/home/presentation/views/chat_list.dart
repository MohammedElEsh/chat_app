import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../chat/data/services/chat_service.dart';
import '../../../chat/presentation/pages/chat_screen.dart';
import 'chat_list_tile.dart';

class ChatList extends StatelessWidget {
  final List<QueryDocumentSnapshot> chatDocs;
  final dynamic currentUser;

  const ChatList({
    super.key,
    required this.chatDocs,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: chatDocs.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.white24,
        indent: 72,
      ),
      itemBuilder: (context, index) {
        final chatDoc = chatDocs[index];
        final chatData = chatDoc.data() as Map<String, dynamic>;

        final otherParticipant = ChatService.getOtherParticipant(
          chatData,
          currentUser.id,
        );

        if (otherParticipant == null) {
          return const SizedBox.shrink();
        }

        final otherUserName = otherParticipant['name'] ?? 'Unknown User';
        final otherUserPhotoURL = otherParticipant['photoURL'] ?? '';
        final otherUserId = otherParticipant['id'] ?? '';
        final lastMessage = chatData['lastMessage'] ?? '';
        final lastMessageTime = chatData['lastMessageTime'] as Timestamp?;

        return ChatListTile(
          chatId: chatDoc.id,
          otherUserId: otherUserId,
          otherUserName: otherUserName,
          otherUserPhotoURL: otherUserPhotoURL,
          lastMessage: lastMessage,
          lastMessageTime: lastMessageTime,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatId: chatDoc.id,
                  currentUserId: currentUser.id,
                  otherUserId: otherUserId,
                  otherUserName: otherUserName,
                  otherUserPhotoURL: otherUserPhotoURL,
                ),
              ),
            );
          },
        );
      },
    );
  }
}