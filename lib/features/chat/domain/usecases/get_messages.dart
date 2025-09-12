import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessages {
  final ChatRepository repository;

  GetMessages(this.repository);

  Stream<Either<Failure, List<MessageEntity>>> call() {
    return repository.getMessages();
  }
}
