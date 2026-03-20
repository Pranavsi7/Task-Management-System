part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskLoadEvent extends TaskEvent {}
class TaskRefreshEvent extends TaskEvent {}
class TaskLoadMoreEvent extends TaskEvent {}

class TaskFilterChangedEvent extends TaskEvent {
  final String? status;
  TaskFilterChangedEvent(this.status);
  @override List<Object?> get props => [status];
}

class TaskSearchChangedEvent extends TaskEvent {
  final String query;
  TaskSearchChangedEvent(this.query);
  @override List<Object?> get props => [query];
}

class TaskCreateEvent extends TaskEvent {
  final String title;
  final String? description;
  final String? priority;
  final String? dueDate;
  TaskCreateEvent({required this.title, this.description, this.priority, this.dueDate});
  @override List<Object?> get props => [title, description, priority, dueDate];
}

class TaskUpdateEvent extends TaskEvent {
  final String id;
  final String? title;
  final String? description;
  final String? status;
  final String? priority;
  final String? dueDate;
  TaskUpdateEvent({required this.id, this.title, this.description, this.status, this.priority, this.dueDate});
  @override List<Object?> get props => [id, title, description, status, priority, dueDate];
}

class TaskDeleteEvent extends TaskEvent {
  final String id;
  TaskDeleteEvent(this.id);
  @override List<Object?> get props => [id];
}

class TaskToggleEvent extends TaskEvent {
  final String id;
  TaskToggleEvent(this.id);
  @override List<Object?> get props => [id];
}
