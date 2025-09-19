import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String senderEmail;
  final String content;
  final DateTime createdAt;
  final MessageType type;
  final String? imageUrl;
  final bool isRead;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderEmail,
    required this.content,
    required this.createdAt,
    this.type = MessageType.text,
    this.imageUrl,
    this.isRead = false,
  });

  MessageEntity copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderEmail,
    String? content,
    DateTime? createdAt,
    MessageType? type,
    String? imageUrl,
    bool? isRead,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderEmail: senderEmail ?? this.senderEmail,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        senderName,
        senderEmail,
        content,
        createdAt,
        type,
        imageUrl,
        isRead,
      ];
}

enum MessageType {
  text,
  image,
  voice,
}
