abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection. Please check your network.');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super('Session expired. Please login again.');
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super('An unexpected error occurred. Please try again.');
}
