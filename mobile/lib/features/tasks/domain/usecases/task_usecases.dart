import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;
  GetTasksUseCase(this.repository);
  Future<Either<Failure, Map<String, dynamic>>> call({
    int page = 1, int limit = 10, String? status, String? search,
  }) => repository.getTasks(page: page, limit: limit, status: status, search: search);
}

class CreateTaskUseCase {
  final TaskRepository repository;
  CreateTaskUseCase(this.repository);
  Future<Either<Failure, TaskEntity>> call({
    required String title, String? description, String? priority, String? dueDate,
  }) => repository.createTask(title: title, description: description, priority: priority, dueDate: dueDate);
}

class UpdateTaskUseCase {
  final TaskRepository repository;
  UpdateTaskUseCase(this.repository);
  Future<Either<Failure, TaskEntity>> call(
    String id, {String? title, String? description, String? status, String? priority, String? dueDate,
  }) => repository.updateTask(id, title: title, description: description, status: status, priority: priority, dueDate: dueDate);
}

class DeleteTaskUseCase {
  final TaskRepository repository;
  DeleteTaskUseCase(this.repository);
  Future<Either<Failure, void>> call(String id) => repository.deleteTask(id);
}

class ToggleTaskUseCase {
  final TaskRepository repository;
  ToggleTaskUseCase(this.repository);
  Future<Either<Failure, TaskEntity>> call(String id) => repository.toggleTask(id);
}
