import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokensModel> login(String email, String password);
  Future<AuthTokensModel> register(String name, String email, String password);
  Future<void> logout(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthTokensModel> login(String email, String password) async {
    final response = await _apiClient.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthTokensModel.fromJson(response.data);
  }

  @override
  Future<AuthTokensModel> register(String name, String email, String password) async {
    final response = await _apiClient.dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    return AuthTokensModel.fromJson(response.data);
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _apiClient.dio.post('/auth/logout', data: {'refreshToken': refreshToken});
  }
}
