import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:task_manager/core/models/task_model.dart';
import 'package:task_manager/core/storage/storage_keys.dart';
import 'package:task_manager/core/storage/storage_service.dart';

import '../../../core/models/project_model.dart';
import '../../auth/models/user_model.dart';
import '../../home/repository/home_repository.dart';
import '../../utils/app_exception.dart';
import '../repository/prochat_task_repository.dart';

part 'prochat_task_event.dart';
part 'prochat_task_state.dart';

class ProchatTaskBloc extends Bloc<ProchatTaskEvent, ProchatTaskState> {
  final ProchatTaskRepository _repository;
  final HomeRepository _homeRepository;
  final StorageService _storageService;

  ProchatTaskBloc(this._repository, this._homeRepository, this._storageService)
      : super(const ProchatTaskState()) {
    // Task list
    on<ProchatTaskFetched>(_onFetched);
    on<ProchatTaskRefreshed>(_onRefreshed);
    on<ResetProchatTask>(_onReset);
    // Sync
    on<ProchatTaskSyncCheck>(_onSyncCheck);
    on<ProchatSyncAndReload>(_onSyncAndReload);

    // Assign flow
    on<ProchatLoadProjectList>(_onLoadProjectList);
    on<ProchatProjectSelected>(_onProjectSelected);
    on<ProchatProjectCleared>(_onProjectCleared);
    on<ProchatCheckerSelected>(_onCheckerSelected);
    on<ProchatCheckerCleared>(_onCheckerCleared);
    on<ProchatMakerSelected>(_onMakerSelected);
    on<ProchatMakerCleared>(_onMakerCleared);
    on<ProchatPcEngineerSelected>(_onPcEngineerSelected);
    on<ProchatPcEngineerCleared>(_onPcEngineerCleared);
    on<ProchatAssignTaskSubmitted>(_onAssignTaskSubmitted);
    on<ProchatAssignReset>(_onAssignReset);
    on<ProchatAssignPreselect>(_onAssignPreselect);

  }

  Future<({String userId, String companyId, String userType})>
  _readCredentials() async {
    final userId = await _storageService.read(StorageKeys.userId) ?? '';
    final companyId = await _storageService.read(StorageKeys.companyId) ?? '';
    final userType = await _storageService.read(StorageKeys.userType) ?? '';
    return (userId: userId, companyId: companyId, userType: userType);
  }

  Future<void> _onSyncCheck(
      ProchatTaskSyncCheck event,
      Emitter<ProchatTaskState> emit,
      ) async {
    try {
      final creds = await _readCredentials();

      final response = await _repository.syncProchatTasks(
        userId: creds.userId,
        companyId: creds.companyId,
        userType: creds.userType,
      );
      debugPrint("[ProchatTaskBloc] - SyncCheck: $response");

      if (response.status == true && response.data != null) {
        emit(state.copyWith(
          hasNewTasksToSync: response.data!.isNewTasks,
        ));
      }
      // Silently ignore errors — sync check should never break the UI
    } catch (_) {}
  }

  Future<void> _onSyncAndReload(
      ProchatSyncAndReload event,
      Emitter<ProchatTaskState> emit,
      ) async {
    emit(state.copyWith(
      isSyncing: true,
      hasNewTasksToSync: false,
    ));

    try {
      final creds = await _readCredentials();

      // Perform the actual sync
      await _repository.syncProchatTasks(
        userId: creds.userId,
        companyId: creds.companyId,
        userType: creds.userType,
      );
    } catch (_) {
      // Even if sync fails, still reload the list
    } finally {
      emit(state.copyWith(isSyncing: false));
    }

    // Reload fresh list after sync
    await _fetchTasks(emit);
  }

  // ── Task list handlers ─────────────────────────────────────────────────────

