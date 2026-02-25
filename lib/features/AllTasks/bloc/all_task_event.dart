part of 'all_task_bloc.dart';

@immutable
sealed class AllTaskEvent {}

class LoadUserRole extends AllTaskEvent {}

class LoadAllTasks extends AllTaskEvent {
  final bool reset;
  LoadAllTasks({this.reset = false});
}

class LoadNextPage extends AllTaskEvent {}

class SearchQueryChanged extends AllTaskEvent {
  final String query;
  SearchQueryChanged(this.query);
}

class RefreshTasks extends AllTaskEvent {}

class ResetTasksState extends AllTaskEvent {}

