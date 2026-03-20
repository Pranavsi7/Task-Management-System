import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/task_usecases.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase _getTasks;
  final CreateTaskUseCase _createTask;
  final UpdateTaskUseCase _updateTask;
  final DeleteTaskUseCase _deleteTask;
  final ToggleTaskUseCase _toggleTask;

  TaskBloc({
    required GetTasksUseCase getTasks,
    required CreateTaskUseCase createTask,
    required UpdateTaskUseCase updateTask,
    required DeleteTaskUseCase deleteTask,
    required ToggleTaskUseCase toggleTask,
  })  : _getTasks = getTasks,
        _createTask = createTask,
        _updateTask = updateTask,
        _deleteTask = deleteTask,
        _toggleTask = toggleTask,
        super(const TaskState()) {
    on<TaskLoadEvent>(_onLoad);
    on<TaskRefreshEvent>(_onRefresh);
    on<TaskLoadMoreEvent>(_onLoadMore);
    on<TaskFilterChangedEvent>(_onFilterChanged);
    on<TaskSearchChangedEvent>(_onSearchChanged);
    on<TaskCreateEvent>(_onCreate);
    on<TaskUpdateEvent>(_onUpdate);
    on<TaskDeleteEvent>(_onDelete);
    on<TaskToggleEvent>(_onToggle);
  }

  Future<void> _onLoad(TaskLoadEvent event, Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskLoadStatus.loading, tasks: [], page: 1, hasMore: true));
    final result = await _getTasks(page: 1, status: state.filterStatus, search: state.searchQuery);
    result.fold(
      (f) => emit(state.copyWith(status: TaskLoadStatus.failure, error: f.message)),
      (data) => emit(state.copyWith(
        status: TaskLoadStatus.success,
        tasks: List<TaskEntity>.from(data['tasks']),
        total: data['total'],
        page: 1,
        hasMore: 1 < (data['totalPages'] as int),
      )),
    );
  }

  Future<void> _onRefresh(TaskRefreshEvent event, Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskLoadStatus.refreshing, page: 1));
    final result = await _getTasks(page: 1, status: state.filterStatus, search: state.searchQuery);
    result.fold(
      (f) => emit(state.copyWith(status: TaskLoadStatus.failure, error: f.message)),
      (data) => emit(state.copyWith(
        status: TaskLoadStatus.success,
        tasks: List<TaskEntity>.from(data['tasks']),
        total: data['total'],
        page: 1,
        hasMore: 1 < (data['totalPages'] as int),
      )),
    );
  }

  Future<void> _onLoadMore(TaskLoadMoreEvent event, Emitter<TaskState> emit) async {
    if (!state.hasMore || state.status == TaskLoadStatus.loadingMore) return;
    emit(state.copyWith(status: TaskLoadStatus.loadingMore));
    final nextPage = state.page + 1;
    final result = await _getTasks(page: nextPage, status: state.filterStatus, search: state.searchQuery);
    result.fold(
      (f) => emit(state.copyWith(status: TaskLoadStatus.success, error: f.message)),
      (data) => emit(state.copyWith(
        status: TaskLoadStatus.success,
        tasks: [...state.tasks, ...List<TaskEntity>.from(data['tasks'])],
        total: data['total'],
        page: nextPage,
        hasMore: nextPage < (data['totalPages'] as int),
      )),
    );
  }

  Future<void> _onFilterChanged(TaskFilterChangedEvent event, Emitter<TaskState> emit) async {
    emit(state.copyWith(filterStatus: event.status, tasks: [], page: 1, hasMore: true));
    add(TaskLoadEvent());
  }

  Future<void> _onSearchChanged(TaskSearchChangedEvent event, Emitter<TaskState> emit) async {
    emit(state.copyWith(searchQuery: event.query, tasks: [], page: 1, hasMore: true));
    add(TaskLoadEvent());
  }

  Future<void> _onCreate(TaskCreateEvent event, Emitter<TaskState> emit) async {
    emit(state.copyWith(actionStatus: TaskActionStatus.loading));
    final result = await _createTask(
      title: event.title,
      description: event.description,
      priority: event.priority,
      dueDate: event.dueDate,
    );
    result.fold(
      (f) => emit(state.copyWith(actionStatus: TaskActionStatus.failure, error: f.message)),
      (task) {
        final updated = [task, ...state.tasks];
        emit(state.copyWith(
          actionStatus: TaskActionStatus.success,
          tasks: updated,
          total: state.total + 1,
          actionMessage: 'Task created!',
        ));
      },
    );
  }

  Future<void> _onUpdate(TaskUpdateEvent event, Emitter<TaskState> emit) async {
    emit(state.copyWith(actionStatus: TaskActionStatus.loading));
    final result = await _updateTask(
      event.id,
      title: event.title,
      description: event.description,
      status: event.status,
      priority: event.priority,
      dueDate: event.dueDate,
    );
    result.fold(
      (f) => emit(state.copyWith(actionStatus: TaskActionStatus.failure, error: f.message)),
      (task) {
        final updated = state.tasks.map((t) => t.id == task.id ? task : t).toList();
        emit(state.copyWith(
          actionStatus: TaskActionStatus.success,
          tasks: updated,
          actionMessage: 'Task updated!',
        ));
      },
    );
  }

  Future<void> _onDelete(TaskDeleteEvent event, Emitter<TaskState> emit) async {
    emit(state.copyWith(actionStatus: TaskActionStatus.loading));
    final result = await _deleteTask(event.id);
    result.fold(
      (f) => emit(state.copyWith(actionStatus: TaskActionStatus.failure, error: f.message)),
      (_) {
        final updated = state.tasks.where((t) => t.id != event.id).toList();
        emit(state.copyWith(
          actionStatus: TaskActionStatus.success,
          tasks: updated,
          total: state.total - 1,
          actionMessage: 'Task deleted',
        ));
      },
    );
  }

  Future<void> _onToggle(TaskToggleEvent event, Emitter<TaskState> emit) async {
    final result = await _toggleTask(event.id);
    result.fold(
      (f) => emit(state.copyWith(actionStatus: TaskActionStatus.failure, error: f.message)),
      (task) {
        final updated = state.tasks.map((t) => t.id == task.id ? task : t).toList();
        emit(state.copyWith(tasks: updated, actionStatus: TaskActionStatus.idle));
      },
    );
  }
}
