import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessageHistory {
  final ChatRepository repository;

  GetMessageHistory(this.repository);

  Future<Either<Failure, List<MessageEntity>>> call({
    int limit = 50,
    String? lastMessageId,
    String? chatId, // ✅ إضافة معامل chatId
  }) async {
    return await repository.getMessageHistory(
      limit: limit,
      lastMessageId: lastMessageId,
      chatId: chatId, // ✅ تمرير chatId
    );
  }
}
