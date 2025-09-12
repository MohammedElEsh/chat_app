import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/chats_repository.dart';

class CreateChatIfNotExists {
  final ChatsRepository repository;

  CreateChatIfNotExists(this.repository);

  Future<Either<Failure, String>> call({
    required String uidA,
    required String uidB,
    required Map<String, String> userAData,
    required Map<String, String> userBData,
  }) async {
    return await repository.createChatIfNotExists(
      uidA: uidA,
      uidB: uidB,
      userAData: userAData,
      userBData: userBData,
    );
  }
}
