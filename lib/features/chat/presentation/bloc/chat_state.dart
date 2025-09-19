import 'package:equatable/equatable.dart';

import '../../domain/entities/message_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<MessageEntity> messages;
  final bool isSendingMessage;

  const ChatLoaded({
    required this.messages,
    this.isSendingMessage = false,
  });

  ChatLoaded copyWith({
    List<MessageEntity>? messages,
    bool? isSendingMessage,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
    );
  }

  @override
  List<Object?> get props => [messages, isSendingMessage];
}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object> get props => [message];
}

class ChatSendingMessage extends ChatState {
  final List<MessageEntity> messages;

  const ChatSendingMessage({required this.messages});

  @override
  List<Object> get props => [messages];
}

class ChatMessageSentState extends ChatState {
  final List<MessageEntity> messages;

  const ChatMessageSentState({required this.messages});

  @override
  List<Object> get props => [messages];
}
