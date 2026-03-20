import { TaskStatus, Priority } from '@/types';
import { Clock, PlayCircle, CheckCircle2, ArrowDown, Minus, ArrowUp } from 'lucide-react';

export function StatusBadge({ status }: { status: TaskStatus }) {
  const map = {
    PENDING:     { className: 'badge-pending',  icon: <Clock size={10} />,        label: 'Pending' },
    IN_PROGRESS: { className: 'badge-progress', icon: <PlayCircle size={10} />,   label: 'In Progress' },
    COMPLETED:   { className: 'badge-done',     icon: <CheckCircle2 size={10} />, label: 'Done' },
  };
  const { className, icon, label } = map[status];
  return <span className={className}>{icon}{label}</span>;
}

export function PriorityBadge({ priority }: { priority: Priority }) {
  const map = {
    LOW:    { className: 'badge-low',    icon: <ArrowDown size={10} />, label: 'Low' },
    MEDIUM: { className: 'badge-medium', icon: <Minus size={10} />,     label: 'Medium' },
    HIGH:   { className: 'badge-high',   icon: <ArrowUp size={10} />,   label: 'High' },
  };
  const { className, icon, label } = map[priority];
  return <span className={className}>{icon}{label}</span>;
}
