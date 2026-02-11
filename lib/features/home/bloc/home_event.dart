part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class FetchQuickActions extends HomeEvent {}

class ClearQuickActionsError extends HomeEvent {}

class FetchTaskHistory extends HomeEvent {}

class LoadProjectList extends HomeEvent {}

class ClearProjectList extends HomeEvent {}

class ClearTaskHistoryError extends HomeEvent {}

class LoadEmployeeWiseTaskList extends HomeEvent {}

class ClearEmployeeWiseTaskListError extends HomeEvent {}