  Future<void> _onFetched(
      ProchatTaskFetched event,
      Emitter<ProchatTaskState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, isError: false, errorMessage: ''));
    await _fetchTasks(emit);
  }

  Future<void> _onRefreshed(
      ProchatTaskRefreshed event,
      Emitter<ProchatTaskState> emit,
      ) async {
    emit(state.copyWith(isRefreshing: true, isError: false, errorMessage: ''));
    await _fetchTasks(emit);
  }

  Future<void> _onReset(
      ResetProchatTask event,
      Emitter<ProchatTaskState> emit,
      ) async {
    emit(const ProchatTaskState());
  }

  Future<void> _fetchTasks(Emitter<ProchatTaskState> emit) async {
    try {
      final userId = await _storageService.read(StorageKeys.userId) ?? '';
      final companyId = await _storageService.read(StorageKeys.companyId) ?? '';
      final userType = await _storageService.read(StorageKeys.userType) ?? '';

      final response = await _repository.getProchatTaskList(
        userId: userId,
        companyId: companyId,
        userType: userType,
      );

      if (response.status == true && response.data != null) {
        emit(state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isError: false,
          tasks: response.data!,
        ));
        add(const ProchatTaskSyncCheck());
      } else {
        emit(state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isError: true,
          errorMessage: response.message ?? 'Something went wrong.',
        ));
      }
    } catch (e) {
      final exception = AppExceptionMapper.from(e);

      emit(state.copyWith(
        isLoading: false,
        isRefreshing: false,
        isError: true,
        errorMessage:exception.message,
      ));
    }
  }

  // ── Assign flow handlers ───────────────────────────────────────────────────

  Future<void> _onLoadProjectList(
      ProchatLoadProjectList event,
      Emitter<ProchatTaskState> emit,
      ) async {
    emit(state.copyWith(projectListLoading: true));
    try {
      final projects = await _homeRepository.getProjectsList();
      emit(state.copyWith(projects: projects, projectListLoading: false));
      if (event.task != null) {
        add(ProchatAssignPreselect(event.task!));
      }
    } catch (e) {
      emit(state.copyWith(
        projectListLoading: false,
        assignErrorMessage: 'Failed to load projects',
      ));
    }
  }

  Future<void> _onProjectSelected(
      ProchatProjectSelected event,
      Emitter<ProchatTaskState> emit,
      ) async {
    emit(state.copyWith(
      selectedProject: event.project,
      checkerListLoading: true,
      clearSelectedChecker: true,
      clearSelectedMaker: true,
      clearSelectedPcEngineer: true,
      checkers: [],
      makers: [],
      pcEngineers: [],
    ));
    try {
      final checkers = await _homeRepository.getTaskManagerUserList(
        projectId: event.project.projectId.toString(),
      );
      emit(state.copyWith(checkers: checkers, checkerListLoading: false));
    } catch (e) {
      emit(state.copyWith(
        checkerListLoading: false,
        assignErrorMessage: 'Failed to load checkers',
      ));
    }
  }

  void _onProjectCleared(
      ProchatProjectCleared event,
      Emitter<ProchatTaskState> emit,
      ) {
    emit(state.copyWith(
      clearSelectedProject: true,
      clearSelectedChecker: true,
      clearSelectedMaker: true,
      clearSelectedPcEngineer: true,
      checkers: [],
      makers: [],
      pcEngineers: [],
    ));
  }

  Future<void> _onCheckerSelected(
      ProchatCheckerSelected event,
      Emitter<ProchatTaskState> emit,
      ) async {
    emit(state.copyWith(
      selectedChecker: event.checker,
      makerListLoading: true,
      clearSelectedMaker: true,
      clearSelectedPcEngineer: true,
      makers: [],
      pcEngineers: [],
    ));
    try {
      final makers = await _homeRepository.getTaskManagerUserList(
        projectId: state.selectedProject!.projectId.toString(),
      );
      emit(state.copyWith(makers: makers, makerListLoading: false));
    } catch (e) {
      emit(state.copyWith(
        makerListLoading: false,
        assignErrorMessage: 'Failed to load makers',
      ));
    }
  }

  void _onCheckerCleared(
      ProchatCheckerCleared event,
      Emitter<ProchatTaskState> emit,
      ) {
    emit(state.copyWith(
      clearSelectedChecker: true,
      clearSelectedMaker: true,
      clearSelectedPcEngineer: true,
      makers: [],
      pcEngineers: [],
    ));
  }

  Future<void> _onMakerSelected(
      ProchatMakerSelected event,
      Emitter<ProchatTaskState> emit,
      ) async {
    emit(state.copyWith(
      selectedMaker: event.maker,
      pcEngineerListLoading: true,
      clearSelectedPcEngineer: true,
      pcEngineers: [],
    ));
    try {
      final pcEngineers = await _homeRepository.getProjectCoordinatorUserList(
        projectId: state.selectedProject!.projectId.toString(),
      );
      emit(state.copyWith(
          pcEngineers: pcEngineers, pcEngineerListLoading: false));
    } catch (e) {
      emit(state.copyWith(
        pcEngineerListLoading: false,
        assignErrorMessage: 'Failed to load Planner/Coordinators',
      ));
    }
  }

  void _onMakerCleared(
      ProchatMakerCleared event,
      Emitter<ProchatTaskState> emit,
      ) {
    emit(state.copyWith(
      clearSelectedMaker: true,
      clearSelectedPcEngineer: true,
      pcEngineers: [],
    ));
  }

  void _onPcEngineerSelected(
      ProchatPcEngineerSelected event,
      Emitter<ProchatTaskState> emit,
      ) {
    emit(state.copyWith(selectedPcEngineer: event.engineer));
  }

  void _onPcEngineerCleared(
      ProchatPcEngineerCleared event,
      Emitter<ProchatTaskState> emit,
      ) {
    emit(state.copyWith(clearSelectedPcEngineer: true));
  }

  Future<void> _onAssignTaskSubmitted(
      ProchatAssignTaskSubmitted event,
      Emitter<ProchatTaskState> emit,
      ) async {
    if (state.selectedProject == null) return;

    final userId = await _storageService.read(StorageKeys.userId) ?? '';
    final companyId = await _storageService.read(StorageKeys.companyId) ?? '';


    emit(state.copyWith(assignStatus: ProchatAssignStatus.loading));
    try {
      await _repository.assignProchatTask(
        userId: userId,
        companyId: companyId,
        prochatTaskId: event.task.taskId.toString(),
        projectId: state.selectedProject!.projectId.toString(),
        checkerId: state.selectedChecker?.userId.toString(),
        makerId: state.selectedMaker?.userId.toString(),
        pcEngrId: state.selectedPcEngineer?.userId.toString(),
      );

      print("[AssignBloc] - UserId: $userId, CompanyId: $companyId "
          "- ProchatTaskId: ${event.task.taskId} - ProjectId: ${state.selectedProject!.projectId}"
          " - CheckerId: ${state.selectedChecker?.userId}"
          " - MakerId: ${state.selectedMaker?.userId}"
          " - PcEngrId: ${state.selectedPcEngineer?.userId}"
          " - Status: ${state.assignStatus}"
          " - Error: ${state.assignErrorMessage}"
          "");

      emit(state.copyWith(assignStatus: ProchatAssignStatus.success));
    } catch (e) {
      emit(state.copyWith(
        assignStatus: ProchatAssignStatus.error,
        assignErrorMessage: e.toString(),
      ));
    }
  }

  void _onAssignReset(
      ProchatAssignReset event,
      Emitter<ProchatTaskState> emit,
      ) {
    emit(state.copyWith(
      clearSelectedProject: true,
      clearSelectedChecker: true,
      clearSelectedMaker: true,
      clearSelectedPcEngineer: true,
      checkers: [],
      makers: [],
      pcEngineers: [],
      assignStatus: ProchatAssignStatus.idle,
      assignErrorMessage: '',
    ));
  }

  // ── Preselect cascade ──────────────────────────────────────────────────────

  Future<void> _onAssignPreselect(
      ProchatAssignPreselect event,
      Emitter<ProchatTaskState> emit,
      ) async {
    final task = event.task;

    // ── 1. Match project by ID first, fall back to name ───────────────────
    final matchedProject = state.projects.cast<ProjectModel?>().firstWhere(
          (p) =>
      (task.projectId != null &&
          p?.projectId.toString() == task.projectId.toString()) ||
          (task.projectName != null &&
              p?.projectName == task.projectName),
      orElse: () => null,
    );

    if (matchedProject == null) return;

    // Select project and load checkers
    emit(state.copyWith(
      selectedProject: matchedProject,
      checkerListLoading: true,
      clearSelectedChecker: true,
      clearSelectedMaker: true,
      clearSelectedPcEngineer: true,
      checkers: [],
      makers: [],
      pcEngineers: [],
    ));

    List<UserModel> checkers = [];
    try {
      checkers = await _homeRepository.getTaskManagerUserList(
        projectId: matchedProject.projectId.toString(),
      );
      emit(state.copyWith(checkers: checkers, checkerListLoading: false));
    } catch (_) {
      emit(state.copyWith(checkerListLoading: false));
      return;
    }

    // ── 2. Match checker ──────────────────────────────────────────────────
    final matchedChecker = checkers.cast<UserModel?>().firstWhere(
          (u) =>
      (task.checkerId != null &&
          u?.userId.toString() == task.checkerId.toString()) ||
          (task.checkerName != null && u?.userName == task.checkerName),
      orElse: () => null,
    );

    if (matchedChecker == null) return;

    // Select checker and load makers
    emit(state.copyWith(
      selectedChecker: matchedChecker,
      makerListLoading: true,
      clearSelectedMaker: true,
      clearSelectedPcEngineer: true,
      makers: [],
      pcEngineers: [],
    ));

    List<UserModel> makers = [];
    try {
      makers = await _homeRepository.getTaskManagerUserList(
        projectId: matchedProject.projectId.toString(),
      );
      emit(state.copyWith(makers: makers, makerListLoading: false));
    } catch (_) {
      emit(state.copyWith(makerListLoading: false));
      return;
    }

    // ── 3. Match maker ────────────────────────────────────────────────────
    final matchedMaker = makers.cast<UserModel?>().firstWhere(
          (u) =>
      (task.makerId != null &&
          u?.userId.toString() == task.makerId.toString()) ||
          (task.makerName != null && u?.userName == task.makerName),
      orElse: () => null,
    );

    if (matchedMaker == null) return;

    // Select maker and load Planner/Coordinators
    emit(state.copyWith(
      selectedMaker: matchedMaker,
      pcEngineerListLoading: true,
      clearSelectedPcEngineer: true,
      pcEngineers: [],
    ));

    List<UserModel> pcEngineers = [];
    try {
      pcEngineers = await _homeRepository.getProjectCoordinatorUserList(
        projectId: matchedProject.projectId.toString(),
      );
      emit(state.copyWith(
          pcEngineers: pcEngineers, pcEngineerListLoading: false));
    } catch (_) {
      emit(state.copyWith(pcEngineerListLoading: false));
      return;
    }

    // ── 4. Match Planner/Coordinator ──────────────────────────────────────────────
    final matchedPcEngineer = pcEngineers.cast<UserModel?>().firstWhere(
          (u) =>
      (task.pcEngrId != null &&
          u?.userId.toString() == task.pcEngrId.toString()) ||
          (task.pcEngrName != null && u?.userName == task.pcEngrName),
      orElse: () => null,
    );

    if (matchedPcEngineer != null) {
      emit(state.copyWith(selectedPcEngineer: matchedPcEngineer));
    }
  }

}