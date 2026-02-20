import '../model/task_list_models.dart';

class TaskListState {
  final bool isLoading;
  final List<TaskItem> items;
  final String selectedTabId;
  final int selectedTabIndex;
  final String? error;
  final bool isFounderOrPartner;

  TaskListState({
    this.isLoading = false,
    this.items = const [],
    this.selectedTabId = "1",
    this.selectedTabIndex = 0,
    this.error,
    this.isFounderOrPartner = false,
  });

  TaskListState copyWith({
    bool? isLoading,
    List<TaskItem>? items,
    String? selectedTabId,
    int? selectedTabIndex,
    String? error,
    bool? isFounderOrPartner,
  }) {
    return TaskListState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      selectedTabId: selectedTabId ?? this.selectedTabId,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      error: error,
      isFounderOrPartner: isFounderOrPartner ?? this.isFounderOrPartner,
    );
  }
}
