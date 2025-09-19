import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/message_entity.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a chat ID in the format: ${min(user1Id, user2Id)}_${max(user1Id, user2Id)}
  static String _createChatId(String user1Id, String user2Id) {
    final List<String> userIds = [user1Id, user2Id]..sort();
    return '${userIds[0]}_${userIds[1]}';
  }

  /// Create or get existing chat between two users
  static Future<String> createOrGetChat({
    required String currentUserId,
    required String otherUserId,
    required Map<String, dynamic> otherUserData,
  }) async {
    final chatId = _createChatId(currentUserId, otherUserId);
    final chatRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      // Get current user data from users collection
      final currentUserDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      final currentUserData = currentUserDoc.exists
          ? currentUserDoc.data()!
          : {};

      // Create new chat document
      await chatRef.set({
        'participants': [currentUserId, otherUserId],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'users': {
          currentUserId: {
            'id': currentUserId,
            'name': currentUserData['name'] ?? 'User',
            'photoURL': currentUserData['photoURL'] ?? '',
          },
          otherUserId: {
            'id': otherUserId,
            'name': otherUserData['name'] ?? 'User',
            'photoURL': otherUserData['photoURL'] ?? '',
          },
        },
      });
    }

    return chatId;
  }

  /// Send a message to a chat
  static Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
    MessageType type = MessageType.text,
    String? imageUrl,
    String? voiceUrl,
    int? duration,
  }) async {
    final batch = _firestore.batch();

    // Add message to messages subcollection
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final messageData = {
      'text': text,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type.name,
    };

    // Add optional fields based on message type
    if (type == MessageType.image && imageUrl != null) {
      messageData['imageUrl'] = imageUrl;
    } else if (type == MessageType.voice && voiceUrl != null) {
      messageData['voiceUrl'] = voiceUrl;
      messageData['duration'] = duration ?? 0;
    }

    batch.set(messageRef, messageData);

    // Update chat document with last message info
    final chatRef = _firestore.collection('chats').doc(chatId);
    String lastMessagePreview;

    if (type == MessageType.image) {
      lastMessagePreview = '📷 Image';
    } else if (type == MessageType.voice) {
      lastMessagePreview = '🎤 Voice message';
    } else {
      lastMessagePreview = text;
    }

    batch.update(chatRef, {
      'lastMessage': lastMessagePreview,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Get real-time stream of chats for a user
  static Stream<QuerySnapshot> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  /// Get real-time stream of messages for a chat
  static Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy(
          'timestamp',
          descending: false,
        ) // Ascending for chronological order
        .snapshots();
  }

  /// Get chat document by ID
  static Future<DocumentSnapshot> getChatById(String chatId) {
    return _firestore.collection('chats').doc(chatId).get();
  }

  /// Search users by name (case-insensitive)
  static Stream<QuerySnapshot> searchUsers(String query) {
    if (query.isEmpty) {
      return const Stream.empty();
    }

    // Convert query to lowercase for case-insensitive search
    final lowerQuery = query.toLowerCase();

    return _firestore
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: lowerQuery)
        .where('name', isLessThanOrEqualTo: '${lowerQuery}z')
        .snapshots();
  }

  /// Get all users (for search when no query provided)
  static Stream<QuerySnapshot> getAllUsers() {
    return _firestore.collection('users').orderBy('name').snapshots();
  }

  /// Check if current user has any chats
  static Future<bool> userHasChats(String userId) async {
    final snapshot = await _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Get other participant data from chat document
  static Map<String, dynamic>? getOtherParticipant(
    Map<String, dynamic> chatData,
    String currentUserId,
  ) {
    final participants = List<String>.from(chatData['participants'] ?? []);
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    if (otherUserId.isEmpty) return null;

    final users = chatData['users'] as Map<String, dynamic>? ?? {};
    return users[otherUserId] as Map<String, dynamic>?;
  }

  /// Create or update user document in Firestore
  static Future<void> createOrUpdateUser(UserEntity user) async {
    await _firestore.collection('users').doc(user.id).set({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'photoURL': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
