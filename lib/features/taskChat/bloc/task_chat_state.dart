part of 'task_chat_bloc.dart';

class TaskChatState extends Equatable {
  final List<TimelineItem> timeline;
  final List<TimelineItem> sentMessages;
  final List<TimelineItem> receivedMessages;
  final List<File> selectedAttachments;
  final bool isLoading;
  final bool isSending;
  final bool hasError;
  final String? errorMessage;
  final ChatData? replyTo;
  final String? taskId;
  final String? currentUserId;
  final List<TeamMember> selectedMentions;


  const TaskChatState({
    this.timeline = const [],
    this.sentMessages = const [],
    this.receivedMessages = const [],
    this.selectedAttachments = const [],
    this.isLoading = false,
    this.isSending = false,
    this.hasError = false,
    this.errorMessage,
    this.replyTo,
    this.taskId,
    this.currentUserId,
    this.selectedMentions = const [],
  });

  TaskChatState copyWith({
    List<TimelineItem>? timeline,
    List<TimelineItem>? sentMessages,
    List<TimelineItem>? receivedMessages,
    List<File>? selectedAttachments,
    bool? isLoading,
    bool? isSending,
    bool? hasError,
    String? errorMessage,
    ChatData? replyTo,
    bool clearReplyTo = false,
    bool clearError = false,
    String? taskId,
    String? currentUserId,
    List<TeamMember>? selectedMentions,
  }) {
    return TaskChatState(
      timeline: timeline ?? this.timeline,
      sentMessages: sentMessages ?? this.sentMessages,
      receivedMessages: receivedMessages ?? this.receivedMessages,
      selectedAttachments: selectedAttachments ?? this.selectedAttachments,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      hasError: clearError ? false : (hasError ?? this.hasError),
      errorMessage: clearError ? null : errorMessage,
      replyTo: clearReplyTo ? null : (replyTo ?? this.replyTo),
      taskId: taskId ?? this.taskId,
      currentUserId: currentUserId ?? this.currentUserId,
      selectedMentions: selectedMentions ?? this.selectedMentions,
    );
  }

  @override
  List<Object?> get props => [
    timeline,
    sentMessages,
    receivedMessages,
    selectedAttachments,
    isLoading,
    isSending,
    hasError,
    errorMessage,
    replyTo,
    taskId,
    currentUserId,
    selectedMentions,
  ];
}