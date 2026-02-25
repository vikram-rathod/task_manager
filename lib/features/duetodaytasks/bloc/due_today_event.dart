part of 'due_today_bloc.dart';

class DueTodayEvent extends Equatable {
  const DueTodayEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserRole extends DueTodayEvent {
  const LoadUserRole();

  @override
  List<Object?> get props => [];
}


class InitializeTabs extends DueTodayEvent {
  const InitializeTabs();
}

class FetchDueTasks extends DueTodayEvent {
  final String tabId;
  final int page;
  final int size;
  final String? search;
  final bool isRefresh;

  const FetchDueTasks({
    required this.tabId,
    this.page = 1,
    this.size = 10,
    this.search,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [tabId, page, size, search, isRefresh];
}

class ChangeTaskTab extends DueTodayEvent {
  final int tabIndex;

  const ChangeTaskTab(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class ResetTaskState extends DueTodayEvent {
  const ResetTaskState();

  @override
  List<Object?> get props => [];
}
