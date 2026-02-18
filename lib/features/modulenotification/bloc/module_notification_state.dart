part of 'module_notification_bloc.dart';

class ModuleNotificationState extends Equatable {
  final bool isLoading;
  final bool isRefreshing;
  final bool isError;
  final String errorMessage;

  final List<AppNotificationResponseModel> groups;
  final bool wasEverLoaded;

  final String? submittingId;
  final Map<String, String> approvedMap;

  final String? markingReadId;
  final Map<String, bool> readMap;

  const ModuleNotificationState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isError = false,
    this.errorMessage = '',
    this.groups = const [],
    this.wasEverLoaded = false,
    this.submittingId,
    this.approvedMap = const {},
    this.markingReadId,
    this.readMap = const {},
  });

  /// True only when the server returned zero groups on the very first fetch.
  bool get isEmpty =>
      !isLoading && !isError && groups.isEmpty && !wasEverLoaded;
  bool get hasData => groups.isNotEmpty;

  /// Key format: '{notificationId}_{taskStatus}' e.g. 'notif123_1'
  /// Uses notificationId (not workId) since workId can repeat across types.
  bool isSubmitting(String notificationId, String taskStatus) =>
      submittingId == '${notificationId}_$taskStatus';
  String? actionFor(String notificationId) => approvedMap[notificationId];

  /// For mark-as-read loading state, keyed by readKey (type_workId or type_chatId).
  bool isMarkingRead(String readKey) => markingReadId == readKey;
  bool isRead(String readKey) => readMap[readKey] == true;

  int get pendingActionCount => groups
      .where((g) =>
  TaskNotificationType.from(g.type) ==
      TaskNotificationType.actionNotification)
      .expand((g) => g.list)
      .where((t) => actionFor(t.notificationId) == null)
      .length;

  /// Removes an action_notification item matched by notificationId —
  /// the unique key the API returns for that type specifically.
  List<AppNotificationResponseModel> groupsWithoutActionNotification(
      String notificationId) {
    if (notificationId.isEmpty) return groups;

    const groupType = 'action_notification';
    final updated = <AppNotificationResponseModel>[];
    for (final group in groups) {
      if (group.type != groupType) {
        updated.add(group);
        continue;
      }
      final filtered = group.list
          .where((t) => t.notificationId != notificationId)
          .toList();
      if (filtered.isNotEmpty) {
        updated.add(AppNotificationResponseModel(
          type: group.type,
          list: filtered,
        ));
      }
    }
    return updated;
  }

  /// Removes an item from all other types using [BcstepTaskModel.readKey].
  /// workId → status_change, checker_change, new_tasks, in_progress, etc.
  /// chatId → mentioned_message.
  List<AppNotificationResponseModel> groupsWithoutItem({
    required String groupType,
    required String itemReadKey,
  }) {
    if (itemReadKey.isEmpty) return groups;

    final updated = <AppNotificationResponseModel>[];
    for (final group in groups) {
      // Only touch the matching group — all other groups pass through unchanged.
      if (group.type != groupType) {
        updated.add(group);
        continue;
      }

      final filtered = group.list
          .where((t) => t.readKey(groupType) != itemReadKey)
          .toList();

      // If items remain, keep the group; otherwise drop it (header disappears).
      if (filtered.isNotEmpty) {
        updated.add(AppNotificationResponseModel(
          type: group.type,
          list: filtered,
        ));
      }
    }
    return updated;
  }

  ModuleNotificationState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isError,
    String? errorMessage,
    List<AppNotificationResponseModel>? groups,
    bool? wasEverLoaded,
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
      wasEverLoaded: wasEverLoaded ?? this.wasEverLoaded,
      submittingId:
      clearSubmittingId ? null : (submittingId ?? this.submittingId),
      approvedMap: approvedMap ?? this.approvedMap,
      markingReadId:
      clearMarkingReadId ? null : (markingReadId ?? this.markingReadId),
      readMap: readMap ?? this.readMap,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isRefreshing,
    isError,
    errorMessage,
    groups,
    wasEverLoaded,
    submittingId,
    approvedMap,
    markingReadId,
    readMap,
  ];
}