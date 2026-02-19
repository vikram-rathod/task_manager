import '../model/task_list_models.dart';

class TaskListState {
  final bool isLoading;
  final List<TaskItem> items;
  final String selectedTabId;
  final String? error;

  TaskListState({
    this.isLoading = false,
    this.items = const [],
    this.selectedTabId = "2",
    this.error,
  });

  TaskListState copyWith({
    bool? isLoading,
    List<TaskItem>? items,
    String? selectedTabId,
    String? error,
  }) {
    return TaskListState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      selectedTabId: selectedTabId ?? this.selectedTabId,
      error: error,
    );
  }
}
