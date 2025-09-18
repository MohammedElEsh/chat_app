import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.senderEmail,
    required super.content,
    required super.createdAt,
    super.type = MessageType.text,
    super.imageUrl,
    super.voiceUrl,
    super.isRead = false,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderEmail: data['senderEmail'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      type: _getMessageTypeFromString(data['type'] ?? 'text'),
      imageUrl: data['imageUrl'],
      voiceUrl: data['voiceUrl'],
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderEmail': senderEmail,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'type': type.name,
      'imageUrl': imageUrl,
      'voiceUrl': voiceUrl,
      'isRead': isRead,
    };
  }

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      senderId: entity.senderId,
      senderName: entity.senderName,
      senderEmail: entity.senderEmail,
      content: entity.content,
      createdAt: entity.createdAt,
      type: entity.type,
      imageUrl: entity.imageUrl,
      voiceUrl: entity.voiceUrl,
      isRead: entity.isRead,
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      senderId: senderId,
      senderName: senderName,
      senderEmail: senderEmail,
      content: content,
      createdAt: createdAt,
      type: type,
      imageUrl: imageUrl,
      voiceUrl: voiceUrl,
      isRead: isRead,
    );
  }

  static MessageType _getMessageTypeFromString(String type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'voice':
        return MessageType.voice;
      default:
        return MessageType.text;
    }
  }
}
