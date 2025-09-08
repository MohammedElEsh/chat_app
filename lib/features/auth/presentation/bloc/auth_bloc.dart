import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_with_email.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register_with_email.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final LoginWithEmail _loginWithEmail;
  final RegisterWithEmail _registerWithEmail;
  final Logout _logout;

  AuthBloc(
    this._authRepository,
    this._loginWithEmail,
    this._registerWithEmail,
    this._logout,
  ) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginWithEmailRequested>(_onLoginWithEmailRequested);
    on<AuthRegisterWithEmailRequested>(_onRegisterWithEmailRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      emit(AuthAuthenticated(user: currentUser));
    } else {
      emit(const AuthInitial());
    }
  }

  Future<void> _onLoginWithEmailRequested(
    AuthLoginWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _loginWithEmail(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onRegisterWithEmailRequested(
    AuthRegisterWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _registerWithEmail(
      name: event.name,
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _logout();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthInitial()),
    );
  }
}
