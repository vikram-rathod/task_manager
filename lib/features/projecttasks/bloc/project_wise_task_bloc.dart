import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/models/task_model.dart';
import 'package:task_manager/core/storage/storage_keys.dart';
import 'package:task_manager/core/storage/storage_service.dart';
import 'package:task_manager/features/projecttasks/bloc/project_wise_task_event.dart';
import 'package:task_manager/features/projecttasks/bloc/project_wise_task_state.dart';

import '../../auth/models/user_model.dart';
import '../../home/repository/home_repository.dart';
import '../../home/repository/task_repository.dart';


class ProjectWiseTaskBloc
    extends Bloc<ProjectWiseTaskEvent, ProjectWiseTaskState> {
  final TaskRepository tasksRepository;
  final HomeRepository homeRepository;
  final StorageService storageService;


  static const int _pageSize = 10;
  static const int _initialPage = 1;
  static const Duration _searchDebounce = Duration(milliseconds: 500);

  Timer? _searchDebounceTimer;

  ProjectWiseTaskBloc({
    required this.tasksRepository,
    required this.homeRepository,
    required this.storageService,
  }) : super(const ProjectWiseTaskState()) {
    on<InitializeProjectWiseTask>(_onInitialize);
    on<UserRoleSelected>(_onUserRoleSelected);
    on<MakerUserSelected>(_onMakerUserSelected);
    on<CheckerUserSelected>(_onCheckerUserSelected);
    on<PcEngineerSelected>(_onPcEngineerSelected);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<LoadNextPage>(_onLoadNextPage);
    on<RefreshTasks>(_onRefreshTasks);
    on<ResetProjectWiseTaskState>(_onReset);
  }

  // ── Initialize ─────────────────────────────────────────────────────────────

  Future<void> _onInitialize(
      InitializeProjectWiseTask event,
      Emitter<ProjectWiseTaskState> emit,
      ) async {
    emit(state.copyWith(project: event.project));
    // If role is ALL, fetch tasks immediately
    if (state.selectedRole == UserRoleType.all) {
      await _fetchTasks(emit, isLoadMore: false);
    }
  }

  // ── Role filter ────────────────────────────────────────────────────────────

  Future<void> _onUserRoleSelected(
      UserRoleSelected event,
      Emitter<ProjectWiseTaskState> emit,
      ) async {
    if (state.selectedRole == event.role) return;

    // Clear selection for the newly selected role
    Map<String, UserModel> newMakerMap = state.selectedMakerMap;
    Map<String, UserModel> newCheckerMap = state.selectedCheckerMap;
    Map<String, UserModel> newPcMap = state.selectedPcEngineerMap;

    switch (event.role) {
      case UserRoleType.maker:
        newMakerMap = {};
        break;
      case UserRoleType.checker:
        newCheckerMap = {};
        break;
      case UserRoleType.pcEngineer:
        newPcMap = {};
        break;
      case UserRoleType.all:
        break;
    }

    emit(state.copyWith(
      selectedRole: event.role,
      selectedMakerMap: newMakerMap,
      selectedCheckerMap: newCheckerMap,
      selectedPcEngineerMap: newPcMap,
      taskStatus: const TaskListIdle(),
      currentPage: _initialPage,
      hasMorePages: true,
    ));

    // Load user lists if not already loaded
    if (event.role == UserRoleType.maker || event.role == UserRoleType.checker) {
      if (state.checkerMakerUserStatus is! UserListSuccess) {
        await _fetchCheckerMakerList(emit);
      }
    } else if (event.role == UserRoleType.pcEngineer) {
      if (state.pcEngineerUserStatus is! UserListSuccess) {
        await _fetchPcEngineerList(emit);
      }
    } else if (event.role == UserRoleType.all) {
      await _resetAndFetch(emit);
    }
  }

  // ── User selections ────────────────────────────────────────────────────────

  Future<void> _onMakerUserSelected(
      MakerUserSelected event,
      Emitter<ProjectWiseTaskState> emit,
      ) async {
    emit(state.copyWith(
      selectedMakerMap: {
        ...state.selectedMakerMap,
        UserRoleType.maker.displayName: event.user,
      },
      currentPage: _initialPage,
      hasMorePages: true,
    ));
    await _fetchTasks(emit, isLoadMore: false);
  }

  Future<void> _onCheckerUserSelected(
      CheckerUserSelected event,
      Emitter<ProjectWiseTaskState> emit,
      ) async {
    emit(state.copyWith(
      selectedCheckerMap: {
        ...state.selectedCheckerMap,
        UserRoleType.checker.displayName: event.user,
      },
      currentPage: _initialPage,
      hasMorePages: true,
    ));
    await _fetchTasks(emit, isLoadMore: false);
  }

  Future<void> _onPcEngineerSelected(
      PcEngineerSelected event,
      Emitter<ProjectWiseTaskState> emit,
      ) async {
    emit(state.copyWith(
      selectedPcEngineerMap: {
        ...state.selectedPcEngineerMap,
        UserRoleType.pcEngineer.displayName: event.user,
      },
      currentPage: _initialPage,
      hasMorePages: true,
    ));
    await _fetchTasks(emit, isLoadMore: false);
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  void _onSearchQueryChanged(
      SearchQueryChanged event,
      Emitter<ProjectWiseTaskState> emit,
      ) {
    emit(state.copyWith(searchQuery: event.query));
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounce, () {
      add(const RefreshTasks());
    });
  }

  // ── Pagination ─────────────────────────────────────────────────────────────

  Future<void> _onLoadNextPage(
      LoadNextPage event,
      Emitter<ProjectWiseTaskState> emit,
      ) async {
    if (!state.hasMorePages || state.isLoadingMore) return;
    emit(state.copyWith(
      currentPage: state.currentPage + 1,
      isLoadingMore: true,
    ));
    await _fetchTasks(emit, isLoadMore: true);
  }

  Future<void> _onRefreshTasks(
      RefreshTasks event,
      Emitter<ProjectWiseTaskState> emit,
      ) async {
    emit(state.copyWith(isRefreshing: true));
    await _resetAndFetch(emit);
  }

  // ── Reset ──────────────────────────────────────────────────────────────────

  void _onReset(
      ResetProjectWiseTaskState event,
      Emitter<ProjectWiseTaskState> emit,
      ) {
    _searchDebounceTimer?.cancel();
    emit(const ProjectWiseTaskState());
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _resetAndFetch(Emitter<ProjectWiseTaskState> emit) async {
    emit(state.copyWith(
      currentPage: _initialPage,
      hasMorePages: true,
    ));
    await _fetchTasks(emit, isLoadMore: false);
  }

  bool _canFetchTasks() {
    switch (state.selectedRole) {
      case UserRoleType.maker:
        return state.selectedMaker != null;
      case UserRoleType.checker:
        return state.selectedChecker != null;
      case UserRoleType.pcEngineer:
        return state.selectedPcEngineer != null;
      case UserRoleType.all:
        return true;
    }
  }

  Future<void> _fetchTasks(
      Emitter<ProjectWiseTaskState> emit, {
        required bool isLoadMore,
      }) async {
    if (!_canFetchTasks()) {
      emit(state.copyWith(taskStatus: const TaskListIdle()));
      return;
    }

    if (!isLoadMore) {
      if (!state.isRefreshing) {
        emit(state.copyWith(taskStatus: const TaskListLoading()));
      }
    }

    try {
      final String? makerId = state.selectedRole == UserRoleType.maker
          ? state.selectedMaker?.userId?.toString()
          : null;
      final String? checkerId = state.selectedRole == UserRoleType.checker
          ? state.selectedChecker?.userId?.toString()
          : null;
      final String? pcEngrId = state.selectedRole == UserRoleType.pcEngineer
          ? state.selectedPcEngineer?.userId?.toString()
          : null;

      final userId = await storageService.read(StorageKeys.userId);
      final userType = await storageService.read(StorageKeys.userType);
      final compId = await storageService.read(StorageKeys.companyId);


      final response = await tasksRepository.getAllTaskByProjectId(
        userId: userId,
        userType: userType,
        compId: compId,
        page: state.currentPage,
        size: _pageSize,
        makerId: makerId,
        checkerId: checkerId,
        pcEngrId: pcEngrId,
        searchQuery:
        state.searchQuery.isNotEmpty ? state.searchQuery : null,
        projectId: state.project?.projectId?.toString() ?? '',
      );

      final newTasks = response.data ?? [];
      final currentTasks =
      state.taskStatus is TaskListSuccess && isLoadMore
          ? (state.taskStatus as TaskListSuccess).tasks
          : <TMTasksModel>[];

      final updatedTasks = [...currentTasks, ...newTasks];

      emit(state.copyWith(
        taskStatus: TaskListSuccess(updatedTasks),
        hasMorePages: newTasks.length >= _pageSize,
        isLoadingMore: false,
        isRefreshing: false,
      ));
    } catch (e) {
      if (!isLoadMore) {
        emit(state.copyWith(
          taskStatus: TaskListError(e.toString()),
          isLoadingMore: false,
          isRefreshing: false,
        ));
      } else {
        // On load-more error, just stop loading without replacing list
        emit(state.copyWith(
          isLoadingMore: false,
          currentPage: state.currentPage - 1, // rollback page
        ));
      }
    }
  }

  Future<void> _fetchCheckerMakerList(
      Emitter<ProjectWiseTaskState> emit,
      ) async {
    emit(state.copyWith(
        checkerMakerUserStatus: const UserListLoading()));
    try {
      final users = await homeRepository.getTaskManagerUserList(
        projectId: state.project?.projectId?.toString() ?? '',
      );
      emit(state.copyWith(
          checkerMakerUserStatus: UserListSuccess(users)));
    } catch (e) {
      emit(state.copyWith(
          checkerMakerUserStatus: UserListError(e.toString())));
    }
  }

  Future<void> _fetchPcEngineerList(
      Emitter<ProjectWiseTaskState> emit,
      ) async {
    emit(state.copyWith(
        pcEngineerUserStatus: const UserListLoading()));
    try {
      final users = await homeRepository.getProjectCoordinatorUserList(
        projectId: state.project?.projectId?.toString() ?? '',
      );
      emit(state.copyWith(
          pcEngineerUserStatus: UserListSuccess(users)));
    } catch (e) {
      emit(state.copyWith(
          pcEngineerUserStatus: UserListError(e.toString())));
    }
  }

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    return super.close();
  }
}