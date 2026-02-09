part of 'all_task_bloc.dart';

enum AllTaskStatus { idle, loading, success, error, loadingMore }

@immutable
class AllTaskState {
  final AllTaskStatus status;
  final List<TMTasksModel> tasks;
  final String? errorMessage;
  final bool hasReachedMax;
  final String searchQuery;

  const AllTaskState({
    this.status = AllTaskStatus.idle,
    this.tasks = const [],
    this.errorMessage,
    this.hasReachedMax = false,
    this.searchQuery = '',
  });

  AllTaskState copyWith({
    AllTaskStatus? status,
    List<TMTasksModel>? tasks,
    String? errorMessage,
    bool? hasReachedMax,
    String? searchQuery,
  }) {
    return AllTaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}