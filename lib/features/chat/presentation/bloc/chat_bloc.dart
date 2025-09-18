import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/get_message_history.dart';
import '../../domain/usecases/get_messages_stream.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessage _sendMessage;
  final GetMessages _getMessages;
  final GetMessageHistory _getMessageHistory;
  final GetMessagesStream _getMessagesStream;
  
  StreamSubscription? _messagesSubscription;

  ChatBloc(
    this._sendMessage,
    this._getMessages,
    this._getMessageHistory,
    this._getMessagesStream,
  ) : super(const ChatInitial()) {
    on<ChatStarted>(_onChatStarted);
    on<LoadMessages>(_onLoadMessages);  // ✅ جديد
    on<ChatMessageSent>(_onChatMessageSent);
    on<ChatImageSent>(_onChatImageSent);
    on<ChatVoiceSent>(_onChatVoiceSent);
    on<ChatMessagesReceived>(_onChatMessagesReceived);
    on<ChatHistoryRequested>(_onChatHistoryRequested);
    on<ChatErrorOccurred>(_onChatErrorOccurred);
  }

  Future<void> _onChatStarted(
    ChatStarted event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    await _messagesSubscription?.cancel();
    
    _messagesSubscription = _getMessages().listen(
      (result) {
        result.fold(
          (failure) => add(ChatErrorOccurred(failure.message)),
          (messages) => add(ChatMessagesReceived(messages)),
        );
      },
      onError: (error) {
        add(ChatErrorOccurred('Failed to load messages: $error'));
      },
    );
  }

  // ✅ جديد - معالج LoadMessages مع Stream في الوقت الفعلي
  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    
    await _messagesSubscription?.cancel();
    
    await emit.forEach<Either<Failure, List<MessageEntity>>>(
      _getMessagesStream(event.chatId),
      onData: (result) {
        return result.fold(
          (failure) => ChatError(message: failure.message),
          (messages) => ChatLoaded(messages: messages),
        );
      },
      onError: (error, stackTrace) {
        return ChatError(message: 'Failed to load messages: $error');
      },
    );
  }

  Future<void> _onChatMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(currentState.copyWith(isSendingMessage: true));

      final result = await _sendMessage(
        content: event.content,
        type: event.type,
        imageUrl: event.imageUrl,
        voiceUrl: event.voiceUrl,
      );

      result.fold(
        (failure) {
          emit(currentState.copyWith(isSendingMessage: false));
          add(ChatErrorOccurred(failure.message));
        },
        (_) {
          emit(currentState.copyWith(isSendingMessage: false));
          // Message will be received through the stream
        },
      );
    }
  }

  Future<void> _onChatImageSent(
    ChatImageSent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(currentState.copyWith(isSendingMessage: true));

      final result = await _sendMessage(
        content: '', // محتوى فارغ للصورة
        type: MessageType.image,
        imageUrl: event.imageUrl,
      );

      result.fold(
        (failure) {
          emit(currentState.copyWith(isSendingMessage: false));
          add(ChatErrorOccurred(failure.message));
        },
        (_) {
          emit(currentState.copyWith(isSendingMessage: false));
          // Message will be received through the stream
        },
      );
    }
  }

  Future<void> _onChatVoiceSent(
    ChatVoiceSent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(currentState.copyWith(isSendingMessage: true));

      final result = await _sendMessage(
        content: '', // محتوى فارغ للرسالة الصوتية
        type: MessageType.voice,
        voiceUrl: event.voiceUrl, // ✅ استخدام voiceUrl بدلاً من imageUrl
      );

      result.fold(
        (failure) {
          emit(currentState.copyWith(isSendingMessage: false));
          add(ChatErrorOccurred(failure.message));
        },
        (_) {
          emit(currentState.copyWith(isSendingMessage: false));
          // Message will be received through the stream
        },
      );
    }
  }

  void _onChatMessagesReceived(
    ChatMessagesReceived event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatLoaded(messages: event.messages));
  }

  Future<void> _onChatHistoryRequested(
    ChatHistoryRequested event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      
      final result = await _getMessageHistory(
        limit: event.limit,
        lastMessageId: event.lastMessageId,
      );

      result.fold(
        (failure) => add(ChatErrorOccurred(failure.message)),
        (historyMessages) {
          // Add history messages to the beginning of current messages
          final allMessages = [...historyMessages, ...currentState.messages];
          // Remove duplicates based on message ID
          final uniqueMessages = <MessageEntity>[];
          final seenIds = <String>{};
          
          for (final message in allMessages) {
            if (!seenIds.contains(message.id)) {
              seenIds.add(message.id);
              uniqueMessages.add(message);
            }
          }
          
          // Sort by creation time
          uniqueMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          
          emit(ChatLoaded(messages: uniqueMessages));
        },
      );
    }
  }

  void _onChatErrorOccurred(
    ChatErrorOccurred event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(ChatLoaded(
        messages: currentState.messages,
        isSendingMessage: false,
      ));
      // Show error temporarily, then return to loaded state
      emit(ChatError(message: event.message));
      Future.delayed(const Duration(seconds: 3), () {
        if (!isClosed) {
          emit(ChatLoaded(messages: currentState.messages));
        }
      });
    } else {
      emit(ChatError(message: event.message));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
