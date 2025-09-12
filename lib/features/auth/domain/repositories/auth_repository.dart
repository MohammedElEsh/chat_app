import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Stream<UserEntity?> get user;
  
  UserEntity? get currentUser;
}
