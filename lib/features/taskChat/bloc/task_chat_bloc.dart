import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:task_manager/features/utils/app_exception.dart';

import '../../../core/models/taskchat/chat_data.dart';
import '../../../core/models/taskchat/task_chat_message.dart';
import '../../../core/models/taskchat/team_member.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../home/repository/task_repository.dart';

part 'task_chat_event.dart';

part 'task_chat_state.dart';

class TaskChatBloc extends Bloc<TaskChatEvent, TaskChatState> {
  static const String _tag = "TaskChatBloc";

  final TaskRepository _taskRepository;
  final StorageService _storageService;
  final ImagePicker _imagePicker = ImagePicker();

  TaskChatBloc(this._taskRepository,
      this._storageService,) : super(const TaskChatState()) {
    on<LoadChatTimeline>(_onLoadChatTimeline);
    on<SendChatMessage>(_onSendChatMessage);
    on<RefreshChat>(_onRefreshChat);
    on<SetReplyTo>(_onSetReplyTo);
    on<ClearReplyTo>(_onClearReplyTo);
    on<PickFromCamera>(_onPickFromCamera);
    on<PickFromGallery>(_onPickFromGallery);
    on<PickDocuments>(_onPickDocuments);
    on<RemoveAttachment>(_onRemoveAttachment);
    on<ClearAttachments>(_onClearAttachments);
    on<AddMention>(_onAddMention);
    on<RemoveMention>(_onRemoveMention);
    on<ClearMentions>(_onClearMentions);
  }

  // ================= LOAD CHAT =================

