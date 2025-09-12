import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final String id;
  final List<String> participants;
  final Map<String, Map<String, String>> users;
  final String lastMessage;
  final DateTime lastMessageTime;

  const ChatEntity({
    required this.id,
    required this.participants,
    required this.users,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  // Get the other participant's data (not current user)
  Map<String, String>? getOtherUserData(String currentUserId) {
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    return otherUserId.isNotEmpty ? users[otherUserId] : null;
  }

  // Get the other participant's ID (not current user)
  String getOtherUserId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  @override
  List<Object?> get props => [id, participants, users, lastMessage, lastMessageTime];
}
