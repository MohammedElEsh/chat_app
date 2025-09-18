import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, void>> sendMessage({
    required String content,
    required MessageType type,
    String? imageUrl,
    String? voiceUrl,  // ✅ جديد للرسائل الصوتية
    String? chatId,  // ✅ جديد
  });

  Stream<Either<Failure, List<MessageEntity>>> getMessages();

  // ✅ جديد للحصول على رسائل محادثة محددة في الوقت الفعلي
  Stream<Either<Failure, List<MessageEntity>>> getMessagesStream(String chatId);

  Future<Either<Failure, void>> markMessageAsRead(String messageId);

  Future<Either<Failure, List<MessageEntity>>> getMessageHistory({
    int limit = 50,
    String? lastMessageId,
  });
}
