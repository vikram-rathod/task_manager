abstract class TaskListEvent {}

class LoadTaskHierarchy extends TaskListEvent {
  final String projectId;
  final String tabId;

  LoadTaskHierarchy({
    required this.projectId,
    required this.tabId,
  });
}

class ChangeTab extends TaskListEvent {
  final String tabId;

  ChangeTab(this.tabId);
}

class TransferTaskRequested extends TaskListEvent {
  final String taskId;
  final String projectId;

  TransferTaskRequested({
    required this.taskId,
    required this.projectId,
  });
}
