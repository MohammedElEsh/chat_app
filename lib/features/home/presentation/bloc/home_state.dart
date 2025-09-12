import 'package:equatable/equatable.dart';
import '../../../chat/domain/entities/chat_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ChatEntity> chats;
  final UserEntity currentUser;

  const HomeLoaded({
    required this.chats,
    required this.currentUser,
  });

  @override
  List<Object> get props => [chats, currentUser];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
}
