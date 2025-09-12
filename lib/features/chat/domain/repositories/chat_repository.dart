import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, void>> sendMessage({
    required String content,
    required MessageType type,
    String? imageUrl,
  });

  Stream<Either<Failure, List<MessageEntity>>> getMessages();

  Future<Either<Failure, void>> markMessageAsRead(String messageId);

  Future<Either<Failure, List<MessageEntity>>> getMessageHistory({
    int limit = 50,
    String? lastMessageId,
  });
}
