import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.status,
    required super.priority,
    super.dueDate,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        status: TaskStatusExt.fromApi(json['status'] ?? 'PENDING'),
        priority: TaskPriorityExt.fromApi(json['priority'] ?? 'MEDIUM'),
        dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}
