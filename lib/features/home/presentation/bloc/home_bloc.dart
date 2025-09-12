import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../domain/usecases/get_chats_for_user.dart';
import '../../../chat/domain/entities/chat_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/errors/failures.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetChatsForUser getChatsForUser;
  final UserEntity currentUser;
  StreamSubscription<Either<Failure, List<ChatEntity>>>? _chatsSubscription;

  HomeBloc({
    required this.getChatsForUser,
    required this.currentUser,
  }) : super(HomeInitial()) {
    on<HomeStarted>(_onHomeStarted);
    on<HomeChatsReceived>(_onChatsReceived);
    on<HomeErrorOccurred>(_onErrorOccurred);
  }

  void _onHomeStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    await _chatsSubscription?.cancel();
    
    _chatsSubscription = getChatsForUser(event.userId).listen(
      (either) {
        either.fold(
          (failure) => add(HomeErrorOccurred(failure.message)),
          (chats) => add(HomeChatsReceived(chats)),
        );
      },
      onError: (error) => add(HomeErrorOccurred(error.toString())),
    );
  }

  void _onChatsReceived(HomeChatsReceived event, Emitter<HomeState> emit) {
    if (event.chats is List<ChatEntity>) {
      emit(HomeLoaded(
        chats: event.chats as List<ChatEntity>,
        currentUser: currentUser,
      ));
    } else {
      add(HomeErrorOccurred('Invalid chat data received'));
    }
  }

  void _onErrorOccurred(HomeErrorOccurred event, Emitter<HomeState> emit) {
    emit(HomeError(message: event.message));
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}
