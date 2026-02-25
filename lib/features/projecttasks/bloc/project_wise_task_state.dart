import 'package:equatable/equatable.dart';
import 'package:task_manager/core/models/task_model.dart';

import '../../auth/models/user_model.dart';
import '../../home/model/project_count_model.dart';

enum UserRoleType { all, maker, checker, pcEngineer }

extension UserRoleTypeX on UserRoleType {
  String get displayName {
    switch (this) {
      case UserRoleType.all:
        return 'All';
      case UserRoleType.maker:
        return 'Maker';
      case UserRoleType.checker:
        return 'Checker';
      case UserRoleType.pcEngineer:
        return 'Planner/Coordinator';
    }
  }
}

// ── User list sub-state ──────────────────────────────────────────────────────
abstract class UserListStatus extends Equatable {
  const UserListStatus();
  @override
  List<Object?> get props => [];
}

class UserListIdle extends UserListStatus {
  const UserListIdle();
}

class UserListLoading extends UserListStatus {
  const UserListLoading();
}

class UserListSuccess extends UserListStatus {
  final List<UserModel> users;
  const UserListSuccess(this.users);
  @override
  List<Object?> get props => [users];
}

class UserListError extends UserListStatus {
  final String message;
  const UserListError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Task list sub-state ──────────────────────────────────────────────────────
abstract class TaskListStatus extends Equatable {
  const TaskListStatus();
  @override
  List<Object?> get props => [];
}

class TaskListIdle extends TaskListStatus {
  const TaskListIdle();
}

class TaskListLoading extends TaskListStatus {
  const TaskListLoading();
}

class TaskListSuccess extends TaskListStatus {
  final List<TMTasksModel> tasks;
  const TaskListSuccess(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

class TaskListError extends TaskListStatus {
  final String message;
  const TaskListError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Main state ───────────────────────────────────────────────────────────────
class ProjectWiseTaskState extends Equatable {
  final ProjectCountModel? project;

  // Role filter
  final UserRoleType selectedRole;

  // User dropdown data
  final UserListStatus checkerMakerUserStatus;
  final UserListStatus pcEngineerUserStatus;

  // Selected users per role (keyed by role displayName)
  final Map<String, UserModel> selectedMakerMap;
  final Map<String, UserModel> selectedCheckerMap;
  final Map<String, UserModel> selectedPcEngineerMap;

  // Task list
  final TaskListStatus taskStatus;
  final bool isLoadingMore;
  final bool hasMorePages;
  final bool isRefreshing;

  // Pagination
  final int currentPage;

  // Search
  final String searchQuery;

  final bool isHighAuthority;
  final int loginUserId;


  const ProjectWiseTaskState({
    this.project,
    this.selectedRole = UserRoleType.all,
    this.checkerMakerUserStatus = const UserListIdle(),
    this.pcEngineerUserStatus = const UserListIdle(),
    this.selectedMakerMap = const {},
    this.selectedCheckerMap = const {},
    this.selectedPcEngineerMap = const {},
    this.taskStatus = const TaskListIdle(),
    this.isLoadingMore = false,
    this.hasMorePages = true,
    this.isRefreshing = false,
    this.currentPage = 1,
    this.searchQuery = '',
    this.isHighAuthority = false,
    this.loginUserId = 0,
  });

  UserModel? get selectedMaker =>
      selectedMakerMap[UserRoleType.maker.displayName];

  UserModel? get selectedChecker =>
      selectedCheckerMap[UserRoleType.checker.displayName];

  UserModel? get selectedPcEngineer =>
      selectedPcEngineerMap[UserRoleType.pcEngineer.displayName];

  ProjectWiseTaskState copyWith({
    ProjectCountModel? project,
    UserRoleType? selectedRole,
    UserListStatus? checkerMakerUserStatus,
    UserListStatus? pcEngineerUserStatus,
    Map<String, UserModel>? selectedMakerMap,
    Map<String, UserModel>? selectedCheckerMap,
    Map<String, UserModel>? selectedPcEngineerMap,
    TaskListStatus? taskStatus,
    bool? isLoadingMore,
    bool? hasMorePages,
    bool? isRefreshing,
    int? currentPage,
    String? searchQuery,
    bool? isHighAuthority,
    int? loginUserId,
  }) {
    return ProjectWiseTaskState(
      project: project ?? this.project,
      selectedRole: selectedRole ?? this.selectedRole,
      checkerMakerUserStatus:
      checkerMakerUserStatus ?? this.checkerMakerUserStatus,
      pcEngineerUserStatus: pcEngineerUserStatus ?? this.pcEngineerUserStatus,
      selectedMakerMap: selectedMakerMap ?? this.selectedMakerMap,
      selectedCheckerMap: selectedCheckerMap ?? this.selectedCheckerMap,
      selectedPcEngineerMap:
      selectedPcEngineerMap ?? this.selectedPcEngineerMap,
      taskStatus: taskStatus ?? this.taskStatus,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      isHighAuthority: isHighAuthority ?? this.isHighAuthority,
      loginUserId: loginUserId ?? this.loginUserId,
    );
  }

  @override
  List<Object?> get props => [
    project,
    selectedRole,
    checkerMakerUserStatus,
    pcEngineerUserStatus,
    selectedMakerMap,
    selectedCheckerMap,
    selectedPcEngineerMap,
    taskStatus,
    isLoadingMore,
    hasMorePages,
    isRefreshing,
    currentPage,
    searchQuery,
    isHighAuthority,
    loginUserId,
  ];
}