import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;

  AuthRepositoryImpl(this._remote, this._storage);

  @override
  Future<Either<Failure, AuthTokensEntity>> login(String email, String password) async {
    try {
      final result = await _remote.login(email, password);
      await _persistTokens(result);
      return Right(result);
    } on DioException catch (e) {
      return Left(handleDioError(e));
    }
  }

  @override
  Future<Either<Failure, AuthTokensEntity>> register(String name, String email, String password) async {
    try {
      final result = await _remote.register(name, email, password);
      await _persistTokens(result);
      return Right(result);
    } on DioException catch (e) {
      return Left(handleDioError(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) await _remote.logout(refreshToken);
      await _storage.clearAll();
      return const Right(null);
    } catch (_) {
      await _storage.clearAll();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getStoredUser() async {
    try {
      final json = await _storage.getUserData();
      if (json == null) return const Right(null);
      return Right(UserModel.fromJsonString(json));
    } catch (_) {
      return const Right(null);
    }
  }

  Future<void> _persistTokens(AuthTokensModel tokens) async {
    await _storage.saveAccessToken(tokens.accessToken);
    await _storage.saveRefreshToken(tokens.refreshToken);
    await _storage.saveUserData((tokens.user as UserModel).toJsonString());
  }
}
