import 'package:bloc/bloc.dart';
import 'package:task_manager/core/storage/storage_keys.dart';
import 'package:task_manager/core/storage/storage_service.dart';

import '../../../features/home/repository/task_repository.dart';

part 'task_priority_event.dart';

part 'task_priority_state.dart';

class ChangePriorityBloc
    extends Bloc<ChangePriorityEvent, ChangePriorityState> {
  final TaskRepository repository;
  final StorageService storageService;

  ChangePriorityBloc({required this.repository, required this.storageService})
    : super(ChangePriorityInitial()) {
    on<SubmitPriorityChange>(_onSubmit);
    on<ResetPriorityState>(_onReset);
  }

  Future<void> _onSubmit(
    SubmitPriorityChange event,
    Emitter<ChangePriorityState> emit,
  ) async {
    emit(ChangePriorityLoading());
    try {
      final userId = await storageService.read(StorageKeys.userId) ?? "";
      final response = await repository.changePriority(
        userId: userId,
        taskId: event.taskId,
        priority: event.priority,
      );
      emit(ChangePrioritySuccess(message: response.message));
    } catch (e) {
      emit(ChangePriorityFailure(message: e.toString()));
    }
  }

  void _onReset(ResetPriorityState event, Emitter<ChangePriorityState> emit) {
    emit(ChangePriorityInitial());
  }
}
