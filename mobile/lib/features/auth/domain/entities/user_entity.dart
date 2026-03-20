import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;

  const UserEntity({required this.id, required this.name, required this.email});

  @override
  List<Object?> get props => [id, name, email];
}

class AuthTokensEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final UserEntity user;

  const AuthTokensEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
