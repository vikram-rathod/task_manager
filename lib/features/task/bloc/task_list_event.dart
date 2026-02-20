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
  final int tabIndex;

  ChangeTab({
    required this.tabId,
    required this.tabIndex,
  });
}

class TransferTaskRequested extends TaskListEvent {
  final String taskId;
  final String projectId;

  TransferTaskRequested({
    required this.taskId,
    required this.projectId,
  });
}

class LoadUserRole extends TaskListEvent {}

class ClearTaskItems extends TaskListEvent {}

class ResetTaskList extends TaskListEvent {}
