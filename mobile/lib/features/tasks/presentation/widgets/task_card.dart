import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;

    return Card(
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? AppTheme.primary : Colors.transparent,
                        border: Border.all(
                          color: isCompleted ? AppTheme.primary : AppTheme.textMuted,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, size: 13, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18, color: AppTheme.textMuted),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (val) {
                      if (val == 'edit') onEdit();
                      if (val == 'delete') onDelete();
                      if (val == 'toggle') onToggle();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(children: [
                          Icon(isCompleted ? Icons.refresh : Icons.check_circle_outline,
                              size: 16, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(isCompleted ? 'Mark Pending' : 'Mark Done',
                              style: const TextStyle(fontSize: 13)),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(children: const [
                          Icon(Icons.edit_outlined, size: 16, color: AppTheme.textSecondary),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(fontSize: 13)),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(children: const [
                          Icon(Icons.delete_outline, size: 16, color: AppTheme.danger),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(fontSize: 13, color: AppTheme.danger)),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 34),
                  child: Text(
                    task.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 34),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _StatusChip(status: task.status),
                    _PriorityChip(priority: task.priority),
                    if (task.dueDate != null)
                      _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: DateFormat('MMM d, yyyy').format(task.dueDate!),
                        color: AppTheme.textMuted,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TaskStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    IconData icon;
    switch (status) {
      case TaskStatus.pending:
        bg = AppTheme.pending; fg = AppTheme.pendingText; icon = Icons.schedule;
        break;
      case TaskStatus.inProgress:
        bg = AppTheme.inProgress; fg = AppTheme.inProgressText; icon = Icons.play_circle_outline;
        break;
      case TaskStatus.completed:
        bg = AppTheme.completed; fg = AppTheme.completedText; icon = Icons.check_circle_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: fg),
        const SizedBox(width: 4),
        Text(status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
      ]),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final TaskPriority priority;
  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    IconData icon;
    switch (priority) {
      case TaskPriority.low:
        bg = const Color(0xFFF3F4F6); fg = const Color(0xFF6B7280); icon = Icons.arrow_downward;
        break;
      case TaskPriority.medium:
        bg = const Color(0xFFFEF3C7); fg = const Color(0xFF92400E); icon = Icons.remove;
        break;
      case TaskPriority.high:
        bg = const Color(0xFFFEE2E2); fg = const Color(0xFF991B1B); icon = Icons.arrow_upward;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: fg),
        const SizedBox(width: 4),
        Text(priority.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg)),
      ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ]);
}
