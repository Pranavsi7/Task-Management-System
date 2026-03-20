import '../../../../core/network/api_client.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<Map<String, dynamic>> getTasks({int page, int limit, String? status, String? search});
  Future<TaskModel> createTask({required String title, String? description, String? priority, String? dueDate});
  Future<TaskModel> updateTask(String id, {String? title, String? description, String? status, String? priority, String? dueDate});
  Future<void> deleteTask(String id);
  Future<TaskModel> toggleTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final ApiClient _apiClient;
  TaskRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> getTasks({int page = 1, int limit = 10, String? status, String? search}) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final response = await _apiClient.dio.get('/tasks', queryParameters: params);
    final data = response.data;
    return {
      'tasks': (data['tasks'] as List).map((e) => TaskModel.fromJson(e)).toList(),
      'total': data['total'],
      'page': data['page'],
      'totalPages': data['totalPages'],
    };
  }

  @override
  Future<TaskModel> createTask({required String title, String? description, String? priority, String? dueDate}) async {
    final body = <String, dynamic>{'title': title};
    if (description != null && description.isNotEmpty) body['description'] = description;
    if (priority != null) body['priority'] = priority;
    if (dueDate != null && dueDate.isNotEmpty) body['dueDate'] = dueDate;

    final response = await _apiClient.dio.post('/tasks', data: body);
    return TaskModel.fromJson(response.data);
  }

  @override
  Future<TaskModel> updateTask(String id, {String? title, String? description, String? status, String? priority, String? dueDate}) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (status != null) body['status'] = status;
    if (priority != null) body['priority'] = priority;
    if (dueDate != null) body['dueDate'] = dueDate;

    final response = await _apiClient.dio.patch('/tasks/$id', data: body);
    return TaskModel.fromJson(response.data);
  }

  @override
  Future<void> deleteTask(String id) => _apiClient.dio.delete('/tasks/$id');

  @override
  Future<TaskModel> toggleTask(String id) async {
    final response = await _apiClient.dio.patch('/tasks/$id/toggle');
    return TaskModel.fromJson(response.data);
  }
}
