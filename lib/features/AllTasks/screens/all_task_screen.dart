import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../createtask/models/task_model.dart';
import '../bloc/all_task_bloc.dart';


class AllTaskScreen extends StatelessWidget {
  const AllTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AllTasksView();
  }
}

class AllTasksView extends StatefulWidget {
  const AllTasksView({super.key});

  @override
  State<AllTasksView> createState() => _AllTasksViewState();
}

class _AllTasksViewState extends State<AllTasksView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<AllTaskBloc>().add(LoadNextPage());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AllTaskBloc, AllTaskState>(
      listener: (context, state) {
        if (state.status == AllTaskStatus.error && state.tasks.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to load tasks'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<AllTaskBloc>().add(
                        SearchQueryChanged(''),
                      );
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  context.read<AllTaskBloc>().add(
                    SearchQueryChanged(value),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Task List with Pull-to-Refresh
            Expanded(
              child: _buildTaskList(state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskList(AllTaskState state) {
    // Loading state (initial load)
    if (state.status == AllTaskStatus.loading || state.status == AllTaskStatus.idle) {
      return _buildShimmerList();
    }

    // Error state (first page)
    if (state.status == AllTaskStatus.error && state.tasks.isEmpty) {
      return _buildErrorView(state.errorMessage ?? 'Failed to load tasks');
    }

    // Filter tasks based on search query
    final filteredTasks = state.searchQuery.isEmpty
        ? state.tasks
        : state.tasks.where((task) {
      return task.taskDescription
          .toLowerCase()
          .contains(state.searchQuery.toLowerCase());
    }).toList();

    // Empty state
    if (filteredTasks.isEmpty && state.status == AllTaskStatus.success) {
      return _buildEmptyView(
        state.searchQuery.isEmpty
            ? 'No tasks available.'
            : 'No tasks found matching "${state.searchQuery}"',
      );
    }

    // Success - Show tasks with pull to refresh
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AllTaskBloc>().add(RefreshTasks());
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 800));
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: state.hasReachedMax
            ? filteredTasks.length
            : filteredTasks.length + 1,
        itemBuilder: (context, index) {
          if (index >= filteredTasks.length) {
            // Loading indicator at bottom
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final task = filteredTasks[index];
          return _buildTaskCard(task, state.searchQuery);
        },
      ),
    );
  }

  Widget _buildTaskCard(TMTasksModel task, String searchQuery) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to task details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task ${task.taskId} clicked'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Description with Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.taskDescription,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(task.taskStatus),
                ],
              ),

              const SizedBox(height: 12),

              // Project Name
              if (task.projectName != null && task.projectName!.isNotEmpty)
                _buildInfoRow(
                  Icons.business,
                  'Project',
                  task.projectName,
                ),

              const SizedBox(height: 8),

              // Maker
              _buildInfoRow(
                Icons.person,
                'Maker',
                task.makerName ?? 'N/A',
              ),

              const SizedBox(height: 8),

              // Checker
              _buildInfoRow(
                Icons.check_circle,
                'Checker',
                task.checkerName ?? 'N/A',
              ),

              // End Date
              if (task.taskEndDate != null && task.taskEndDate!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.calendar_today,
                  'End Date',
                  task.taskEndDate,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                TextSpan(
                  text: value ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    String displayStatus = status ?? 'N/A';

    switch (status?.toLowerCase()) {
      case 'completed':
      case 'complete':
        color = Colors.green;
        displayStatus = 'Completed';
        break;
      case 'in_progress':
      case 'in progress':
      case 'inprogress':
        color = Colors.orange;
        displayStatus = 'In Progress';
        break;
      case 'pending':
        color = Colors.blue;
        displayStatus = 'Pending';
        break;
      case 'overdue':
        color = Colors.red;
        displayStatus = 'Overdue';
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title shimmer
                Container(
                  height: 20,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                // Info rows shimmer
                ...List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<AllTaskBloc>().add(RefreshTasks());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}