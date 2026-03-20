import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remote;
  TaskRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTasks({int page = 1, int limit = 10, String? status, String? search}) async {
    try {
      final result = await _remote.getTasks(page: page, limit: limit, status: status, search: search);
      return Right(result);
    } on DioException catch (e) {
      return Left(handleDioError(e));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> createTask({required String title, String? description, String? priority, String? dueDate}) async {
    try {
      final result = await _remote.createTask(title: title, description: description, priority: priority, dueDate: dueDate);
      return Right(result);
    } on DioException catch (e) {
      return Left(handleDioError(e));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(String id, {String? title, String? description, String? status, String? priority, String? dueDate}) async {
    try {
      final result = await _remote.updateTask(id, title: title, description: description, status: status, priority: priority, dueDate: dueDate);
      return Right(result);
    } on DioException catch (e) {
      return Left(handleDioError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      await _remote.deleteTask(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(handleDioError(e));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> toggleTask(String id) async {
    try {
      final result = await _remote.toggleTask(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(handleDioError(e));
    }
  }
}
