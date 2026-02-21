import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/task_model.dart';
import '../../../../core/models/taskchat/chat_data.dart';
import '../../../../core/models/taskchat/team_member.dart';
import '../../bloc/task_chat_bloc.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_timeline.dart';
import '../widgets/mention_list_overlay.dart';
import '../widgets/reply_preview_banner.dart';
import '../widgets/team_members_dialog.dart';


class TaskChatScreen extends StatefulWidget {
  final TMTasksModel task;

  const TaskChatScreen({super.key, required this.task});

  @override
  State<TaskChatScreen> createState() => _TaskChatScreenState();
}

class _TaskChatScreenState extends State<TaskChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  bool _showMentionList = false;
  String _mentionQuery = '';
  String? _highlightedChatId;

  /// Keeps a stable GlobalKey per chat message for scroll-to navigation.
  final Map<String, GlobalKey> _messageKeys = {};

  // ─── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    context
        .read<TaskChatBloc>()
        .add(LoadChatTimeline(widget.task.taskId.toString()));
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ─── Mention helpers ────────────────────────────────────────────────────────

  void _onTextChanged() {
    final text = _messageController.text;
    final cursor = _messageController.selection.baseOffset;
    if (cursor < 0) return;

    final lastAt = text.lastIndexOf('@', cursor - 1);
    if (lastAt == -1) {
      _setMentionState(show: false, query: '');
      return;
    }

    final afterAt = text.substring(lastAt + 1, cursor);
    if (afterAt.contains(' ')) {
      _setMentionState(show: false, query: '');
    } else {
      _setMentionState(show: true, query: afterAt.toLowerCase());
    }
  }

  void _setMentionState({required bool show, required String query}) {
    if (_showMentionList != show || _mentionQuery != query) {
      setState(() {
        _showMentionList = show;
        _mentionQuery = query;
      });
    }
  }

  List<TeamMember> get _teamMembers {
    final members = <String, TeamMember>{};

    members[widget.task.makerId.toString()] = TeamMember(
      userId: widget.task.makerId.toString(),
      userName: widget.task.makerName ?? 'Maker',
      profileUrl: '',
      role: 'Maker',
    );
    members[widget.task.checkerId.toString()] = TeamMember(
      userId: widget.task.checkerId.toString(),
      userName: widget.task.checkerName ?? 'Checker',
      profileUrl: '',
      role: 'Checker',
    );
    members[widget.task.pcEngrId.toString()] = TeamMember(
      userId: widget.task.pcEngrId.toString(),
      userName: widget.task.pcEngrName ?? 'PC Engineer',
      profileUrl: '',
      role: 'PC Engineer',
    );

    return members.values.toList();
  }

  List<TeamMember> get _filteredMembers {
    if (_mentionQuery.isEmpty) return _teamMembers;
    return _teamMembers
        .where((m) => m.userName.toLowerCase().contains(_mentionQuery))
        .toList();
  }

  void _onMentionSelected(TeamMember member) {
    context.read<TaskChatBloc>().add(AddMention(member));

    // Replace the @query in the text field with a clean @name
    final text = _messageController.text;
    final cursor = _messageController.selection.baseOffset;
    final lastAt = text.lastIndexOf('@', cursor - 1);
    if (lastAt != -1) {
      final newText =
          text.substring(0, lastAt) + text.substring(cursor);
      _messageController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: lastAt),
      );
    }

    _setMentionState(show: false, query: '');
    _focusNode.requestFocus();
  }

  // ─── Send ────────────────────────────────────────────────────────────────────

  void _sendMessage() {
    final state = context.read<TaskChatBloc>().state;
    final message = _messageController.text.trim();
    final mentionIds = state.selectedMentions.map((e) => e.userId).toList();

    if (mentionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please mention at least one member before sending'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (message.isEmpty && state.selectedAttachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message or attachment required')),
      );
      return;
    }

    context.read<TaskChatBloc>().add(
      SendChatMessage(
        message: message,
        mentionedUserIds: mentionIds,
        replyToId: '',
      ),
    );

    _messageController.clear();
    context.read<TaskChatBloc>().add(ClearMentions());
    _setMentionState(show: false, query: '');
    _scrollToBottom();
  }

  // ─── Scroll helpers ──────────────────────────────────────────────────────────

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _scrollToMessage(String chatId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _messageKeys[chatId];
      if (key == null) return;
      final ctx = key.currentContext;
      if (ctx == null) return;

      final box = ctx.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero);
      final targetOffset =
      (_scrollController.offset + position.dy - 100).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );

      setState(() => _highlightedChatId = chatId);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _highlightedChatId = null);
      });
    });
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<TaskChatBloc, TaskChatState>(
        listener: _handleStateChanges,
        builder: (context, state) => _buildBody(state),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Task Conversation', style: TextStyle(fontSize: 18)),
          Tooltip(
            message: widget.task.taskDescription,
            child: Text(
              widget.task.taskDescription,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.normal),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.people_outline),
          tooltip: 'Team members',
          onPressed: () =>
              showTeamMembersDialog(context, _teamMembers),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: () =>
              context.read<TaskChatBloc>().add(const RefreshChat()),
        ),
      ],
    );
  }

  void _handleStateChanges(BuildContext context, TaskChatState state) {
    if (state.hasError &&
        state.errorMessage != null &&
        state.timeline.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
    if (!state.isLoading && state.timeline.isNotEmpty) {
      _scrollToBottom();
    }
  }

  Widget _buildBody(TaskChatState state) {
    return Column(
      children: [
        // ── Timeline ──────────────────────────────────────────────────────────
        Expanded(
          child: ChatTimeline(
            state: state,
            scrollController: _scrollController,
            messageKeys: _messageKeys,
            highlightedChatId: _highlightedChatId,
            onReplyScrollRequest: _scrollToMessage,
            onReply: (ChatData chat) {
              context.read<TaskChatBloc>().add(SetReplyTo(chat));
              _focusNode.requestFocus();
            },
            onRefresh: () =>
                context.read<TaskChatBloc>().add(const RefreshChat()),
          ),
        ),

        // ── Mention list ─────────────────────────────────────────────────────
        if (_showMentionList)
          MentionListOverlay(
            members: _filteredMembers,
            onSelected: _onMentionSelected,
            onDismiss: () {
              context.read<TaskChatBloc>().add(ClearMentions());
              _setMentionState(show: false, query: '');
            },
          ),

        // ── Reply preview ─────────────────────────────────────────────────────
        if (state.replyTo != null)
          ReplyPreviewBanner(
            replyTo: state.replyTo!,
            onTap: () =>
                _scrollToMessage(state.replyTo!.chatId.toString()),
          ),

        // ── Input bar (mentions indicator + text field) ───────────────────────
        ChatInputBar(
          messageController: _messageController,
          focusNode: _focusNode,
          onSend: _sendMessage,
        ),
      ],
    );
  }
}