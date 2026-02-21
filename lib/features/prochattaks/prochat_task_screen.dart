import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/models/task_model.dart';
import 'package:task_manager/features/home/model/quick_action_model.dart';
import '../../reusables/task_card.dart';
import 'assign_task_bottom_sheet.dart';
import 'bloc/prochat_task_bloc.dart';

class ProChatTaskScreen extends StatefulWidget {
  final QuickActionModel quickActionModel;

  const ProChatTaskScreen({super.key, required this.quickActionModel});

  @override
  State<ProChatTaskScreen> createState() => _ProChatTaskScreenState();
}

class _ProChatTaskScreenState extends State<ProChatTaskScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProchatTaskBloc>().add(const ProchatTaskFetched());
    context.read<ProchatTaskBloc>().add(const ProchatTaskSyncCheck());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<ProchatTaskBloc>();
    bloc.add(const ProchatTaskRefreshed());
    bloc.add(const ProchatTaskSyncCheck());
    await bloc.stream.firstWhere((s) => !s.isRefreshing);
  }

  void _onTaskTap(TMTasksModel task) {
    Navigator.pushNamed(context, '/taskDetails', arguments: task);
  }

  void _onChatTap(TMTasksModel task) {
    Navigator.pushNamed(context, '/taskChat', arguments: task);
  }

  void _onAssignTap(TMTasksModel task) {
    context.read<ProchatTaskBloc>().add(ProchatLoadProjectList(task: task));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ProchatTaskBloc>(),
        child: AssignTaskBottomSheet(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProChat Tasks'),
        actions: [
          // refresh icon
          IconButton(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),

        ],
        centerTitle: false,
      ),
      body: BlocConsumer<ProchatTaskBloc, ProchatTaskState>(
        listenWhen: (prev, curr) =>
        // Error snackbar
        (curr.isError && !prev.isError) ||
            // New tasks detected — show snackbar nudge
            (!prev.hasNewTasksToSync && curr.hasNewTasksToSync),
        listener: (context, state) {
          if (state.isError && !state.hasData) return;

          if (state.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          // if (state.hasNewTasksToSync) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          //       content: const Row(
          //         children: [
          //           Icon(Icons.sync_rounded, color: Colors.white, size: 18),
          //           SizedBox(width: 10),
          //           Expanded(
          //             child: Text(
          //               'New ProChat tasks available to sync',
          //               style: TextStyle(fontWeight: FontWeight.w500),
          //             ),
          //           ),
          //         ],
          //       ),
          //       backgroundColor: scheme.primaryContainer,
          //       behavior: SnackBarBehavior.floating,
          //       duration: const Duration(seconds: 6),
          //       margin: const EdgeInsets.all(12),
          //       shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(12)),
          //       action: SnackBarAction(
          //         label: 'SYNC NOW',
          //         textColor: Colors.white,
          //         onPressed: () {
          //           ScaffoldMessenger.of(context).hideCurrentSnackBar();
          //           context
          //               .read<ProchatTaskBloc>()
          //               .add(const ProchatSyncAndReload());
          //         },
          //       ),
          //     ),
          //   );
          // }
        },
        builder: (context, state) {
          // ── Full-page loading
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Full-page error
          if (state.isError && !state.hasData) {
            return _ErrorView(
              message: state.errorMessage,
              onRetry: () => context
                  .read<ProchatTaskBloc>()
                  .add(const ProchatTaskRefreshed()),
            );
          }

          // ── Empty state
          if (state.isEmpty) {
            return const _EmptyView();
          }

          return Column(
            children: [
              // ── Sync banner (visible when hasNewTasksToSync = true)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: state.hasNewTasksToSync
                    ? _SyncBanner(
                  isSyncing: state.isSyncing,
                  onSync: () => context
                      .read<ProchatTaskBloc>()
                      .add(const ProchatSyncAndReload()),
                )
                    : state.isSyncing
                    ? const _SyncingIndicator()
                    : const SizedBox.shrink(),
              ),

              // ── Task list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: Stack(
                    children: [
                      ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        itemCount: state.tasks.length,
                        itemBuilder: (context, index) {
                          final task = state.tasks[index];
                          return TaskCard(
                            task: task,
                            onTap: () => _onTaskTap(task),
                            onChatTap: () => _onChatTap(task),
                            onAssignTap:
                            (task.prochatTaskId?.isNotEmpty ?? false)
                                ? () => _onAssignTap(task)
                                : null,
                          );
                        },
                      ),
                      if (state.isRefreshing)
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(minHeight: 3),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SyncBanner extends StatelessWidget {
  final bool isSyncing;
  final VoidCallback onSync;

  const _SyncBanner({required this.isSyncing, required this.onSync});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('sync-banner'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.primary,
      ),
      child: Row(
        children: [
           Icon(Icons.sync_rounded, color: scheme.onPrimary, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'New ProChat tasks available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: isSyncing ? null : onSync,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: isSyncing
                  ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text(
                'Sync Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncingIndicator extends StatelessWidget {
  const _SyncingIndicator();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('syncing-indicator'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: scheme.primary.withOpacity(0.85),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: scheme.onPrimary,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Syncing ProChat tasks...',
            style: TextStyle(
              color: scheme.onPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message.isNotEmpty ? message : 'Something went wrong.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No tasks found.',
              style: TextStyle(fontSize: 15, color: Colors.grey[600])),
        ],
      ),
    );
  }
}