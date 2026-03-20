import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/task_bloc.dart';
import '../widgets/task_card.dart';
import '../widgets/filter_bar.dart';
import '../../domain/entities/task_entity.dart';

class TaskDashboardPage extends StatefulWidget {
  const TaskDashboardPage({super.key});

  @override
  State<TaskDashboardPage> createState() => _TaskDashboardPageState();
}

class _TaskDashboardPageState extends State<TaskDashboardPage> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(TaskLoadEvent());
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<TaskBloc>().add(TaskLoadMoreEvent());
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext ctx, String id) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<TaskBloc>().add(TaskDeleteEvent(id));
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskBloc, TaskState>(
      listenWhen: (prev, curr) => curr.actionStatus != prev.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == TaskActionStatus.success && state.actionMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.actionMessage!),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ));
        } else if (state.actionStatus == TaskActionStatus.failure && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.error!),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            title: const Text('My Tasks'),
            actions: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (ctx, authState) {
                  final name = authState is AuthAuthenticated ? authState.user.name : '';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: PopupMenuButton<String>(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      offset: const Offset(0, 40),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primaryLight,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                      onSelected: (val) {
                        if (val == 'logout') {
                          ctx.read<AuthBloc>().add(AuthLogoutEvent());
                          Navigator.pushReplacementNamed(context, AppRouter.login);
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          enabled: false,
                          child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(children: const [
                            Icon(Icons.logout_rounded, size: 16, color: AppTheme.danger),
                            SizedBox(width: 8),
                            Text('Logout', style: TextStyle(color: AppTheme.danger)),
                          ]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => context.read<TaskBloc>().add(TaskSearchChangedEvent(v)),
                  decoration: InputDecoration(
                    hintText: 'Search tasks…',
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.textMuted),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchCtrl.clear();
                              context.read<TaskBloc>().add(TaskSearchChangedEvent(''));
                            },
                          )
                        : null,
                  ),
                ),
              ),
              // Filter chips
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FilterBar(
                  selected: state.filterStatus,
                  onChanged: (s) => context.read<TaskBloc>().add(TaskFilterChangedEvent(s)),
                ),
              ),
              // Task count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '${state.total} task${state.total != 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Task list
              Expanded(child: _buildBody(context, state)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, AppRouter.createTask),
            backgroundColor: AppTheme.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('New Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TaskState state) {
    if (state.status == TaskLoadStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    if (state.status == TaskLoadStatus.failure && state.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            Text(state.error ?? 'Something went wrong',
                style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<TaskBloc>().add(TaskRefreshEvent()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.check_box_outline_blank_rounded, color: AppTheme.primary, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('No tasks found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 6),
            const Text('Tap + to add your first task', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () async => context.read<TaskBloc>().add(TaskRefreshEvent()),
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        itemCount: state.tasks.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == state.tasks.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
            );
          }
          final task = state.tasks[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TaskCard(
              task: task,
              onToggle: () => context.read<TaskBloc>().add(TaskToggleEvent(task.id)),
              onEdit: () => Navigator.pushNamed(context, AppRouter.editTask, arguments: task),
              onDelete: () => _showDeleteDialog(context, task.id),
            ),
          );
        },
      ),
    );
  }
}
