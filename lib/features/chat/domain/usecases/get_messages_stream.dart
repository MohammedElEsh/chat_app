import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesStream {
  final ChatRepository repository;

  GetMessagesStream(this.repository);

  Stream<Either<Failure, List<MessageEntity>>> call(String chatId) {
    return repository.getMessagesStream(chatId);
  }
}