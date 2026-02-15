import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/models/task_model.dart';

import '../../../reusables/reusable_tabs_section.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';

class TodaysTaskSection extends StatefulWidget {
  const TodaysTaskSection({super.key});

  @override
  State<TodaysTaskSection> createState() => _TodaysTaskSectionState();
}

class _TodaysTaskSectionState extends State<TodaysTaskSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _myTasksScrollController = ScrollController();
  final ScrollController _otherTasksScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Setup scroll listeners for pagination
    _myTasksScrollController.addListener(_onMyTasksScroll);
    _otherTasksScrollController.addListener(_onOtherTasksScroll);

    // Listen to tab changes - API call on every switch
    _tabController.addListener(_onTabChanged);

    // Load initial data for first tab (My Tasks) after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadMyTasks();
      }
    });
  }

  void _onTabChanged() {
    if (!mounted) return;

    // Trigger API call based on which tab is selected
    if (_tabController.index == 0) {
      _loadMyTasks();
    } else if (_tabController.index == 1) {
      _loadOtherTasks();
    }
  }

  void _loadMyTasks() {
    if (mounted) {
      context.read<HomeBloc>().add(const FetchTodaysTasks(page: 1, isMyTasks: true));
    }
  }

  void _loadOtherTasks() {
    if (mounted) {
      context.read<HomeBloc>().add(const FetchTodaysTasks(page: 1, isMyTasks: false));
    }
  }

  void _onMyTasksScroll() {
    if (!mounted) return;

    if (_myTasksScrollController.position.pixels >=
        _myTasksScrollController.position.maxScrollExtent * 0.8) {
      final state = context.read<HomeBloc>().state;
      if (!state.isMyTasksLoading && state.hasMoreMyTasks) {
        context.read<HomeBloc>().add(
          FetchTodaysTasks(page: state.myTasksPage + 1, isMyTasks: true),
        );
      }
    }
  }

  void _onOtherTasksScroll() {
    if (!mounted) return;

    if (_otherTasksScrollController.position.pixels >=
        _otherTasksScrollController.position.maxScrollExtent * 0.8) {
      final state = context.read<HomeBloc>().state;
      if (!state.isOtherTasksLoading && state.hasMoreOtherTasks) {
        context.read<HomeBloc>().add(
          FetchTodaysTasks(page: state.otherTasksPage + 1, isMyTasks: false),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _myTasksScrollController.dispose();
    _otherTasksScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Header Section
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Row(
            children: [
              Icon(
                Icons.today_rounded,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'Today\'s Tasks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),

        ReusableTabsSection(
          onTabChanged: (index) {
            if (index == 0) {
              _loadMyTasks();
            } else {
              _loadOtherTasks();
            }
          },
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline_rounded, size: 18),
                  SizedBox(width: 6),
                  Text('My Tasks'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.groups_outlined, size: 18),
                  SizedBox(width: 6),
                  Text('Other Tasks'),
                ],
              ),
            ),
          ],
          views: [
            _buildMyTasksList(),
            _buildOtherTasksList(),
          ],
        ),

      ],
    );
  }

  Widget _buildMyTasksList() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.isMyTasksLoading && state.myTasks.isEmpty) {
          return _buildLoadingState();
        }

        if (state.myTasksError != null && state.myTasks.isEmpty) {
          return _buildErrorState(
            message: state.myTasksError!,
            onRetry: _loadMyTasks,
          );
        }

        if (state.myTasks.isEmpty) {
          return _buildEmptyState(
            icon: Icons.task_alt_rounded,
            title: 'No tasks for today',
            subtitle: 'You\'re all caught up!',
          );
        }

        return ListView.builder(
          controller: _myTasksScrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: state.myTasks.length + (state.isMyTasksLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.myTasks.length) {
              return _buildPaginationLoader();
            }

            final task = state.myTasks[index];
            return _buildTaskCard(task, index);
          },
        );
      },
    );
  }

  Widget _buildOtherTasksList() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.isOtherTasksLoading && state.otherTasks.isEmpty) {
          return _buildLoadingState();
        }

        if (state.otherTasksError != null && state.otherTasks.isEmpty) {
          return _buildErrorState(
            message: state.otherTasksError!,
            onRetry: _loadOtherTasks,
          );
        }

        if (state.otherTasks.isEmpty) {
          return _buildEmptyState(
            icon: Icons.groups_rounded,
            title: 'No other tasks',
            subtitle: 'Team is all set for today',
          );
        }

        return ListView.builder(
          controller: _otherTasksScrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: state.otherTasks.length + (state.isOtherTasksLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.otherTasks.length) {
              return _buildPaginationLoader();
            }

            final task = state.otherTasks[index];
            return _buildTaskCard(task, index);
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading tasks...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({required String message, required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 56,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationLoader() {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildTaskCard(TMTasksModel task, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: index == 0 ? 12 : 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle task tap
            Navigator.pushNamed(context, '/taskDetails', arguments: task);
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Title and Status Row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.taskDescription ?? 'Untitled Task',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (task.taskStatus != null && task.taskStatus!.isNotEmpty)
                      _buildStatusBadge(task.taskStatus!),
                  ],
                ),

                const SizedBox(height: 10),

                // Metadata Row
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    // Project Name
                    if (task.projectName != null && task.projectName!.isNotEmpty)
                      _buildInfoChip(
                        icon: Icons.folder_outlined,
                        label: task.projectName!,
                        color: Colors.blue,
                      ),

                    // Due Date
                    if (task.dueDate != null && task.dueDate!.isNotEmpty)
                      _buildInfoChip(
                        icon: Icons.access_time_rounded,
                        label: task.dueDate!,
                        color: Colors.orange,
                      ),

                    // Priority
                    if (task.priority != null && task.priority!.isNotEmpty)
                      _buildPriorityChip(task.priority!),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color.withOpacity(0.7)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.9),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    final color = _getPriorityColor(priority);
    final label = _getPriorityLabel(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String taskStatus) {
    switch (taskStatus.toLowerCase()) {
      case 'completed':
      case 'complete':
        return const Color(0xFF10B981);
      case 'in progress':
      case 'ongoing':
      case 'in-progress':
        return const Color(0xFF3B82F6);
      case 'pending':
      case 'in queue':
        return const Color(0xFFF59E0B);
      case 'overdue':
      case 'over due':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    final priorityLower = priority.toLowerCase();

    if (priorityLower == '1' || priorityLower == 'high' || priorityLower == 'urgent') {
      return const Color(0xFFEF4444);
    } else if (priorityLower == '2' || priorityLower == 'medium') {
      return const Color(0xFFF59E0B);
    } else if (priorityLower == '3' || priorityLower == 'low') {
      return const Color(0xFF10B981);
    } else if (priorityLower == '4' || priorityLower == 'very low') {
      return const Color(0xFF3B82F6);
    }

    return Colors.grey;
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case '1':
        return 'High';
      case '2':
        return 'Medium';
      case '3':
        return 'Low';
      case '4':
        return 'Very Low';
      default:
        return priority;
    }
  }
}