'use client';

import { useState, useEffect, useCallback } from 'react';
import { Task, TaskStatus } from '@/types';
import { tasksApi, GetTasksParams } from '@/lib/tasks.api';
import toast from 'react-hot-toast';

export function useTasks() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [total, setTotal] = useState(0);
  const [totalPages, setTotalPages] = useState(1);
  const [loading, setLoading] = useState(true);
  const [params, setParams] = useState<GetTasksParams>({ page: 1, limit: 10, search: '', status: '' });

  const fetchTasks = useCallback(async (p: GetTasksParams = params) => {
    setLoading(true);
    try {
      const data = await tasksApi.getAll(p);
      setTasks(data.tasks);
      setTotal(data.total);
      setTotalPages(data.totalPages);
    } catch {
      toast.error('Failed to load tasks');
    } finally {
      setLoading(false);
    }
  }, [params]);

  useEffect(() => { fetchTasks(params); }, [params]); // eslint-disable-line

  const updateParams = (updates: Partial<GetTasksParams>) => {
    const next = { ...params, ...updates, page: 1 };
    setParams(next);
  };

  const createTask = async (data: { title: string; description?: string; priority?: string; dueDate?: string }) => {
    const task = await tasksApi.create(data as Parameters<typeof tasksApi.create>[0]);
    toast.success('Task created!');
    fetchTasks(params);
    return task;
  };

  const updateTask = async (id: string, data: Partial<Task>) => {
    const task = await tasksApi.update(id, data);
    setTasks((prev) => prev.map((t) => (t.id === id ? task : t)));
    toast.success('Task updated!');
    return task;
  };

  const deleteTask = async (id: string) => {
    await tasksApi.delete(id);
    setTasks((prev) => prev.filter((t) => t.id !== id));
    setTotal((prev) => prev - 1);
    toast.success('Task deleted');
  };

  const toggleTask = async (id: string) => {
    const task = await tasksApi.toggle(id);
    setTasks((prev) => prev.map((t) => (t.id === id ? task : t)));
  };

  const setPage = (page: number) => setParams((p) => ({ ...p, page }));

  return {
    tasks, total, totalPages, loading, params,
    updateParams, createTask, updateTask, deleteTask, toggleTask,
    setPage, refresh: () => fetchTasks(params),
  };
}
