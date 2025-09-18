import 'package:equatable/equatable.dart';

import '../../domain/entities/message_entity.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatStarted extends ChatEvent {
  const ChatStarted();
}

class ChatMessageSent extends ChatEvent {
  final String content;
  final MessageType type;
  final String? imageUrl;

  const ChatMessageSent({
    required this.content,
    required this.type,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [content, type, imageUrl];
}

class ChatMessagesReceived extends ChatEvent {
  final List<MessageEntity> messages;

  const ChatMessagesReceived(this.messages);

  @override
  List<Object> get props => [messages];
}

class ChatMessageReadRequested extends ChatEvent {
  final String messageId;

  const ChatMessageReadRequested(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class ChatImageSent extends ChatEvent {
  final String imageUrl;
  final String chatId;

  const ChatImageSent({
    required this.imageUrl,
    required this.chatId,
  });

  @override
  List<Object> get props => [imageUrl, chatId];
}

class ChatHistoryRequested extends ChatEvent {
  final int limit;
  final String? lastMessageId;

  const ChatHistoryRequested({
    this.limit = 50,
    this.lastMessageId,
  });

  @override
  List<Object?> get props => [limit, lastMessageId];
}

class ChatErrorOccurred extends ChatEvent {
  final String message;

  const ChatErrorOccurred(this.message);

  @override
  List<Object> get props => [message];
}
