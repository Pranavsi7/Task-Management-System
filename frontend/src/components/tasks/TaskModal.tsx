'use client';

import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Task } from '@/types';
import { X } from 'lucide-react';

const schema = z.object({
  title: z.string().min(1, 'Title is required'),
  description: z.string().optional(),
  priority: z.enum(['LOW', 'MEDIUM', 'HIGH']),
  status: z.enum(['PENDING', 'IN_PROGRESS', 'COMPLETED']).optional(),
  dueDate: z.string().optional(),
});
type FormData = z.infer<typeof schema>;

interface Props {
  open: boolean;
  onClose: () => void;
  onSubmit: (data: FormData) => Promise<void>;
  task?: Task | null;
  submitting?: boolean;
}

export default function TaskModal({ open, onClose, onSubmit, task, submitting }: Props) {
  const { register, handleSubmit, reset, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: { priority: 'MEDIUM' },
  });

  useEffect(() => {
    if (task) {
      reset({
        title: task.title,
        description: task.description || '',
        priority: task.priority,
        status: task.status,
        dueDate: task.dueDate ? task.dueDate.slice(0, 10) : '',
      });
    } else {
      reset({ title: '', description: '', priority: 'MEDIUM', dueDate: '' });
    }
  }, [task, reset, open]);

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4" style={{ background: 'rgba(26,23,48,0.4)', backdropFilter: 'blur(4px)' }}>
      <div className="card w-full max-w-md p-6 relative">
        <button onClick={onClose} className="absolute top-4 right-4 btn-ghost p-1.5 rounded-lg" style={{ color: 'var(--text-muted)' }}>
          <X size={18} />
        </button>
        <h2 className="text-lg font-bold mb-5" style={{ color: 'var(--text-primary)' }}>
          {task ? 'Edit Task' : 'New Task'}
        </h2>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <label className="label">Title *</label>
            <input {...register('title')} className="input" placeholder="What needs to be done?" />
            {errors.title && <p className="text-xs mt-1" style={{ color: 'var(--danger)' }}>{errors.title.message}</p>}
          </div>

          <div>
            <label className="label">Description</label>
            <textarea {...register('description')} className="input resize-none" rows={3} placeholder="Optional details…" />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="label">Priority</label>
              <select {...register('priority')} className="input">
                <option value="LOW">Low</option>
                <option value="MEDIUM">Medium</option>
                <option value="HIGH">High</option>
              </select>
            </div>
            {task && (
              <div>
                <label className="label">Status</label>
                <select {...register('status')} className="input">
                  <option value="PENDING">Pending</option>
                  <option value="IN_PROGRESS">In Progress</option>
                  <option value="COMPLETED">Completed</option>
                </select>
              </div>
            )}
            <div className={task ? 'col-span-2' : ''}>
              <label className="label">Due Date</label>
              <input {...register('dueDate')} type="date" className="input" />
            </div>
          </div>

          <div className="flex gap-2 justify-end pt-2">
            <button type="button" onClick={onClose} className="btn-ghost">Cancel</button>
            <button type="submit" disabled={submitting} className="btn-primary">
              {submitting ? <span className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" /> : null}
              {task ? 'Save Changes' : 'Create Task'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
