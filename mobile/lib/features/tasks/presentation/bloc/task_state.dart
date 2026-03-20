part of 'task_bloc.dart';

enum TaskLoadStatus { initial, loading, refreshing, loadingMore, success, failure }
enum TaskActionStatus { idle, loading, success, failure }

class TaskState extends Equatable {
  final TaskLoadStatus status;
  final TaskActionStatus actionStatus;
  final List<TaskEntity> tasks;
  final int total;
  final int page;
  final bool hasMore;
  final String? filterStatus;
  final String searchQuery;
  final String? error;
  final String? actionMessage;

  const TaskState({
    this.status = TaskLoadStatus.initial,
    this.actionStatus = TaskActionStatus.idle,
    this.tasks = const [],
    this.total = 0,
    this.page = 1,
    this.hasMore = true,
    this.filterStatus,
    this.searchQuery = '',
    this.error,
    this.actionMessage,
  });

  TaskState copyWith({
    TaskLoadStatus? status,
    TaskActionStatus? actionStatus,
    List<TaskEntity>? tasks,
    int? total,
    int? page,
    bool? hasMore,
    String? filterStatus,
    String? searchQuery,
    String? error,
    String? actionMessage,
  }) =>
      TaskState(
        status: status ?? this.status,
        actionStatus: actionStatus ?? this.actionStatus,
        tasks: tasks ?? this.tasks,
        total: total ?? this.total,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        filterStatus: filterStatus,
        searchQuery: searchQuery ?? this.searchQuery,
        error: error,
        actionMessage: actionMessage,
      );

  @override
  List<Object?> get props => [status, actionStatus, tasks, total, page, hasMore, filterStatus, searchQuery, error, actionMessage];
}
