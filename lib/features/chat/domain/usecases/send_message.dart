import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<Either<Failure, void>> call({
    required String content,
    required MessageType type,
    String? imageUrl,
  }) async {
    if (content.trim().isEmpty && type == MessageType.text) {
      return Left(ValidationFailure('Message cannot be empty'));
    }

    return await repository.sendMessage(
      content: content,
      type: type,
      imageUrl: imageUrl,
    );
  }
}

