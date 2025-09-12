import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.participants,
    required super.users,
    required super.lastMessage,
    required super.lastMessageTime,
  });

  // Create from Firestore document
  factory ChatModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel.fromMap(data, doc.id);
  }

  // Create from Map with document ID
  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      users: _parseUsersMap(map['users'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: (map['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'users': users,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
    };
  }

  // Convert to Entity
  ChatEntity toEntity() {
    return ChatEntity(
      id: id,
      participants: participants,
      users: users,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
    );
  }

  // Helper method to parse users map with proper types
  static Map<String, Map<String, String>> _parseUsersMap(Map<dynamic, dynamic> usersMap) {
    final result = <String, Map<String, String>>{};
    usersMap.forEach((key, value) {
      if (key is String && value is Map) {
        result[key] = Map<String, String>.from(value);
      }
    });
    return result;
  }

  // Create new chat document data
  static Map<String, dynamic> createChatData({
    required String uidA,
    required String uidB,
    required Map<String, String> userAData,
    required Map<String, String> userBData,
  }) {
    return {
      'participants': [uidA, uidB],
      'users': {
        uidA: userAData,
        uidB: userBData,
      },
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    };
  }
}
