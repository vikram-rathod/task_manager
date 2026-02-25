import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../../../core/constants/app_constant.dart';
import '../../../core/models/task_model.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/storage/storage_service.dart';
import '../../createtask/models/task_request.dart';
import '../../home/repository/task_repository.dart';
import '../../utils/app_exception.dart';

part 'all_task_event.dart';
part 'all_task_state.dart';

class AllTaskBloc extends Bloc<AllTaskEvent, AllTaskState> {
  final TaskRepository taskRepository;
  final StorageService storageService;

  int _page = 1;
  final int _pageSize = 20;

  AllTaskBloc(
      this.taskRepository,
      this.storageService,
      ) : super(const AllTaskState()) {
    on<LoadUserRole>(_onLoadUserRole);
    on<LoadAllTasks>(_loadTasks);
    on<LoadNextPage>(_loadNextPage);
    on<SearchQueryChanged>(_onSearch);
    on<RefreshTasks>(_onRefresh);
    on<ResetTasksState>(_onReset);

    add(LoadAllTasks(reset: true));
  }

  Future<void> _onLoadUserRole(LoadUserRole event,
      Emitter<AllTaskState> emit,) async {
    final userType = await storageService.read(StorageKeys.userType) ?? "";
    final loginUserId = await storageService.read(StorageKeys.userId) ?? "0";


    final isHighAuthority =
        AppConstant.owners.contains(userType) ||
            AppConstant.partners.contains(userType);

    emit(state.copyWith(isHighAuthority: isHighAuthority,
        loginUserId: int.parse(loginUserId)));
  }


  Future<void> _loadTasks(
      LoadAllTasks event,
      Emitter<AllTaskState> emit,
      ) async {
    if (state.isLoading) return;

    if (event.reset) {
      _page = 1;
      emit(state.copyWith(
        isLoading: true,
        tasks: [],
        hasReachedMax: false,
        errorMessage: null,
      ));
    } else {
      emit(state.copyWith(isLoading: true));
    }

    try {
      final request = TaskRequestBody(
        userId: int.parse(await storageService.read(StorageKeys.userId) ?? '0'),
        compId: int.parse(await storageService.read(StorageKeys.companyId) ?? '0'),
        userType:
        int.parse(await storageService.read(StorageKeys.userType) ?? '0'),
        page: _page,
        size: _pageSize,
        searchDescription: state.searchQuery,
      );

      final response = await taskRepository.fetchTasks(request);
      final newTasks = response.data ?? [];

      emit(state.copyWith(
        isLoading: false,
        tasks: newTasks,
        hasReachedMax: newTasks.length < _pageSize,
      ));
    } catch (e) {
      final exception = AppExceptionMapper.from(e);

      // Handle specific exception types if needed
      if (exception is UnauthorisedException) {
        // e.g. trigger logout or navigate to login
        // add(LogoutEvent());
      }

      emit(state.copyWith(
        isLoading: false,
        errorMessage: exception.message,
      ));
    }
  }

  Future<void> _loadNextPage(
      LoadNextPage event,
      Emitter<AllTaskState> emit,
      ) async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      _page++;

      final request = TaskRequestBody(
        userId: int.parse(await storageService.read(StorageKeys.userId) ?? '0'),
        compId: int.parse(await storageService.read(StorageKeys.companyId) ?? '0'),
        userType:
        int.parse(await storageService.read(StorageKeys.userType) ?? '0'),
        page: _page,
        size: _pageSize,
        searchDescription: state.searchQuery,
      );

      final response = await taskRepository.fetchTasks(request);
      final newTasks = response.data ?? [];

      emit(state.copyWith(
        isLoadingMore: false,
        tasks: [...state.tasks, ...newTasks],
        hasReachedMax: newTasks.length < _pageSize,
      ));
    } catch (e) {
      _page--; // Roll back the page increment on failure

      final exception = AppExceptionMapper.from(e);

      emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: exception.message,
      ));
    }
  }

  void _onSearch(
      SearchQueryChanged event,
      Emitter<AllTaskState> emit,
      ) {
    emit(state.copyWith(searchQuery: event.query));
    add(LoadAllTasks(reset: true));
  }

  void _onRefresh(
      RefreshTasks event,
      Emitter<AllTaskState> emit,
      ) {
    add(LoadAllTasks(reset: true));
  }

  void _onReset(
      ResetTasksState event,
      Emitter<AllTaskState> emit,
      ) {
    _page = 1;
    emit(const AllTaskState());
  }
}