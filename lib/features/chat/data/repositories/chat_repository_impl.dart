import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/firebase_chat_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseChatDataSource dataSource;

  ChatRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, void>> sendMessage({
    required String content,
    required MessageType type,
    String? imageUrl,
    String? voiceUrl,  // ✅ جديد
    String? chatId,  // ✅ جديد
  }) async {
    try {
      await dataSource.sendMessage(
        content: content,
        type: type,
        imageUrl: imageUrl,
        voiceUrl: voiceUrl,
        chatId: chatId,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(ServerFailure('Failed to send message: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getMessages() {
    try {
      return dataSource.getMessages().map((messages) {
        final entities = messages.map((model) => model.toEntity()).toList();
        return Right<Failure, List<MessageEntity>>(entities);
      }).handleError((error) {
        if (error is FirebaseAuthException) {
          return Left<Failure, List<MessageEntity>>(
            AuthFailure(_getAuthErrorMessage(error.code))
          );
        }
        return Left<Failure, List<MessageEntity>>(
          ServerFailure('Failed to get messages: ${error.toString()}')
        );
      });
    } catch (e) {
      return Stream.value(
        Left(ServerFailure('Failed to get messages stream: ${e.toString()}'))
      );
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getMessagesStream(String chatId) {
    try {
      return dataSource.getMessagesStream(chatId).map((messages) {
        final entities = messages.map((model) => model.toEntity()).toList();
        return Right<Failure, List<MessageEntity>>(entities);
      }).handleError((error) {
        if (error is FirebaseAuthException) {
          return Left<Failure, List<MessageEntity>>(
            AuthFailure(_getAuthErrorMessage(error.code))
          );
        }
        return Left<Failure, List<MessageEntity>>(
          ServerFailure('Failed to get messages stream: ${error.toString()}')
        );
      });
    } catch (e) {
      return Stream.value(
        Left(ServerFailure('Failed to get messages stream: ${e.toString()}'))
      );
    }
  }

  @override
  Future<Either<Failure, void>> markMessageAsRead(String messageId) async {
    try {
      await dataSource.markMessageAsRead(messageId);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(ServerFailure('Failed to mark message as read: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessageHistory({
    int limit = 50,
    String? lastMessageId,
  }) async {
    try {
      final messages = await dataSource.getMessageHistory(
        limit: limit,
        lastMessageId: lastMessageId,
      );
      final entities = messages.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(ServerFailure('Failed to get message history: ${e.toString()}'));
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      default:
        return 'Authentication error: $code';
    }
  }
}

