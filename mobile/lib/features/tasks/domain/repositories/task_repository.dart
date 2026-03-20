import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<Either<Failure, Map<String, dynamic>>> getTasks({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  });
  Future<Either<Failure, TaskEntity>> createTask({
    required String title,
    String? description,
    String? priority,
    String? dueDate,
  });
  Future<Either<Failure, TaskEntity>> updateTask(
    String id, {
    String? title,
    String? description,
    String? status,
    String? priority,
    String? dueDate,
  });
  Future<Either<Failure, void>> deleteTask(String id);
  Future<Either<Failure, TaskEntity>> toggleTask(String id);
}
