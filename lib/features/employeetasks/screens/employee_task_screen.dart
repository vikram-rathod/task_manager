import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/task_model.dart';
import '../../../reusables/custom_tabs.dart';
import '../../../reusables/reusable_tabs_section.dart';
import '../../../reusables/task_card.dart';
import '../../home/model/employee_count_model.dart';
import '../bloc/employee_task_bloc.dart';

class EmployeeTaskScreen extends StatefulWidget {
  final EmployeeModel employee;

  const EmployeeTaskScreen({
    super.key,
    required this.employee,
  });

  @override
  State<EmployeeTaskScreen> createState() => _EmployeeTaskScreenState();
}

class _EmployeeTaskScreenState extends State<EmployeeTaskScreen>
    with SingleTickerProviderStateMixin {
  final Map<String, ScrollController> _scrollControllers = {};
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Store BLoC reference to use in dispose
  EmployeeTaskBloc? _bloc;

  // Track if initial data has been loaded
  bool _hasLoadedInitialData = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EmployeeTaskBloc>().add(
          InitializeEmployeeTabs(
            employeeUserId: widget.employee.userId.toString(),
          ),
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely store BLoC reference for use in dispose
    _bloc = context.read<EmployeeTaskBloc>();
  }

  void _initializeScrollControllers(List<TaskTab> tabs) {
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    _scrollControllers.clear();

    for (var tab in tabs) {
      _scrollControllers[tab.id] = ScrollController()
        ..addListener(() => _onScroll(tab.id));
    }
  }

  void _onTabChanged(int index) {
    final bloc = context.read<EmployeeTaskBloc>();
    bloc.add(ChangeEmployeeTaskTab(index));

    final tabId = bloc.state.tabs[index].id;
    final tabLabel = bloc.state.tabs[index].label;

    print('═══════════════════════════════════════════════════════');
    print('🔄 TAB SWITCHED');
    print('═══════════════════════════════════════════════════════');
    print('   Tab Index: $index');
    print('   Tab ID: $tabId');
    print('   Tab Label: $tabLabel');
    print('   Making API call for fresh data...');
    print('═══════════════════════════════════════════════════════');

    // Load fresh data for the selected tab only
    _loadTasksForTab(tabId, isRefresh: true);
  }

  void _loadTasksForTab(String tabId, {bool isRefresh = false}) {
    print(
        '📡 API CALL: Loading tasks for tabId: $tabId, isRefresh: $isRefresh, page: 1');

    context.read<EmployeeTaskBloc>().add(
      FetchEmployeeTasks(
        tabId: tabId,
        employeeId: widget.employee.userId.toString(),
        page: 1,
        search: _searchController.text.isEmpty
            ? null
            : _searchController.text,
        isRefresh: isRefresh,
      ),
    );
  }

  void _onScroll(String tabId) {
    if (!mounted) return;

    final controller = _scrollControllers[tabId];
    if (controller == null) return;

    if (controller.position.pixels >=
        controller.position.maxScrollExtent * 0.8) {
      final state = context.read<EmployeeTaskBloc>().state;

      if (state.currentTabId == tabId) {
        final isLoading = state.loadingByTab[tabId] ?? false;
        final isPaginationLoading =
            state.paginationLoadingByTab[tabId] ?? false;
        final hasMore = state.hasMoreByTab[tabId] ?? true;

        if (!isLoading && !isPaginationLoading && hasMore) {
          final currentPage = state.pagesByTab[tabId] ?? 1;
          final nextPage = currentPage + 1;

          print('📄 Loading next page: $nextPage for tab: $tabId');

          context.read<EmployeeTaskBloc>().add(
            FetchEmployeeTasks(
              tabId: tabId,
              employeeId: widget.employee.userId.toString(),
              page: nextPage,
              search: _searchController.text.isEmpty
                  ? null
                  : _searchController.text,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    // Reset the BLoC state when leaving the screen using stored reference
    _bloc?.add(const ResetEmployeeTaskState());

    // Reset flag for next screen visit
    _hasLoadedInitialData = false;

    _searchController.dispose();
    _animationController.dispose();
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final employee = widget.employee;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF8F9FE),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildModernAppBar(theme, isDark, employee),
            // Main Content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildTasksSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar(
      ThemeData theme, bool isDark, EmployeeModel employee) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1A1F3A) : theme.primaryColor,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                const Color(0xFF1A1F3A),
                const Color(0xFF2D3561),
              ]
                  : [
                theme.primaryColor,
                theme.primaryColor.withOpacity(0.85),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              child: Row(
                children: [
                  // Compact Avatar with Status Indicator
                  Stack(
                    children: [
                      Hero(
                        tag: 'employee_${employee.userId}',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            backgroundImage: employee.userProfileUrl.isNotEmpty
                                ? NetworkImage(employee.userProfileUrl)
                                : null,
                            child: employee.userProfileUrl.isEmpty
                                ? Text(
                              employee.userName.isNotEmpty
                                  ? employee.userName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            )
                                : null,
                          ),
                        ),
                      ),
                      // Active status indicator
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Compact Name and Stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          employee.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildMicroStat(
                              icon: Icons.check_circle_outline_rounded,
                              value: employee.completedTaskCount.toString(),
                              label: 'Done',
                            ),
                            const SizedBox(width: 12),
                            _buildMicroStat(
                              icon: Icons.pending_actions_rounded,
                              value: employee.totalPendingTask.toString(),
                              label: 'Pending',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMicroStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTasksSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<EmployeeTaskBloc, EmployeeTaskState>(
      builder: (context, state) {
        if (state.tabs.isEmpty) {
          return _buildLoadingState();
        }

        // Auto-load first tab data when tabs are first initialized
        if (!_hasLoadedInitialData && state.tabs.isNotEmpty) {
          _hasLoadedInitialData = true;

          // Schedule data load for next frame to avoid building during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final firstTabId = state.tabs[0].id;
              print('AUTO-LOADING: Initial data for first tab (${state.tabs[0].label}, id: $firstTabId)');
              _loadTasksForTab(firstTabId, isRefresh: false);

              // Initialize scroll controllers
              _initializeScrollControllers(state.tabs);
            }
          });
        }

        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0A0E21)
                      : const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.4)
                          : Colors.grey[500],
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isDark
                          ? Colors.white.withOpacity(0.4)
                          : Colors.grey[500],
                      size: 22,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: isDark
                            ? Colors.white.withOpacity(0.4)
                            : Colors.grey[500],
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _loadTasksForTab(state.currentTabId,
                            isRefresh: true);
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (query) {
                    _loadTasksForTab(state.currentTabId, isRefresh: true);
                  },
                ),
              ),
            ),

            // Reusable Tabs Section with Counts
            ReusableTabsSection(
              tabs: state.tabs
                  .map((tab) => Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(tab.icon, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        tab.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ))
                  .toList(),
              views: state.tabs.map((tab) => _buildTasksList(tab.id)).toList(),
              onTabChanged: _onTabChanged,
              tabCounts: [
                widget.employee.pendingAtMe,
                widget.employee.pendingAtOther,
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTasksList(String tabId) {
    return BlocBuilder<EmployeeTaskBloc, EmployeeTaskState>(
      builder: (context, state) {
        final isLoading = state.loadingByTab[tabId] ?? false;
        final isPaginationLoading =
            state.paginationLoadingByTab[tabId] ?? false;
        final error = state.errorsByTab[tabId];
        final tasks = state.tasksByTab[tabId] ?? [];

        if (isLoading && tasks.isEmpty) {
          return _buildLoadingState();
        }

        if (error != null && tasks.isEmpty) {
          return _buildErrorState(
            message: error,
            onRetry: () => _loadTasksForTab(tabId, isRefresh: true),
          );
        }

        if (tasks.isEmpty) {
          return _buildEmptyState(
            icon: Icons.task_alt_rounded,
            title: 'No Tasks Found',
            subtitle: 'There are no tasks to display for this category',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _loadTasksForTab(tabId, isRefresh: true);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: const Color(0xFF667EEA),
          child: ListView.builder(
            controller: _scrollControllers[tabId],
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: tasks.length + (isPaginationLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= tasks.length) {
                return _buildPaginationLoader();
              }

              final taskModel = tasks[index] as TMTasksModel;

              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: TaskCard(
                  task: taskModel,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Task ${taskModel.taskId} clicked'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  onChatTap: () {
                    Navigator.pushNamed(
                      context,
                      '/taskChat',
                      arguments: taskModel,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF667EEA),
              ),
            ),
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

  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 56,
              color: const Color(0xFF667EEA).withOpacity(0.6),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationLoader() {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
        ),
      ),
    );
  }
}