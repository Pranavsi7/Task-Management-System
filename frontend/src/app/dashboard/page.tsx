'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/hooks/useAuth';
import { useTasks } from '@/hooks/useTasks';
import Navbar from '@/components/layout/Navbar';
import TaskCard from '@/components/tasks/TaskCard';
import TaskModal from '@/components/tasks/TaskModal';
import { Task, TaskStatus } from '@/types';
import { Plus, Search, SlidersHorizontal, ChevronLeft, ChevronRight, ListTodo } from 'lucide-react';
import toast from 'react-hot-toast';

const STATUS_FILTERS: { label: string; value: TaskStatus | '' }[] = [
  { label: 'All', value: '' },
  { label: 'Pending', value: 'PENDING' },
  { label: 'In Progress', value: 'IN_PROGRESS' },
  { label: 'Completed', value: 'COMPLETED' },
];

export default function DashboardPage() {
  const { user, loading: authLoading } = useAuth();
  const router = useRouter();
  const [modalOpen, setModalOpen] = useState(false);
  const [editingTask, setEditingTask] = useState<Task | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [searchInput, setSearchInput] = useState('');

  const {
    tasks, total, totalPages, loading, params,
    updateParams, createTask, updateTask, deleteTask, toggleTask, setPage,
  } = useTasks();

  useEffect(() => {
    if (!authLoading && !user) router.replace('/auth/login');
  }, [user, authLoading, router]);

  // Debounce search
  useEffect(() => {
    const t = setTimeout(() => updateParams({ search: searchInput }), 350);
    return () => clearTimeout(t);
  }, [searchInput]); // eslint-disable-line

  const handleCreate = async (data: Parameters<typeof createTask>[0]) => {
    setSubmitting(true);
    try {
      await createTask(data);
      setModalOpen(false);
    } catch {
      toast.error('Failed to create task');
    } finally {
      setSubmitting(false);
    }
  };

  const handleUpdate = async (data: Partial<Task>) => {
    if (!editingTask) return;
    setSubmitting(true);
    try {
      await updateTask(editingTask.id, data);
      setEditingTask(null);
      setModalOpen(false);
    } catch {
      toast.error('Failed to update task');
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Delete this task?')) return;
    try {
      await deleteTask(id);
    } catch {
      toast.error('Failed to delete task');
    }
  };

  const handleToggle = async (id: string) => {
    try {
      await toggleTask(id);
    } catch {
      toast.error('Failed to update task');
    }
  };

  const openCreate = () => { setEditingTask(null); setModalOpen(true); };
  const openEdit = (task: Task) => { setEditingTask(task); setModalOpen(true); };

  if (authLoading) return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="w-8 h-8 rounded-full border-2 border-[var(--brand)] border-t-transparent animate-spin" />
    </div>
  );

  return (
    <div className="min-h-screen" style={{ background: 'var(--bg)' }}>
      <Navbar />

      <main className="max-w-4xl mx-auto px-4 py-8">
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-2xl font-bold" style={{ color: 'var(--text-primary)' }}>
              My Tasks
            </h1>
            <p className="text-sm mt-0.5" style={{ color: 'var(--text-secondary)' }}>
              {total} task{total !== 1 ? 's' : ''} total
            </p>
          </div>
          <button onClick={openCreate} className="btn-primary">
            <Plus size={16} />
            New Task
          </button>
        </div>

        {/* Filters bar */}
        <div className="card p-3 mb-5 flex flex-col sm:flex-row gap-3 items-stretch sm:items-center">
          <div className="relative flex-1">
            <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2" style={{ color: 'var(--text-muted)' }} />
            <input
              value={searchInput}
              onChange={(e) => setSearchInput(e.target.value)}
              className="input pl-9"
              placeholder="Search tasks…"
            />
          </div>
          <div className="flex items-center gap-1">
            <SlidersHorizontal size={14} style={{ color: 'var(--text-muted)' }} className="mr-1" />
            {STATUS_FILTERS.map((f) => (
              <button
                key={f.value}
                onClick={() => updateParams({ status: f.value })}
                className="px-3 py-1.5 rounded-lg text-xs font-semibold transition-all"
                style={{
                  background: params.status === f.value ? 'var(--brand)' : 'transparent',
                  color: params.status === f.value ? '#fff' : 'var(--text-secondary)',
                }}
              >
                {f.label}
              </button>
            ))}
          </div>
        </div>

        {/* Task list */}
        {loading ? (
          <div className="flex justify-center py-16">
            <div className="w-8 h-8 rounded-full border-2 border-[var(--brand)] border-t-transparent animate-spin" />
          </div>
        ) : tasks.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20 gap-3" style={{ color: 'var(--text-muted)' }}>
            <ListTodo size={40} strokeWidth={1.2} />
            <p className="text-sm font-medium">No tasks found</p>
            <button onClick={openCreate} className="btn-primary mt-2">
              <Plus size={14} /> Add your first task
            </button>
          </div>
        ) : (
          <div className="grid gap-3 sm:grid-cols-2">
            {tasks.map((task) => (
              <TaskCard
                key={task.id}
                task={task}
                onEdit={openEdit}
                onDelete={handleDelete}
                onToggle={handleToggle}
              />
            ))}
          </div>
        )}

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex items-center justify-center gap-3 mt-8">
            <button
              onClick={() => setPage((params.page || 1) - 1)}
              disabled={(params.page || 1) <= 1}
              className="btn-ghost p-2 rounded-lg disabled:opacity-40"
            >
              <ChevronLeft size={16} />
            </button>
            <span className="text-sm" style={{ color: 'var(--text-secondary)' }}>
              Page {params.page} of {totalPages}
            </span>
            <button
              onClick={() => setPage((params.page || 1) + 1)}
              disabled={(params.page || 1) >= totalPages}
              className="btn-ghost p-2 rounded-lg disabled:opacity-40"
            >
              <ChevronRight size={16} />
            </button>
          </div>
        )}
      </main>

      <TaskModal
        open={modalOpen}
        onClose={() => { setModalOpen(false); setEditingTask(null); }}
        onSubmit={editingTask ? handleUpdate : handleCreate}
        task={editingTask}
        submitting={submitting}
      />
    </div>
  );
}
