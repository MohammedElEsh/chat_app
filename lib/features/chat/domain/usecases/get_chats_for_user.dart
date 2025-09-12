import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/chat_entity.dart';
import '../repositories/chats_repository.dart';

class GetChatsForUser {
  final ChatsRepository repository;

  GetChatsForUser(this.repository);

  Stream<Either<Failure, List<ChatEntity>>> call(String userId) {
    return repository.getChatsForUserStream(userId);
  }
}
