part of 'module_notification_bloc.dart';

class ModuleNotificationState extends Equatable {
  final bool isLoading;
  final bool isRefreshing;
  final bool isError;
  final String errorMessage;

  final List<AppNotificationResponseModel> groups;

  final String? submittingId;
  /// notificationId → 'Completed' | 'Cancelled' | 'Hold'
  final Map<String, String> approvedMap;

  final String? markingReadId;
  final Map<String, bool> readMap;


  const ModuleNotificationState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isError = false,
    this.errorMessage = '',
    this.groups = const [],
    this.submittingId,
    this.approvedMap = const {},
    this.markingReadId,
    this.readMap = const {},

  });

  bool get isEmpty => !isLoading && !isError && groups.isEmpty;
  bool get hasData => groups.isNotEmpty;

  bool isSubmitting(String notificationId) => submittingId == notificationId;
  String? actionFor(String notificationId) => approvedMap[notificationId];
  bool isMarkingRead(String notificationId) =>
      markingReadId == notificationId;

  bool isRead(String notificationId) =>
      readMap[notificationId] == true;
  int get pendingActionCount => groups
      .where((g) =>
  TaskNotificationType.from(g.type) ==
      TaskNotificationType.actionNotification)
      .expand((g) => g.list)
      .where((t) => actionFor(t.notificationId) == null)
      .length;

  ModuleNotificationState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isError,
    String? errorMessage,
    List<AppNotificationResponseModel>? groups,
    String? submittingId,
    Map<String, String>? approvedMap,
    bool clearSubmittingId = false,
    String? markingReadId,
    Map<String, bool>? readMap,
    bool clearMarkingReadId = false,
  }) {
    return ModuleNotificationState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      groups: groups ?? this.groups,
      submittingId:
      clearSubmittingId ? null : (submittingId ?? this.submittingId),
      approvedMap: approvedMap ?? this.approvedMap,
      markingReadId:
      clearMarkingReadId ? null : (markingReadId ?? this.markingReadId),

    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isRefreshing,
    isError,
    errorMessage,
    groups,
    submittingId,
    approvedMap,
    markingReadId,
    readMap,
  ];
}