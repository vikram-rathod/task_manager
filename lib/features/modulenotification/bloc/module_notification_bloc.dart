import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/core/storage/storage_keys.dart';
import 'package:task_manager/core/storage/storage_service.dart';
import 'package:task_manager/features/utils/app_exception.dart';

import '../../../core/models/app_notification_acknow_model.dart';
import '../app_notification_repository.dart';
import '../notification_type_config.dart';

part 'module_notification_event.dart';

part 'module_notification_state.dart';

class ModuleNotificationBloc
    extends Bloc<ModuleNotificationEvent, ModuleNotificationState> {
  final AppNotificationRepository _repository;
  final StorageService _storageService;

  ModuleNotificationBloc(this._repository, this._storageService)
      : super(const ModuleNotificationState()) {
    on<NotificationFetched>(_onFetched);
    on<NotificationRefreshed>(_onRefreshed);
    on<NotificationApprovalSubmitted>(_onApprovalSubmitted);
    on<NotificationErrorCleared>(_onErrorCleared);
    on<NotificationMarkedAsRead>(_onMarkedAsRead);
  }

  Future<void> _onFetched(
      NotificationFetched event,
      Emitter<ModuleNotificationState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, isError: false, errorMessage: ''));
    await _fetch(emit);
  }

  Future<void> _onRefreshed(
      NotificationRefreshed event,
      Emitter<ModuleNotificationState> emit,
      ) async {
    emit(state.copyWith(isRefreshing: true, isError: false, errorMessage: ''));
    await _fetch(emit);
  }

  Future<void> _onApprovalSubmitted(
      NotificationApprovalSubmitted event,
      Emitter<ModuleNotificationState> emit,
      ) async {
    // Key = '{notificationId}_{taskStatus}' — notificationId is unique per approval item
    emit(state.copyWith(submittingId: '${event.notificationId}_${event.taskStatus}'));
    try {
      final userId = await _storageService.read(StorageKeys.userId) ?? '';

      final response = await _repository.taskManagerApproval(
        taskId: int.tryParse(event.workId) ?? 0,
        userId: int.tryParse(userId) ?? 0,
        taskStatus: event.taskStatus,
        notificationId: event.notificationId,
      );

      if (response.status == true) {
        // Remove by notificationId — unique per action_notification item
        final updatedGroups = state.groupsWithoutActionNotification(
          event.notificationId,
        );
        emit(state.copyWith(
          clearSubmittingId: true,
          groups: updatedGroups,
        ));
      } else {
        emit(
          state.copyWith(
            clearSubmittingId: true,
            isError: true,
            errorMessage: response.message ?? 'Action failed.',
          ),
        );
      }
    } catch (e) {
      final exception = AppExceptionMapper.from(e);
      emit(
        state.copyWith(
          clearSubmittingId: true,
          isError: true,
          errorMessage: exception.message,
        ),
      );
    }
  }

  void _onErrorCleared(
      NotificationErrorCleared event,
      Emitter<ModuleNotificationState> emit,
      ) => emit(state.copyWith(isError: false, errorMessage: ''));

  Future<void> _fetch(Emitter<ModuleNotificationState> emit) async {
    try {
      final userId = await _storageService.read(StorageKeys.userId) ?? '';
      final response = await _repository.getNotifications(userId: userId);

      if (response.status == true && response.data != null) {
        emit(
          state.copyWith(
            isLoading: false,
            isRefreshing: false,
            isError: false,
            groups: response.data!,
            wasEverLoaded: true,
          ),
        );
      } else {

        emit(
          state.copyWith(
            isLoading: false,
            isRefreshing: false,
            isError: true,
            errorMessage: response.message ?? 'Something went wrong.',
          ),
        );
      }
    } catch (e) {
      final exception = AppExceptionMapper.from(e);
      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isError: true,
          errorMessage: exception.message,
        ),
      );
    }
  }

  Future<void> _onMarkedAsRead(
      NotificationMarkedAsRead event,
      Emitter<ModuleNotificationState> emit,
      ) async {
    // Use readKey as the loading state key (type_workId or type_chatId)
    emit(state.copyWith(markingReadId: event.readKey));

    try {
      final response = await _repository.markAsReadFromUrl(event.seenUrl);

      if (response.status) {
        final updatedGroups = state.groupsWithoutItem(
          groupType: event.groupType,
          itemReadKey: event.readKey,
        );

        emit(state.copyWith(
          groups: updatedGroups,
          clearMarkingReadId: true,
        ));
      } else {
        emit(
          state.copyWith(
            clearMarkingReadId: true,
            isError: true,
            errorMessage: response.message.isNotEmpty == true
                ? response.message
                : 'Failed to mark as read. Please try again.',
          ),
        );
      }
    } catch (e) {
      final exception = AppExceptionMapper.from(e);
      emit(
        state.copyWith(
          clearMarkingReadId: true,
          isError: true,
          errorMessage: exception.message,
        ),
      );
    }
  }

}