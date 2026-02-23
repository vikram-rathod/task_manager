import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/models/task_model.dart';
import 'package:task_manager/features/projecttasks/ui/widgets/role_filters.dart';
import 'package:task_manager/features/projecttasks/ui/widgets/task_list.dart';
import 'package:task_manager/features/projecttasks/ui/widgets/user_drop_down.dart';
import 'package:task_manager/reusables/task_card.dart';

import '../../../reusables/searchable_dropdown.dart';
import '../../auth/models/user_model.dart';
import '../../home/model/project_count_model.dart';
import '../bloc/project_wise_task_bloc.dart';
import '../bloc/project_wise_task_event.dart';
import '../bloc/project_wise_task_state.dart';

class ProjectWiseTaskScreen extends StatefulWidget {
  final ProjectCountModel projectCountModel;

  const ProjectWiseTaskScreen({super.key, required this.projectCountModel});

  @override
  State<ProjectWiseTaskScreen> createState() => _ProjectWiseTaskScreenState();
}

class _ProjectWiseTaskScreenState extends State<ProjectWiseTaskScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectWiseTaskBloc>().add(
      InitializeProjectWiseTask(widget.projectCountModel),
    );
  }

  @override
  void dispose() {
    context.read<ProjectWiseTaskBloc>().add(const ResetProjectWiseTaskState());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectWiseTaskBloc, ProjectWiseTaskState>(
      listener: (context, state) {
        if (state.taskStatus is TaskListError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text((state.taskStatus as TaskListError).message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
        if (state.checkerMakerUserStatus is UserListError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  (state.checkerMakerUserStatus as UserListError).message,
                ),
              ),
            );
        }
        if (state.pcEngineerUserStatus is UserListError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  (state.pcEngineerUserStatus as UserListError).message,
                ),
              ),
            );
        }
      },
      child: ProjectWiseTaskView(),
    );
  }
}

class ProjectWiseTaskView extends StatefulWidget {
  const ProjectWiseTaskView({super.key});

  @override
  State<ProjectWiseTaskView> createState() => _ProjectWiseTaskViewState();
}

class _ProjectWiseTaskViewState extends State<ProjectWiseTaskView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    if (currentScroll >= maxScroll - 200) {
      context.read<ProjectWiseTaskBloc>().add(const LoadNextPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<ProjectWiseTaskBloc, ProjectWiseTaskState>(
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(context, state),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<ProjectWiseTaskBloc>().add(const RefreshTasks());
              // Wait for refresh to complete
              await Future.delayed(const Duration(milliseconds: 800));
            },
            child: Column(
              children: [
                // ── Role filter tabs ─────────────────────────────────────
                RoleFilterTabs(
                  selectedRole: state.selectedRole,
                  onRoleSelected: (role) {
                    context.read<ProjectWiseTaskBloc>().add(
                      UserRoleSelected(role),
                    );
                  },
                ),

                Divider(
                  height: 1,
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                ),

                // ── User dropdowns ───────────────────────────────────────
                UserDropdownSection(state: state),

                // ── Task content ─────────────────────────────────────────
                Expanded(
                  child: _TaskContent(
                    state: state,
                    scrollController: _scrollController,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ProjectWiseTaskState state,
  ) {
    return AppBar(
      leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.project?.projectName ?? '',
            style: Theme.of(context).textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TaskContent extends StatelessWidget {
  final ProjectWiseTaskState state;
  final ScrollController scrollController;

  const _TaskContent({required this.state, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final taskStatus = state.taskStatus;

    if (taskStatus is TaskListIdle) {
      return _IdleState(role: state.selectedRole);
    }

    if (taskStatus is TaskListLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (taskStatus is TaskListError) {
      return _ErrorState(
        message: taskStatus.message,
        onRetry: () =>
            context.read<ProjectWiseTaskBloc>().add(const RefreshTasks()),
      );
    }

    if (taskStatus is TaskListSuccess) {
      final tasks = taskStatus.tasks;
      if (tasks.isEmpty) {
        return const _EmptyState();
      }
      return TaskList(
        tasks: tasks,
        isLoadingMore: state.isLoadingMore,
        scrollController: scrollController,
      );
    }

    return const SizedBox.shrink();
  }
}

class _IdleState extends StatelessWidget {
  final UserRoleType role;

  const _IdleState({required this.role});

  @override
  Widget build(BuildContext context) {
    final (title, detail) = switch (role) {
      UserRoleType.maker => (
        'No Maker Selected',
        'Please select a Maker to view project-wise tasks.',
      ),
      UserRoleType.checker => (
        'No Checker Selected',
        'Please select a Checker to see the tasks assigned for checking.',
      ),
      UserRoleType.pcEngineer => (
        'No Planner/Coordinator Selected',
        'Please select a Planner/Coordinator to load their project tasks.',
      ),
      UserRoleType.all => (
        'No Tasks Available',
        'Tasks are not available right now. Please try again.',
      ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No tasks found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}


