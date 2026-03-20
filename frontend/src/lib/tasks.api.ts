import api from './api';
import { Task, PaginatedTasks, TaskStatus, Priority } from '@/types';

export interface GetTasksParams {
  page?: number;
  limit?: number;
  status?: TaskStatus | '';
  search?: string;
}

export interface TaskPayload {
  title: string;
  description?: string;
  priority?: Priority;
  dueDate?: string;
}

export const tasksApi = {
  getAll: (params: GetTasksParams = {}) =>
    api.get<PaginatedTasks>('/tasks', { params }).then((r) => r.data),

  getOne: (id: string) =>
    api.get<Task>(`/tasks/${id}`).then((r) => r.data),

  create: (data: TaskPayload) =>
    api.post<Task>('/tasks', data).then((r) => r.data),

  update: (id: string, data: Partial<TaskPayload & { status: TaskStatus }>) =>
    api.patch<Task>(`/tasks/${id}`, data).then((r) => r.data),

  delete: (id: string) =>
    api.delete(`/tasks/${id}`),

  toggle: (id: string) =>
    api.patch<Task>(`/tasks/${id}/toggle`).then((r) => r.data),
};