  Future<void> _onLoadChatTimeline(LoadChatTimeline event,
      Emitter<TaskChatState> emit,) async {
    print("$_tag: Loading chat for Task ID: ${event.taskId}");

    try {
      emit(state.copyWith(
        isLoading: true,
        clearError: true,
        taskId: event.taskId,
      ));

      final userId = await _storageService.read(StorageKeys.userId);
      final currentUserId = userId;

      print("$_tag: CurrentUserId = $currentUserId");

      final response =
      await _taskRepository.getTaskChat(taskId: event.taskId);

      print("$_tag: Chat API status = ${response.status}");

      if (response.data != null && response.status) {
        print("$_tag: Timeline count = ${response.data?.length}");

        final List<TimelineItem> sentMessages = [];
        final List<TimelineItem> receivedMessages = [];
        final List<TimelineItem> timeline = [];

        timeline.addAll(response.data as Iterable<TimelineItem>);

        for (final item in timeline) {
          if (item.isChat && item.chatData != null) {
            if (item.chatData!.userId.toString() == currentUserId) {
              sentMessages.add(item);
            } else {
              receivedMessages.add(item);
            }
          }
        }

        print(
            "$_tag: Sent = ${sentMessages.length}, Received = ${receivedMessages
                .length}");

        emit(state.copyWith(
          isLoading: false,
          timeline: response.data,
          sentMessages: sentMessages,
          receivedMessages: receivedMessages,
          currentUserId: currentUserId,
          clearError: true,
        ));
      } else {
        print("$_tag: Chat API error = ${response.message}");

        emit(state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: response.message,
        ));
      }
    } catch (e) {
      print("$_tag: Exception in LoadChatTimeline = $e");
      final exception = AppExceptionMapper.from(e);

      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: exception.message,
      ));
    }
  }

  // ================= SEND MESSAGE =================

  Future<void> _onSendChatMessage(SendChatMessage event,
      Emitter<TaskChatState> emit,) async {
    if (state.taskId == null) return;

    print("$_tag: Sending message for Task ID = ${state.taskId}");
    print("$_tag: Message = ${event.message}");
    print("$_tag: Attachments count = ${state.selectedAttachments.length}");
    // print reply
    print("$_tag: ReplyTo = ${state.replyTo?.chatId.toString()}");


    try {
      emit(state.copyWith(isSending: true, clearError: true));

      final userId = await _storageService.read(StorageKeys.userId);
      final compId = await _storageService.read(StorageKeys.companyId);

      print("$_tag: userId = $userId");
      print("$_tag: companyId = $compId");

      final response = await _taskRepository.insertTaskChat(
        workId: state.taskId ?? '',
        userId: userId ?? '',
        compId: compId ?? '',
        chatMessage: event.message,
        files: state.selectedAttachments,
        replyTo: state.replyTo?.chatId.toString(),
        mentionUserId: event.mentionedUserIds,
      );

      print("$_tag: Send message API status = ${response.status}");

      if (response.status) {
        print("$_tag: Message sent successfully");

        add(ClearAttachments());
        add(RefreshChat());

        emit(state.copyWith(
          isSending: false,
          clearReplyTo: true,
          clearError: true,
        ));
      } else {
        print("$_tag: Send message failed = ${response.message}");

        emit(state.copyWith(
          isSending: false,
          hasError: true,
          errorMessage: response.message,
        ));
      }
    } catch (e) {
      print("$_tag: Exception in SendChatMessage = $e");
      final exception = AppExceptionMapper.from(e);
      emit(state.copyWith(
        isSending: false,
        hasError: true,
        errorMessage:  exception.message,
      ));
    }
  }

  // ================= REFRESH =================

  Future<void> _onRefreshChat(RefreshChat event,
      Emitter<TaskChatState> emit,) async {
    print("$_tag: Refreshing chat");

    if (state.taskId != null) {
      add(LoadChatTimeline(state.taskId.toString()));
    }
  }

  // ================= REPLY =================

  void _onSetReplyTo(SetReplyTo event,
      Emitter<TaskChatState> emit,) {
    print("$_tag: Set reply to messageId = ${event.replyMessage?.chatId}");
    emit(state.copyWith(replyTo: event.replyMessage));

  }

  void _onClearReplyTo(ClearReplyTo event,
      Emitter<TaskChatState> emit,) {
    print("$_tag: Reply cleared");
    emit(state.copyWith(clearReplyTo: true));
  }

  // ================= CAMERA =================

  Future<void> _onPickFromCamera(PickFromCamera event,
      Emitter<TaskChatState> emit,) async {
    print("$_tag: Opening camera");

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        print("$_tag: Camera image selected = ${image.path}");

        final file = File(image.path);
        final updatedAttachments = List<File>.from(state.selectedAttachments)
          ..add(file);

        emit(state.copyWith(
          selectedAttachments: updatedAttachments,
        ));
      }
    } catch (e) {
      print("$_tag: Camera exception = $e");

      emit(state.copyWith(
        hasError: true,
        errorMessage: 'Failed to capture image: ${e.toString()}',
      ));
    }
  }

  // ================= GALLERY =================

  Future<void> _onPickFromGallery(PickFromGallery event,
      Emitter<TaskChatState> emit,) async {
    print("$_tag: Opening gallery");

    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        print("$_tag: Gallery images selected count = ${images.length}");

        final files = images.map((xFile) => File(xFile.path)).toList();
        final updatedAttachments = List<File>.from(state.selectedAttachments)
          ..addAll(files);

        emit(state.copyWith(
          selectedAttachments: updatedAttachments,
        ));
      }
    } catch (e) {
      print("$_tag: Gallery exception = $e");

      emit(state.copyWith(
        hasError: true,
        errorMessage: 'Failed to pick images: ${e.toString()}',
      ));
    }
  }

  // ================= DOCUMENTS =================

  Future<void> _onPickDocuments(PickDocuments event,
      Emitter<TaskChatState> emit,) async {
    print("$_tag: Picking documents");

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'txt',
          'jpg',
          'jpeg',
          'png'
        ],
      );

      if (result != null && result.files.isNotEmpty) {
        print("$_tag: Documents selected count = ${result.files.length}");

        final files = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();

        final updatedAttachments = List<File>.from(state.selectedAttachments)
          ..addAll(files);

        emit(state.copyWith(
          selectedAttachments: updatedAttachments,
        ));
      }
    } catch (e) {
      print("$_tag: Document picker exception = $e");

      emit(state.copyWith(
        hasError: true,
        errorMessage: 'Failed to pick documents: ${e.toString()}',
      ));
    }
  }

  // ================= REMOVE ATTACHMENT =================

  void _onRemoveAttachment(RemoveAttachment event,
      Emitter<TaskChatState> emit,) {
    print("$_tag: Removed attachment = ${event.file.path}");

    final updatedAttachments = List<File>.from(state.selectedAttachments)
      ..remove(event.file);

    emit(state.copyWith(
      selectedAttachments: updatedAttachments,
    ));
  }

  // ================= CLEAR ATTACHMENTS =================

  void _onClearAttachments(ClearAttachments event,
      Emitter<TaskChatState> emit,) {
    print("$_tag: All attachments cleared");

    emit(state.copyWith(
      selectedAttachments: const [],
    ));
  }

  void _onAddMention(AddMention event,
      Emitter<TaskChatState> emit,) {
    final alreadyExists = state.selectedMentions
        .any((m) => m.userId == event.member.userId);

    if (!alreadyExists) {
      emit(state.copyWith(
        selectedMentions: [
          ...state.selectedMentions,
          event.member,
        ],
      ));
    }
  }

  void _onRemoveMention(RemoveMention event,
      Emitter<TaskChatState> emit,) {
    emit(state.copyWith(
      selectedMentions: state.selectedMentions
          .where((m) => m.userId != event.userId)
          .toList(),
    ));
  }
  void _onClearMentions(ClearMentions event,
      Emitter<TaskChatState> emit,) {
    emit(state.copyWith(
      selectedMentions: const [],
    ));
  }
}
