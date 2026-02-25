part of 'over_due_bloc.dart';

@immutable
sealed class OverDueEvent {
  const OverDueEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserRole extends OverDueEvent {
  const LoadUserRole();

  @override
  List<Object?> get props => [];
}

class InitializeTabs extends OverDueEvent {

  const InitializeTabs();
}


class FetchDueTasks extends OverDueEvent {
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

class ChangeTaskTab extends OverDueEvent {
  final int tabIndex;

  const ChangeTaskTab(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class ResetTaskState extends OverDueEvent {
  const ResetTaskState();

  @override
  List<Object?> get props => [];
}