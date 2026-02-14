part of 'employee_task_bloc.dart';

sealed class EmployeeTaskEvent extends Equatable {
  const EmployeeTaskEvent();

  @override
  List<Object?> get props => [];
}

class InitializeEmployeeTabs extends EmployeeTaskEvent {
  final String employeeUserId;

  const InitializeEmployeeTabs({
    required this.employeeUserId,
  });

  @override
  List<Object?> get props => [employeeUserId];
}

/// Event to fetch tasks for a specific tab
class FetchEmployeeTasks extends EmployeeTaskEvent {
  final String tabId;
  final String employeeId;
  final int page;
  final int size;
  final String? search;
  final bool isRefresh; // Flag to indicate if this is a refresh (clears existing data)

  const FetchEmployeeTasks({
    required this.tabId,
    required this.employeeId,
    this.page = 1,
    this.size = 10,
    this.search,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [tabId, employeeId, page, size, search, isRefresh];
}

/// Event to change active tab
class ChangeEmployeeTaskTab extends EmployeeTaskEvent {
  final int tabIndex;

  const ChangeEmployeeTaskTab(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

/// Event to reset the entire state when leaving the screen
class ResetEmployeeTaskState extends EmployeeTaskEvent {
  const ResetEmployeeTaskState();

  @override
  List<Object?> get props => [];
}