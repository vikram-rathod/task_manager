import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/overdue/bloc/over_due_bloc.dart';

import '../../../core/models/task_model.dart';
import '../../../reusables/custom_tabs.dart';
import '../../../reusables/reusable_tabs_section.dart';
import '../../../reusables/task_card.dart';
import '../../home/model/quick_action_model.dart';

class OverDueTaskScreen extends StatefulWidget {
  final QuickActionModel action;

  const OverDueTaskScreen({super.key, required this.action});

  @override
  State<OverDueTaskScreen> createState() => _OverDueTaskScreenState();
}

class _OverDueTaskScreenState extends State<OverDueTaskScreen>
    with SingleTickerProviderStateMixin {
  final Map<String, ScrollController> _scrollControllers = {};
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Store BLoC reference to use in dispose
  OverDueBloc? _bloc;

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
        context.read<OverDueBloc>().add(InitializeTabs());
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely store BLoC reference for use in dispose
    _bloc = context.read<OverDueBloc>();
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
    final bloc = context.read<OverDueBloc>();
    bloc.add(ChangeTaskTab(index));

    final tabId = bloc.state.tabs[index].id;
    final tabLabel = bloc.state.tabs[index].label;

    print('═══════════════════════════════════════════════════════');
    print('TAB SWITCHED');
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
      'API CALL: Loading tasks for tabId: $tabId, isRefresh: $isRefresh, page: 1',
    );

    context.read<OverDueBloc>().add(
      FetchDueTasks(
        tabId: tabId,
        page: 1,
        search: _searchController.text.isEmpty ? null : _searchController.text,
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
      final state = context.read<OverDueBloc>().state;

      if (state.currentTabId == tabId) {
        final isLoading = state.loadingByTab[tabId] ?? false;
        final isPaginationLoading =
            state.paginationLoadingByTab[tabId] ?? false;
        final hasMore = state.hasMoreByTab[tabId] ?? true;

        if (!isLoading && !isPaginationLoading && hasMore) {
          final currentPage = state.pagesByTab[tabId] ?? 1;
          final nextPage = currentPage + 1;

          print(' Loading next page: $nextPage for tab: $tabId');

          context.read<OverDueBloc>().add(
            FetchDueTasks(
              tabId: tabId,
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
    _bloc?.add(const ResetTaskState());

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
    final quickAction = widget.action;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSimpleAppBar(theme.colorScheme, "Overdue Tasks", ""
                "Your Over Due Tasks..."),
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

  Widget _buildSimpleAppBar(ColorScheme theme,
    String title,
    String subtitle,
  ) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: theme.primaryContainer,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: theme.primary,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.primary.withOpacity(0.8),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTasksSection() {
    final theme = Theme.of(context);

    return BlocBuilder<OverDueBloc, OverDueState>(
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
              print(
                'AUTO-LOADING: Initial data for first tab (${state.tabs[0].label}, id: $firstTabId)',
              );
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.05),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      size: 22,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.4),
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _loadTasksForTab(
                                state.currentTabId,
                                isRefresh: true,
                              );
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
              height:MediaQuery.of(context).size.height * 0.75,
              tabs: state.tabs
                  .map(
                    (tab) => Tab(
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
                    ),
                  )
                  .toList(),
              views: state.tabs.map((tab) =>
                  _buildTasksList(tab.id, theme.colorScheme)).toList(),
              onTabChanged: _onTabChanged,
              tabCounts: [
                widget.action.pendingAtMe,
                widget.action.pendingAtOthers,
              ],
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildTasksList(String tabId, ColorScheme scheme) {
    return BlocBuilder<OverDueBloc, OverDueState>(
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
          color: scheme.primary,
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
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: TaskCard(
                  task: taskModel,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/taskDetails',
                      arguments: taskModel,
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
                const Color(0xFF0D9667),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9667),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
              color: const Color(0xFF0D9667).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 56,
              color: const Color(0xFF0D9667).withOpacity(0.6),
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
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9667)),
        ),
      ),
    );
  }
}
