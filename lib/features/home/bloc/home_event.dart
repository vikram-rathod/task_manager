part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class FetchQuickActions extends HomeEvent {}

class ClearQuickActionsError extends HomeEvent {}

class FetchTaskHistory extends HomeEvent {}

class LoadProjectList extends HomeEvent {

  final String page;
  final String size;

  const LoadProjectList({required this.page,
    required this.size,
  });

  @override
  List<Object?> get props =>
      [
        page,
        size,
      ];
}

class ClearProjectList extends HomeEvent {}

class ClearTaskHistoryError extends HomeEvent {}

class LoadEmployeeWiseTaskList extends HomeEvent {
  final int page;
  final int size;

  const LoadEmployeeWiseTaskList({required this.page,
    required this.size,
  });

  @override
  List<Object?> get props =>
      [
        page,
        size,
      ];

}

class ClearEmployeeWiseTaskListError extends HomeEvent {}

class FetchTodaysTasks extends HomeEvent {
  final int page;
  final bool isMyTasks;

  const FetchTodaysTasks({
    required this.page,
    required this.isMyTasks,
  });

  @override
  List<Object?> get props => [page,isMyTasks];
}

class ClearTodaysTasksError extends HomeEvent {}

class RefreshHomeData extends HomeEvent {}
