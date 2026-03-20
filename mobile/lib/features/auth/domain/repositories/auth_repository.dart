import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthTokensEntity>> login(String email, String password);
  Future<Either<Failure, AuthTokensEntity>> register(String name, String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity?>> getStoredUser();
}
