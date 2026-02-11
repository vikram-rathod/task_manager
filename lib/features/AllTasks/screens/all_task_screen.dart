import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/task_model.dart';
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
        if (state.errorMessage != null && state.tasks.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 8),
            Expanded(child: _buildTaskList(state)),
          ],
        );
      },
    );
  }

  /// 🔍 Search Bar
  Widget _buildSearchBar() {
    return Padding(
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
                    context
                        .read<AllTaskBloc>()
                        .add(SearchQueryChanged(''));
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          context.read<AllTaskBloc>().add(SearchQueryChanged(value));
        },
      ),
    );
  }

  /// 📋 Task List
  Widget _buildTaskList(AllTaskState state) {
    // Initial loading
    if (state.isLoading && state.tasks.isEmpty) {
      return _buildShimmerList();
    }

    // Error (first page)
    if (state.errorMessage != null && state.tasks.isEmpty) {
      return _buildErrorView(state.errorMessage!);
    }

    final filteredTasks = state.searchQuery.isEmpty
        ? state.tasks
        : state.tasks.where((task) {
            return task.taskDescription
                .toLowerCase()
                .contains(state.searchQuery.toLowerCase());
          }).toList();

    // Empty
    if (filteredTasks.isEmpty) {
      return _buildEmptyView(
        state.searchQuery.isEmpty
            ? 'No tasks available'
            : 'No tasks found for "${state.searchQuery}"',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AllTaskBloc>().add(RefreshTasks());
        await Future.delayed(const Duration(milliseconds: 600));
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: state.hasReachedMax
            ? filteredTasks.length
            : filteredTasks.length + 1,
        itemBuilder: (context, index) {
          if (index >= filteredTasks.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return _buildTaskCard(filteredTasks[index]);
        },
      ),
    );
  }

  /// 🧾 Task Card
  Widget _buildTaskCard(TMTasksModel task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task ${task.taskId} clicked')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  _buildStatusChip(task.taskStatus),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.person, 'Maker', task.makerName),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.check_circle, 'Checker', task.checkerName),
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
        Expanded(
          child: Text(
            '$label: ${value ?? 'N/A'}',
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String? status) {
    final s = status?.toLowerCase() ?? '';
    Color color = Colors.grey;
    String text = 'N/A';

    if (s.contains('complete')) {
      color = Colors.green;
      text = 'Completed';
    } else if (s.contains('progress')) {
      color = Colors.orange;
      text = 'In Progress';
    } else if (s.contains('pending')) {
      color = Colors.blue;
      text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (_, __) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Container(height: 80, color: Colors.grey[300]),
      ),
    );
  }

  Widget _buildEmptyView(String message) {
    return Center(
      child: Text(message, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
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
