import 'package:dio/dio.dart';
import 'failures.dart';

Failure handleDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const NetworkFailure();
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode;
      final msg = e.response?.data?['message'] ?? 'Server error';
      if (code == 401) return const UnauthorizedFailure();
      return ServerFailure(msg, statusCode: code);
    default:
      return const UnknownFailure();
  }
}
