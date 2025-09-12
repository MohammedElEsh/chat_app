import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatsRepository {
  /// Get stream of chats for a specific user
  Stream<Either<Failure, List<ChatEntity>>> getChatsForUserStream(String userId);

  /// Create a new chat between two users if it doesn't exist, return chat ID
  Future<Either<Failure, String>> createChatIfNotExists({
    required String uidA,
    required String uidB,
    required Map<String, String> userAData,
    required Map<String, String> userBData,
  });

  /// Send a message to a chat and update last message info
  Future<Either<Failure, void>> sendMessage({
    required String chatId,
    required MessageEntity message,
  });

  /// Get existing chat ID between two users (if exists)
  Future<Either<Failure, String?>> getExistingChatId(String uidA, String uidB);
}
