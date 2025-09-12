import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../../domain/entities/message_entity.dart';

abstract class FirebaseChatsDataSource {
  Stream<List<ChatModel>> getChatsForUserStream(String userId);
  Future<String> createChatIfNotExists({
    required String uidA,
    required String uidB,
    required Map<String, String> userAData,
    required Map<String, String> userBData,
  });
  Future<void> sendMessageToChat({
    required String chatId,
    required MessageEntity message,
  });
  Future<String?> getExistingChatId(String uidA, String uidB);
}

class FirebaseChatsDataSourceImpl implements FirebaseChatsDataSource {
  final FirebaseFirestore _firestore;

  FirebaseChatsDataSourceImpl(this._firestore);

  @override
  Stream<List<ChatModel>> getChatsForUserStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatModel.fromDocument(doc))
          .toList();
    });
  }

  @override
  Future<String> createChatIfNotExists({
    required String uidA,
    required String uidB,
    required Map<String, String> userAData,
    required Map<String, String> userBData,
  }) async {
    // Check if chat already exists
    final existingChatId = await getExistingChatId(uidA, uidB);
    if (existingChatId != null) {
      return existingChatId;
    }

    // Create new chat
    final chatData = ChatModel.createChatData(
      uidA: uidA,
      uidB: uidB,
      userAData: userAData,
      userBData: userBData,
    );

    final docRef = await _firestore.collection('chats').add(chatData);
    return docRef.id;
  }

  @override
  Future<String?> getExistingChatId(String uidA, String uidB) async {
    final querySnapshot = await _firestore
        .collection('chats')
        .where('participants', whereIn: [
          [uidA, uidB],
          [uidB, uidA]
        ])
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    }
    return null;
  }

  @override
  Future<void> sendMessageToChat({
    required String chatId,
    required MessageEntity message,
  }) async {
    final batch = _firestore.batch();

    // Add message to messages subcollection
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final messageModel = MessageModel(
      id: messageRef.id,
      senderId: message.senderId,
      senderName: message.senderName,
      senderEmail: message.senderEmail,
      content: message.content,
      createdAt: message.createdAt,
      type: message.type,
      imageUrl: message.imageUrl,
      isRead: message.isRead,
    );

    batch.set(messageRef, messageModel.toFirestore());

    // Update chat document with last message info
    final chatRef = _firestore.collection('chats').doc(chatId);
    batch.update(chatRef, {
      'lastMessage': message.content,
      'lastMessageTime': Timestamp.fromDate(message.createdAt),
    });

    await batch.commit();
  }
}
