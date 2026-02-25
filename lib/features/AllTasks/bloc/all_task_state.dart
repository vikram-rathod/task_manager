part of 'all_task_bloc.dart';

@immutable
class AllTaskState {
  final List<TMTasksModel> tasks;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String searchQuery;
  final String? errorMessage;
  final bool isHighAuthority;
  final int loginUserId;



  const AllTaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.searchQuery = '',
    this.errorMessage,
    this.isHighAuthority = true,
    this.loginUserId = 0,
  });

  AllTaskState copyWith({
    List<TMTasksModel>? tasks,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? searchQuery,
    String? errorMessage,
    bool? isHighAuthority,
    int? loginUserId,
  }) {
    return AllTaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      isHighAuthority: isHighAuthority ?? this.isHighAuthority,
      loginUserId: loginUserId ?? this.loginUserId,

    );
  }
}
