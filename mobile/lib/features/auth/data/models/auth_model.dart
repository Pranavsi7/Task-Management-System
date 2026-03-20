import 'dart:convert';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({required super.id, required super.name, required super.email});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(id: json['id'], name: json['name'], email: json['email']);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String str) =>
      UserModel.fromJson(jsonDecode(str));
}

class AuthTokensModel extends AuthTokensEntity {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
    required UserModel userModel,
  }) : super(user: userModel);

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) => AuthTokensModel(
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken'],
        userModel: UserModel.fromJson(json['user']),
      );
}
