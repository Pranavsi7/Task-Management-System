import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';

class TaskFormPage extends StatefulWidget {
  final TaskEntity? task;
  const TaskFormPage({super.key, this.task});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  String _priority = 'MEDIUM';
  String? _status;
  DateTime? _dueDate;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task?.title ?? '');
    _descCtrl = TextEditingController(text: widget.task?.description ?? '');
    if (_isEditing) {
      _priority = widget.task!.priority.toApi();
      _status = widget.task!.status.toApi();
      _dueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final dueDateStr = _dueDate != null ? _dueDate!.toIso8601String() : null;

    if (_isEditing) {
      context.read<TaskBloc>().add(TaskUpdateEvent(
            id: widget.task!.id,
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            status: _status,
            priority: _priority,
            dueDate: dueDateStr,
          ));
    } else {
      context.read<TaskBloc>().add(TaskCreateEvent(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            priority: _priority,
            dueDate: dueDateStr,
          ));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskBloc, TaskState>(
      listenWhen: (prev, curr) => curr.actionStatus != prev.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == TaskActionStatus.success) {
          Navigator.pop(context);
        } else if (state.actionStatus == TaskActionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.error ?? 'An error occurred'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        final loading = state.actionStatus == TaskActionStatus.loading;
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Task' : 'New Task'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TextButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                        )
                      : Text(
                          _isEditing ? 'Save' : 'Create',
                          style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('TITLE *'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleCtrl,
                    autofocus: !_isEditing,
                    maxLength: 100,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      hintText: 'What needs to be done?',
                      counterText: '',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('DESCRIPTION'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(hintText: 'Optional details…'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel('PRIORITY'),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _priority,
                              decoration: const InputDecoration(),
                              items: ['LOW', 'MEDIUM', 'HIGH'].map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(p[0] + p.substring(1).toLowerCase(),
                                    style: const TextStyle(fontSize: 14)),
                              )).toList(),
                              onChanged: (v) => setState(() => _priority = v!),
                            ),
                          ],
                        ),
                      ),
                      if (_isEditing) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel('STATUS'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _status,
                                decoration: const InputDecoration(),
                                items: ['PENDING', 'IN_PROGRESS', 'COMPLETED'].map((s) {
                                  final label = s == 'IN_PROGRESS' ? 'In Progress'
                                      : s[0] + s.substring(1).toLowerCase();
                                  return DropdownMenuItem(
                                    value: s,
                                    child: Text(label, style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (v) => setState(() => _status = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('DUE DATE'),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.textMuted),
                          const SizedBox(width: 10),
                          Text(
                            _dueDate != null
                                ? DateFormat('MMM d, yyyy').format(_dueDate!)
                                : 'Pick a date',
                            style: TextStyle(
                              fontSize: 14,
                              color: _dueDate != null ? AppTheme.textPrimary : AppTheme.textMuted,
                            ),
                          ),
                          const Spacer(),
                          if (_dueDate != null)
                            GestureDetector(
                              onTap: () => setState(() => _dueDate = null),
                              child: const Icon(Icons.close, size: 16, color: AppTheme.textMuted),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      );
}
