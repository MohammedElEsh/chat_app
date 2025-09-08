import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await dataSource.loginWithEmail(
        email: email,
        password: password,
      );
      return Right(userModel.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(AuthFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await dataSource.registerWithEmail(
        name: name,
        email: email,
        password: password,
      );
      return Right(userModel.toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(AuthFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await dataSource.logout();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_getAuthErrorMessage(e.code)));
    } catch (e) {
      return Left(AuthFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Stream<UserEntity?> get user {
    return dataSource.user.map((userModel) => userModel?.toEntity());
  }
  
  @override
  UserEntity? get currentUser {
    final userModel = dataSource.currentUser;
    return userModel?.toEntity();
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'email-already-in-use':
        return 'Email is already in use';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'user-disabled':
        return 'User has been disabled';
      case 'too-many-requests':
        return 'Too many requests. Try again later';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      default:
        return 'Authentication error: $code';
    }
  }
}
