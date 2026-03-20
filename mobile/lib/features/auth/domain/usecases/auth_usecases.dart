import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);
  Future<Either<Failure, AuthTokensEntity>> call(String email, String password) =>
      repository.login(email, password);
}

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);
  Future<Either<Failure, AuthTokensEntity>> call(String name, String email, String password) =>
      repository.register(name, email, password);
}

class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);
  Future<Either<Failure, void>> call() => repository.logout();
}

class GetStoredUserUseCase {
  final AuthRepository repository;
  GetStoredUserUseCase(this.repository);
  Future<Either<Failure, UserEntity?>> call() => repository.getStoredUser();
}
