import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../../../core/storage/storage_keys.dart';
import '../../../core/storage/storage_service.dart';
import '../../createtask/models/task_model.dart';
import '../../createtask/models/task_request.dart';
import '../../home/repository/task_repository.dart';

part 'all_task_event.dart';
part 'all_task_state.dart';

class AllTaskBloc extends Bloc<AllTaskEvent, AllTaskState> {
  final TaskRepository taskRepository;
  final StorageService storageService;

  int _currentPage = 1;
  final int _pageSize = 20;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final List<TMTasksModel> _allTasks = [];

  AllTaskBloc(
      this.taskRepository,
      this.storageService,
      ) : super(const AllTaskState()) {
    on<LoadAllTasks>(_onLoadAllTasks);
    on<LoadNextPage>(_onLoadNextPage);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<RefreshTasks>(_onRefreshTasks);
    on<ResetTasksState>(_onResetTasksState);

    // Auto-load on initialization
    add(LoadAllTasks(reset: true));
  }

  Future<void> _onLoadAllTasks(
      LoadAllTasks event,
      Emitter<AllTaskState> emit,
      ) async {
    if (_isLoadingMore) {
      debugPrint('[AllTaskBloc] Skipping fetch — already loading page $_currentPage');
      return;
    }

    _isLoadingMore = true;

    if (event.reset) {
      debugPrint('[AllTaskBloc] Resetting pagination: starting from page 1');
      emit(state.copyWith(status: AllTaskStatus.loading));
      _currentPage = 1;
      _allTasks.clear();
      _hasMore = true;
    }

    try {
      final requestBody = TaskRequestBody(
        userId: int.parse(await storageService.read(StorageKeys.userId) ?? '0'),
        compId: int.parse(await  storageService.read(StorageKeys.companyId) ?? '0'),
        userType: int.parse(await storageService.read(StorageKeys.userType) ?? '0'),
        page: _currentPage,
        size: _pageSize,
        searchDescription: state.searchQuery.isEmpty ? null : state.searchQuery,
      );

      debugPrint('[AllTaskBloc] ➡ Fetching tasks: page=$_currentPage, size=$_pageSize');
      final response = await taskRepository.fetchTasks(requestBody);

      if (response.status) {
        final newTasks = response.data ?? [];
        debugPrint('[AllTaskBloc]  Page $_currentPage fetched successfully, received ${newTasks.length} records');

        if (newTasks.isEmpty) {
          _hasMore = false;
          debugPrint('[AllTaskBloc]  No more data available — stopping pagination');
        } else {
          _allTasks.addAll(newTasks);
          debugPrint('[AllTaskBloc]  Total loaded so far: ${_allTasks.length} (after adding ${newTasks.length})');
          _currentPage++;
        }

        emit(state.copyWith(
          status: AllTaskStatus.success,
          tasks: List.from(_allTasks),
          hasReachedMax: !_hasMore,
        ));
      } else {
        if (response.message.toLowerCase().contains('no tasks found')) {
          if (_currentPage == 1) {
            // No tasks at all — first page empty
            _hasMore = false;
            debugPrint('[AllTaskBloc]  Page 1 returned "No tasks found" — no data for this user/company');
            emit(state.copyWith(
              status: AllTaskStatus.error,
              errorMessage: 'No tasks available.',
            ));
          } else {
            // We've already loaded some pages, this means end of pagination
            _hasMore = false;
            debugPrint('[AllTaskBloc]  All tasks loaded — page $_currentPage returned "No tasks found"');
            emit(state.copyWith(
              status: AllTaskStatus.success,
              tasks: List.from(_allTasks),
              hasReachedMax: true,
            ));
          }
        } else {
          emit(state.copyWith(
            status: AllTaskStatus.error,
            errorMessage: response.message,
          ));
        }
      }
    } catch (e) {
      debugPrint('[AllTaskBloc]  Exception while fetching page $_currentPage: ${e.toString()}');
      emit(state.copyWith(
        status: AllTaskStatus.error,
        errorMessage: e.toString(),
      ));
    } finally {
      debugPrint('[AllTaskBloc]  Finished loading page ${_currentPage - 1}');
      _isLoadingMore = false;
    }
  }

  Future<void> _onLoadNextPage(
      LoadNextPage event,
      Emitter<AllTaskState> emit,
      ) async {
    if (!_isLoadingMore && _hasMore) {
      debugPrint('[AllTaskBloc]  Loading next page: $_currentPage');
      emit(state.copyWith(status: AllTaskStatus.loadingMore));
      add(LoadAllTasks(reset: false));
    } else {
      if (_isLoadingMore) debugPrint('[AllTaskBloc] ⏳ Skipping next load — still loading current page');
      if (!_hasMore) debugPrint('[AllTaskBloc]  No more pages to load');
    }
  }

  void _onSearchQueryChanged(
      SearchQueryChanged event,
      Emitter<AllTaskState> emit,
      ) {
    emit(state.copyWith(searchQuery: event.query));
    // Don't auto-reload - user can pull to refresh or we can debounce
  }

  Future<void> _onRefreshTasks(
      RefreshTasks event,
      Emitter<AllTaskState> emit,
      ) async {
    add(LoadAllTasks(reset: true));
  }

  void _onResetTasksState(
      ResetTasksState event,
      Emitter<AllTaskState> emit,
      ) {
    _currentPage = 1;
    _hasMore = true;
    _allTasks.clear();
    _isLoadingMore = false;
    emit(const AllTaskState());
    debugPrint('[AllTaskBloc] ✔ State reset successfully');
  }
}
