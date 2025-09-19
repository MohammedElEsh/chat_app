import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message_model.dart';
import '../../domain/entities/message_entity.dart';

abstract class FirebaseChatDataSource {
  Future<void> sendMessage({
    required String content,
    required MessageType type,
    String? imageUrl,
    String? voiceUrl,  // ✅ جديد
    String? chatId,  // ✅ جديد لتحديد المحادثة
  });

  Stream<List<MessageModel>> getMessages();

  // ✅ جديد للحصول على رسائل محادثة محددة
  Stream<List<MessageModel>> getMessagesStream(String chatId);

  Future<void> markMessageAsRead(String messageId);

  Future<List<MessageModel>> getMessageHistory({
    int limit = 50,
    String? lastMessageId,
    String? chatId, // ✅ إضافة معامل chatId
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
    String? voiceUrl,  // ✅ جديد
    String? chatId,  // ✅ جديد
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
      voiceUrl: voiceUrl,
      isRead: false,
    );

    // حفظ الرسالة في المحادثة المحددة أو في collection عام
    if (chatId != null) {
      // إضافة الرسالة للمحادثة المحددة
      final batch = _firestore.batch();
      
      // إضافة الرسالة
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();
      
      batch.set(messageRef, messageModel.toFirestore());
      
      // تحديث معلومات آخر رسالة في المحادثة
      final chatRef = _firestore.collection('chats').doc(chatId);
      batch.update(chatRef, {
        'lastMessage': content.isEmpty ? (
          type == MessageType.image ? '📷 Photo' : 
          type == MessageType.voice ? '🎤 Voice message' : 
          content
        ) : content,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      
      await batch.commit();
    } else {
      // الاحتفاظ بالسلوك القديم للتوافق مع الوراء
      await _firestore.collection('messages').add(messageModel.toFirestore());
    }
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
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
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
    String? chatId, // ✅ إضافة معامل chatId
  }) async {
    // إذا لم يتم تحديد chatId، استخدم المجموعة العامة (للتوافق مع الوراء)
    CollectionReference collection = chatId != null 
        ? _firestore.collection('chats').doc(chatId).collection('messages')
        : _firestore.collection('messages');
    
    Query query = collection
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastMessageId != null) {
      DocumentSnapshot lastDoc;
      if (chatId != null) {
        lastDoc = await _firestore.collection('chats').doc(chatId).collection('messages').doc(lastMessageId).get();
      } else {
        lastDoc = await _firestore.collection('messages').doc(lastMessageId).get();
      }
      
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
