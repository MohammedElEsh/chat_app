import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chats_repository.dart';
import '../datasources/firebase_chats_datasource.dart';

class ChatsRepositoryImpl implements ChatsRepository {
  final FirebaseChatsDataSource dataSource;

  ChatsRepositoryImpl(this.dataSource);

  @override
  Stream<Either<Failure, List<ChatEntity>>> getChatsForUserStream(String userId) {
    try {
      return dataSource.getChatsForUserStream(userId).map((chats) {
        final entities = chats.map((chat) => chat.toEntity()).toList();
        return Right<Failure, List<ChatEntity>>(entities);
      }).handleError((error) {
        if (error is FirebaseAuthException) {
          return Left<Failure, List<ChatEntity>>(
            AuthFailure(_getAuthErrorMessage(error.code))
          );
        }
        return Left<Failure, List<ChatEntity>>(
          ServerFailure('Failed to get chats: ${error.toString()}')
        );
      });
    } catch (e) {
      return Stream.value(
        Left(ServerFailure('Failed to get chats stream: ${e.toString()}'))
      );
    }
  }

  @override
  Future<Either<Failure, String>> createChatIfNotExists({
    required String uidA,
    required String uidB,
    required Map<String, String> userAData,
    required Map<String, String> userBData,
  }) async {
    try {
      final chatId = await dataSource.createChatIfNotExists(
        uidA: uidA,
        uidB: uidB,
        userAData: userAData,
        userBData: userBData,
      );
      return Right(chatId);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(ServerFailure('Failed to create chat: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required String chatId,
    required MessageEntity message,
  }) async {
    try {
      await dataSource.sendMessageToChat(
        chatId: chatId,
        message: message,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(ServerFailure('Failed to send message: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String?>> getExistingChatId(String uidA, String uidB) async {
    try {
      final chatId = await dataSource.getExistingChatId(uidA, uidB);
      return Right(chatId);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(ServerFailure('Failed to get existing chat: ${e.toString()}'));
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
