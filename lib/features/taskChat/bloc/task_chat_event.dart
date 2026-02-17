part of 'task_chat_bloc.dart';

sealed class TaskChatEvent extends Equatable {
  const TaskChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatTimeline extends TaskChatEvent {
  final String taskId;

  const LoadChatTimeline(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class SendChatMessage extends TaskChatEvent {
  final String message;
  final List<String> mentionedUserIds;
  final String? replyToId;

  const SendChatMessage({
    required this.message,
    this.mentionedUserIds = const [],
    this.replyToId,
  });

  @override
  List<Object?> get props => [message, mentionedUserIds, replyToId];
}

class RefreshChat extends TaskChatEvent {
  const RefreshChat();
}

class SetReplyTo extends TaskChatEvent {
  final ChatData? replyMessage;

  const SetReplyTo(this.replyMessage);

  @override
  List<Object?> get props => [replyMessage];
}

class ClearReplyTo extends TaskChatEvent {
  const ClearReplyTo();
}

class PickFromCamera extends TaskChatEvent {
  const PickFromCamera();
}

class PickFromGallery extends TaskChatEvent {
  const PickFromGallery();
}

class PickDocuments extends TaskChatEvent {
  const PickDocuments();
}

class RemoveAttachment extends TaskChatEvent {
  final File file;

  const RemoveAttachment(this.file);

  @override
  List<Object?> get props => [file];
}

class ClearAttachments extends TaskChatEvent {
  const ClearAttachments();
}

class AddMention extends TaskChatEvent {
  final TeamMember member;
  const AddMention(this.member);
}

class RemoveMention extends TaskChatEvent {
  final String userId;
  const RemoveMention(this.userId);
}

class ClearMentions extends TaskChatEvent {}
