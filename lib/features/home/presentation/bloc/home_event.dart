import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeStarted extends HomeEvent {
  final String userId;

  const HomeStarted(this.userId);

  @override
  List<Object> get props => [userId];
}

class HomeChatsReceived extends HomeEvent {
  final List<dynamic> chats; // Using dynamic to handle Either type

  const HomeChatsReceived(this.chats);

  @override
  List<Object> get props => [chats];
}

class HomeErrorOccurred extends HomeEvent {
  final String message;

  const HomeErrorOccurred(this.message);

  @override
  List<Object> get props => [message];
}
