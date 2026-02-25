part of 'over_due_bloc.dart';

@immutable
class OverDueState extends Equatable {
  // Current active tab index
  final int currentTabIndex;

  // Search query
  final String? searchQuery;

  // Tab configurations
  final List<TaskTab> tabs;

  // Task data by tab ID
  final Map<String, List<dynamic>> tasksByTab;

  // Loading state by tab ID (for initial load)
  final Map<String, bool> loadingByTab;

  // Pagination loading state by tab ID (for load more)
  final Map<String, bool> paginationLoadingByTab;

  // Error messages by tab ID
  final Map<String, String?> errorsByTab;

  // Current page number by tab ID
  final Map<String, int> pagesByTab;

  // Has more data flag by tab ID
  final Map<String, bool> hasMoreByTab;

  final isHighAuthority;

  final int loginUserId;



  const OverDueState({
    this.currentTabIndex = 0,
    this.searchQuery,
    this.tabs = const [],
    this.tasksByTab = const {},
    this.loadingByTab = const {},
    this.paginationLoadingByTab = const {},
    this.errorsByTab = const {},
    this.pagesByTab = const {},
    this.hasMoreByTab = const {},
    this.isHighAuthority = false,
    this.loginUserId = 0,
  });

  // Convenience getters for current tab
  String get currentTabId => tabs.isNotEmpty ? tabs[currentTabIndex].id : '';

  List<dynamic> get currentTasks => tasksByTab[currentTabId] ?? [];

  bool get isLoading => loadingByTab[currentTabId] ?? false;

  bool get isPaginationLoading => paginationLoadingByTab[currentTabId] ?? false;

  String? get currentError => errorsByTab[currentTabId];

  int get currentPage => pagesByTab[currentTabId] ?? 1;

  bool get hasMore => hasMoreByTab[currentTabId] ?? true;

  OverDueState copyWith({
    int? currentTabIndex,
    Map<String, List<dynamic>>? tasksByTab,
    Map<String, bool>? loadingByTab,
    Map<String, bool>? paginationLoadingByTab,
    Map<String, String?>? errorsByTab,
    Map<String, int>? pagesByTab,
    Map<String, bool>? hasMoreByTab,
    String? searchQuery,
    bool clearSearch = false,
    List<TaskTab>? tabs,
    bool? isHighAuthority,
    int? loginUserId,
  }) {
    return OverDueState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      tabs: tabs ?? this.tabs,
      tasksByTab: tasksByTab ?? this.tasksByTab,
      loadingByTab: loadingByTab ?? this.loadingByTab,
      paginationLoadingByTab: paginationLoadingByTab ??
          this.paginationLoadingByTab,
      errorsByTab: errorsByTab ?? this.errorsByTab,
      pagesByTab: pagesByTab ?? this.pagesByTab,
      hasMoreByTab: hasMoreByTab ?? this.hasMoreByTab,
      isHighAuthority: isHighAuthority ?? this.isHighAuthority,
      loginUserId: loginUserId ?? this.loginUserId,
    );
  }

  @override
  List<Object?> get props =>
      [
        currentTabIndex,
        searchQuery,
        tabs,
        tasksByTab,
        loadingByTab,
        paginationLoadingByTab,
        errorsByTab,
        pagesByTab,
        hasMoreByTab,
        isHighAuthority,
        loginUserId,
      ];
}