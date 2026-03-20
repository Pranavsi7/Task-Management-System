import 'package:equatable/equatable.dart';

enum TaskStatus { pending, inProgress, completed }
enum TaskPriority { low, medium, high }

extension TaskStatusExt on TaskStatus {
  String toApi() {
    switch (this) {
      case TaskStatus.pending: return 'PENDING';
      case TaskStatus.inProgress: return 'IN_PROGRESS';
      case TaskStatus.completed: return 'COMPLETED';
    }
  }

  static TaskStatus fromApi(String s) {
    switch (s) {
      case 'IN_PROGRESS': return TaskStatus.inProgress;
      case 'COMPLETED': return TaskStatus.completed;
      default: return TaskStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.pending: return 'Pending';
      case TaskStatus.inProgress: return 'In Progress';
      case TaskStatus.completed: return 'Completed';
    }
  }
}

extension TaskPriorityExt on TaskPriority {
  String toApi() => name.toUpperCase();

  static TaskPriority fromApi(String s) {
    switch (s) {
      case 'HIGH': return TaskPriority.high;
      case 'LOW': return TaskPriority.low;
      default: return TaskPriority.medium;
    }
  }

  String get label => name[0].toUpperCase() + name.substring(1);
}

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, description, status, priority, dueDate, createdAt, updatedAt];
}
