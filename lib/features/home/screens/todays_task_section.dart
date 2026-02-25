import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:task_manager/core/models/task_model.dart';

import '../../../reusables/compact_task_card.dart';
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

    _myTasksScrollController.addListener(_onMyTasksScroll);
    _otherTasksScrollController.addListener(_onOtherTasksScroll);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadMyTasks();
    });
  }

  void _onTabChanged() {
    if (!mounted) return;
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
    final scheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Row(
            children: [
              Icon(Icons.today_rounded, color: theme.primaryColor, size: 20),
              const SizedBox(width: 12),
               Text(
                'In Progress Tasks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: scheme.onSurface,
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
                  Text("Others's Task"),
                ],
              ),
            ),
          ],
          height: MediaQuery.of(context).size.height * 0.30,
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
        if (state.isMyTasksLoading) return _buildLoadingState();

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
          shrinkWrap: true,
          controller: _myTasksScrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: state.myTasks.length + (state.isMyTasksLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.myTasks.length) return _buildPaginationLoader();
            final task = state.myTasks[index];
            return CompactTaskCard(
              task: task,
              onTap: () => Navigator.pushNamed(context, '/taskDetails', arguments: task),
            );
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
            if (index == state.otherTasks.length) return _buildPaginationLoader();
            final task = state.otherTasks[index];
            return CompactTaskCard(
              task: task,
              onTap: () => Navigator.pushNamed(context, '/taskDetails', arguments: task),

            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        highlightColor: isDark ? Colors.grey.shade600 : Colors.grey.shade100,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 180,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 70,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(
                  3,
                      (_) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 36, color: Colors.red[400]),
            ),
            const SizedBox(height: 10),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

  // ── Fixed: mainAxisSize.min prevents unbounded height ─────────────────────
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: Colors.grey[400]),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
}