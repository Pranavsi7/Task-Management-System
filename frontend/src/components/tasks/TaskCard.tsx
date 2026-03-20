'use client';

import { Task } from '@/types';
import { StatusBadge, PriorityBadge } from '@/components/ui/Badges';
import { format } from 'date-fns';
import { Pencil, Trash2, ToggleLeft, ToggleRight, CalendarDays } from 'lucide-react';

interface Props {
  task: Task;
  onEdit: (task: Task) => void;
  onDelete: (id: string) => void;
  onToggle: (id: string) => void;
}

export default function TaskCard({ task, onEdit, onDelete, onToggle }: Props) {
  const isCompleted = task.status === 'COMPLETED';

  return (
    <div
      className="card p-4 flex flex-col gap-3 transition-all duration-200 hover:shadow-md group"
      style={{ opacity: isCompleted ? 0.75 : 1 }}
    >
      <div className="flex items-start justify-between gap-3">
        <p
          className="text-sm font-semibold leading-snug flex-1"
          style={{
            color: 'var(--text-primary)',
            textDecoration: isCompleted ? 'line-through' : 'none',
          }}
        >
          {task.title}
        </p>
        <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
          <button
            onClick={() => onToggle(task.id)}
            className="btn-ghost p-1.5 rounded-lg"
            title={isCompleted ? 'Mark incomplete' : 'Mark complete'}
            style={{ color: 'var(--brand)' }}
          >
            {isCompleted ? <ToggleRight size={16} /> : <ToggleLeft size={16} />}
          </button>
          <button onClick={() => onEdit(task)} className="btn-ghost p-1.5 rounded-lg" title="Edit">
            <Pencil size={14} />
          </button>
          <button
            onClick={() => onDelete(task.id)}
            className="btn-ghost p-1.5 rounded-lg"
            title="Delete"
            style={{ color: 'var(--danger)' }}
          >
            <Trash2 size={14} />
          </button>
        </div>
      </div>

      {task.description && (
        <p className="text-xs leading-relaxed line-clamp-2" style={{ color: 'var(--text-secondary)' }}>
          {task.description}
        </p>
      )}

      <div className="flex items-center gap-2 flex-wrap">
        <StatusBadge status={task.status} />
        <PriorityBadge priority={task.priority} />
        {task.dueDate && (
          <span className="inline-flex items-center gap-1 text-xs" style={{ color: 'var(--text-muted)' }}>
            <CalendarDays size={10} />
            {format(new Date(task.dueDate), 'MMM d, yyyy')}
          </span>
        )}
      </div>
    </div>
  );
}
