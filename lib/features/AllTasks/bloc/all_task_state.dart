part of 'all_task_bloc.dart';

@immutable
class AllTaskState {
  final List<TMTasksModel> tasks;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String searchQuery;
  final String? errorMessage;

  const AllTaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.searchQuery = '',
    this.errorMessage,
  });

  AllTaskState copyWith({
    List<TMTasksModel>? tasks,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? searchQuery,
    String? errorMessage,
  }) {
    return AllTaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}
