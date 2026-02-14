import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/core/storage/storage_service.dart';
import 'package:task_manager/features/home/repository/task_repository.dart';

import '../../../core/models/task_model.dart';

part 'task_details_event.dart';
part 'task_details_state.dart';

class TaskDetailsBloc extends Bloc<TaskDetailsEvent, TaskDetailsState> {
  final TaskRepository _taskRepository;
  final StorageService _storageService;

  TaskDetailsBloc(
      this._taskRepository,
      this._storageService,
      ) : super(TaskDetailsState()) {
    on<FetchTaskDetails>(_onFetchTaskDetails);
  }
  Future<void> _onFetchTaskDetails (
      FetchTaskDetails event,
      Emitter<TaskDetailsState> emit,
      ) async {
    print(' [TaskDetailsBloc] Fetching task details for taskId: ${event.taskId}');
    emit(state.copyWith(isLoading: true));



  }

}
