import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:task_manager/core/storage/storage_keys.dart';
import 'package:task_manager/core/storage/storage_service.dart';

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
    emit(state.copyWith(submittingId: event.notificationId));
    try {
      final userId = await _storageService.read(StorageKeys.userId) ?? '';

      final response = await _repository.taskManagerApproval(
        taskId: int.tryParse(event.workId) ?? 0,
        userId: int.tryParse(userId) ?? 0,
        taskStatus: event.taskStatus,
        notificationId: event.notificationId,
      );

      if (response.status == true) {
        final updated = Map<String, String>.from(state.approvedMap)
          ..[event.notificationId] = event.taskStatus;
        emit(state.copyWith(clearSubmittingId: true, approvedMap: updated));
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
      emit(
        state.copyWith(
          clearSubmittingId: true,
          isError: true,
          errorMessage: e.toString(),
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
      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isError: true,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onMarkedAsRead(
      NotificationMarkedAsRead event,
      Emitter<ModuleNotificationState> emit,
      ) async {
    const String tag = "ModuleNotificationBloc";

    debugPrint("[$tag] MarkAsRead started");
    debugPrint("[$tag] NotificationId: ${event.notificationId}");
    debugPrint("[$tag] SeenUrl: ${event.seenUrl}");

    // Emit loading state
    emit(state.copyWith(markingReadId: event.notificationId));

    try {
      debugPrint("[$tag] Calling repository.markAsReadFromUrl");

      final response =
      await _repository.markAsReadFromUrl(event.seenUrl);

      debugPrint("[$tag] Response received");
      debugPrint("[$tag] Status: ${response.status}");
      debugPrint("[$tag] Message: ${response.message}");

      if (response.status) {
        final updatedReadMap = Map<String, bool>.from(state.readMap)
          ..[event.notificationId] = true;

        debugPrint("[$tag] Updating local readMap");
        debugPrint("[$tag] Updated readMap: $updatedReadMap");

        emit(state.copyWith(
          readMap: updatedReadMap,
          clearMarkingReadId: true,
        ));

        debugPrint("[$tag] Success state emitted");
      } else {
        debugPrint("[$tag] API returned failure");

        emit(
          state.copyWith(
            clearMarkingReadId: true,
            isError: true,
            errorMessage: response.message ?? "Failed",
          ),
        );

        debugPrint("[$tag] Error state emitted");
      }
    } catch (e, stackTrace) {
      debugPrint("[$tag] Exception occurred");
      debugPrint("[$tag] Error: $e");
      debugPrint("[$tag] StackTrace: $stackTrace");

      emit(
        state.copyWith(
          clearMarkingReadId: true,
          isError: true,
          errorMessage: e.toString(),
        ),
      );

      debugPrint("[$tag] Exception state emitted");
    }

    debugPrint("[$tag] MarkAsRead finished");
  }

}
