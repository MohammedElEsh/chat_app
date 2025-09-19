import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message_model.dart';
import '../../domain/entities/message_entity.dart';

abstract class FirebaseChatDataSource {
  Future<void> sendMessage({
    required String content,
    required MessageType type,
    String? imageUrl,
  });

  Stream<List<MessageModel>> getMessages();

  Future<void> markMessageAsRead(String messageId);

  Future<List<MessageModel>> getMessageHistory({
    int limit = 50,
    String? lastMessageId,
  });
}

class FirebaseChatDataSourceImpl implements FirebaseChatDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  FirebaseChatDataSourceImpl(this._firestore, this._firebaseAuth);

  @override
  Future<void> sendMessage({
    required String content,
    required MessageType type,
    String? imageUrl,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final messageModel = MessageModel(
      id: '', // Firestore will generate this
      senderId: user.uid,
      senderName: user.displayName ?? 'Anonymous',
      senderEmail: user.email ?? '',
      content: content,
      createdAt: DateTime.now(),
      type: type,
      imageUrl: imageUrl,
      isRead: false,
    );

    await _firestore.collection('messages').add(messageModel.toFirestore());
  }

  @override
  Stream<List<MessageModel>> getMessages() {
    return _firestore
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    await _firestore.collection('messages').doc(messageId).update({
      'isRead': true,
    });
  }

  @override
  Future<List<MessageModel>> getMessageHistory({
    int limit = 50,
    String? lastMessageId,
  }) async {
    Query query = _firestore
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastMessageId != null) {
      final lastDoc = await _firestore.collection('messages').doc(lastMessageId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => MessageModel.fromFirestore(doc))
        .toList()
        .reversed
        .toList();
  }
}
