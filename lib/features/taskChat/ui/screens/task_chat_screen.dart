import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/task_model.dart';
import '../../../../core/models/taskchat/chat_data.dart';
import '../../../../core/models/taskchat/team_member.dart';
import '../../../../reusables/attachment_bottom_sheet.dart';
import '../../../../reusables/date_header.dart';
import '../../../home/model/task_history_model.dart';
import '../../bloc/task_chat_bloc.dart';
import '../receiver_message_bubble.dart';
import '../sender_message_bubble.dart';

class TaskChatScreen extends StatefulWidget {
  final TMTasksModel task;

  const TaskChatScreen({super.key, required this.task});

  @override
  State<TaskChatScreen> createState() => _TaskChatScreenState();
}

class _TaskChatScreenState extends State<TaskChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _showMentionList = false;
  String _mentionQuery = '';
  int _mentionStartIndex = -1;
  String? _highlightedChatId;
  final Map<String, GlobalKey> _messageKeys = {};


  @override
  void initState() {
    super.initState();
    context.read<TaskChatBloc>().add(
      LoadChatTimeline(widget.task.taskId.toString()),
    );
    _messageController.addListener(_onMessageTextChanged);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onMessageTextChanged() {
    final text = _messageController.text;
    final cursorPos = _messageController.selection.baseOffset;

    if (cursorPos < 0) return;

    final lastAtIndex = text.lastIndexOf('@', cursorPos - 1);

    if (lastAtIndex != -1) {
      final textAfterAt = text.substring(lastAtIndex + 1, cursorPos);

      if (textAfterAt.contains(' ')) {
        setState(() {
          _showMentionList = false;
          _mentionQuery = '';
        });
        return;
      }

      setState(() {
        _showMentionList = true;
        _mentionQuery = textAfterAt.toLowerCase();
        _mentionStartIndex = lastAtIndex;
      });
    } else {
      setState(() {
        _showMentionList = false;
        _mentionQuery = '';
      });
    }
  }

  List<TeamMember> _getTeamMembers() {
    final members = <String, TeamMember>{};

    if (widget.task.makerId != null) {
      members[widget.task.makerId.toString()] = TeamMember(
        userId: widget.task.makerId.toString(),
        userName: widget.task.makerName ?? 'Maker',
        profileUrl: '',
        role: 'Maker',
      );
    }

    if (widget.task.checkerId != null) {
      members[widget.task.checkerId.toString()] = TeamMember(
        userId: widget.task.checkerId.toString(),
        userName: widget.task.checkerName ?? 'Checker',
        profileUrl: '',
        role: 'Checker',
      );
    }

    if (widget.task.pcEngrId != null) {
      members[widget.task.pcEngrId.toString()] = TeamMember(
        userId: widget.task.pcEngrId.toString(),
        userName: widget.task.pcEngrName ?? 'PC Engineer',
        profileUrl: '',
        role: 'PC Engineer',
      );
    }

    return members.values.toList();
  }

  List<TeamMember> _getFilteredTeamMembers() {
    final allMembers = _getTeamMembers();

    if (_mentionQuery.isEmpty) {
      return allMembers;
    }

    return allMembers.where((member) {
      return member.userName.toLowerCase().contains(_mentionQuery);
    }).toList();
  }

  void _onMentionSelected(TeamMember member) {
    context.read<TaskChatBloc>().add(AddMention(member));
  }

  void _sendMessage(TaskChatState state) {
    final message = _messageController.text.trim();
    final mentionIds = state.selectedMentions.map((e) => e.userId).toList();

    final hasAttachments = state.selectedAttachments.isNotEmpty;

    //  Block if no mention selected
    if (mentionIds.isEmpty) {
      debugPrint(" Cannot send message without mention");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please mention at least one user")),
      );
      return;
    }

    //  Block only if BOTH message & attachment are empty
    if (message.isEmpty && !hasAttachments) {
      debugPrint(" Message & attachment both empty");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Message or attachment required")),
      );
      return;
    }

    debugPrint(" Sending Message");
    debugPrint(" Message: $message");
    debugPrint(" Attachments: ${state.selectedAttachments.length}");
    debugPrint(" Mention IDs: ${mentionIds.join(',')}");

    context.read<TaskChatBloc>().add(
      SendChatMessage(
        message: message,
        mentionedUserIds: mentionIds,
        replyToId: '',
      ),
    );

    _messageController.clear();
    context.read<TaskChatBloc>().add(ClearMentions());
    setState(() {
      _showMentionList = false;
      _mentionQuery = '';
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
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
  }

  void _scrollToMessage(String chatId, TaskChatState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _messageKeys[chatId];

      if (key == null) {
        debugPrint("Key not found for $chatId");
        return;
      }

      final context = key.currentContext;
      if (context == null) return;

      final box = context.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero);

      final scrollOffset =
          _scrollController.offset +
              position.dy -
              100; // 100 padding from top

      _scrollController.animateTo(
        scrollOffset.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );

      setState(() {
        _highlightedChatId = chatId;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _highlightedChatId = null;
          });
        }
      });
    });
  }

  Map<DateTime, List<dynamic>> _groupMessagesByDate(List<dynamic> timeline) {
    final grouped = <DateTime, List<dynamic>>{};

    for (final item in timeline) {
      DateTime date;

      if (item.isChat && item.chatData != null) {
        date = _parseDateFromString(item.chatData!.cdate);
      } else if (item.isHistory && item.historyData != null) {
        date = _parseDateFromString(item.historyData!.createdDate);
      } else {
        continue;
      }

      final dateKey = DateTime(date.year, date.month, date.day);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(item);
    }

    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  DateTime _parseDateFromString(String dateStr) {
    try {
      final parts = dateStr.split(' ');
      if (parts.isNotEmpty) {
        final dateParts = parts[0].split('-');
        if (dateParts.length == 3) {
          return DateTime(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
          );
        }
      }
    } catch (e) {
      debugPrint('Error parsing date: $e');
    }
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Task Conversation', style: TextStyle(fontSize: 18)),
            Text(
              widget.task.taskDescription,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showTeamMembersDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TaskChatBloc>().add(const RefreshChat());
            },
          ),
        ],
      ),
      body: BlocConsumer<TaskChatBloc, TaskChatState>(
        listener: (context, state) {
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
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(child: _buildChatTimeline(state)),
              if (_showMentionList) _buildMentionList(),
              if (state.replyTo != null) _buildReplyPreview(state.replyTo!),
              _buildMessageInput(state),
            ],
          );
        },
      ),
    );
  }

  void _showTeamMembersDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final members = _getTeamMembers();
        return AlertDialog(
          title: const Text('Team Members'),
          content: SizedBox(
            width: double.maxFinite,
            child: members.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No team members available'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final initial = member.userName.isNotEmpty
                          ? member.userName[0].toUpperCase()
                          : '?';

                      return ListTile(
                        leading: CircleAvatar(child: Text(initial)),
                        title: Text(
                          member.userName.isNotEmpty
                              ? member.userName
                              : 'Unknown',
                        ),
                        subtitle: Text(member.role),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatTimeline(TaskChatState state) {
    if (state.isLoading && state.timeline.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && state.timeline.isEmpty) {
      return _buildErrorView(state.errorMessage ?? 'Failed to load chat');
    }

    if (state.timeline.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final groupedMessages = _groupMessagesByDate(state.timeline);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TaskChatBloc>().add(const RefreshChat());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: groupedMessages.entries.fold<int>(
          0,
          (sum, entry) => sum + entry.value.length + 1,
        ),
        itemBuilder: (context, index) {
          int currentIndex = 0;

          for (final entry in groupedMessages.entries) {
            if (index == currentIndex) {
              return DateHeader(date: entry.key);
            }
            currentIndex++;

            if (index < currentIndex + entry.value.length) {
              final item = entry.value[index - currentIndex];


              if (item.isChat && item.chatData != null) {
                final chatId = item.chatData!.chatId.toString();
                if (!_messageKeys.containsKey(chatId)) {
                  _messageKeys[chatId] = GlobalKey();
                }
                // Check if message is in sentMessages
                final isSentMessage = state.sentMessages.any(
                  (msg) => msg.chatData?.chatId == item.chatData!.chatId,
                );
                debugPrint('isSentMessage: $isSentMessage');

                if (isSentMessage) {
                  // Sender message (You) - from state.sentMessages
                  return SenderMessageBubble(
                    key: _messageKeys[chatId],
                    chat: item.chatData!,
                    isHighlighted: item.chatData!.chatId.toString() == _highlightedChatId,
                    onReply: () {
                      context.read<TaskChatBloc>().add(
                        SetReplyTo(item.chatData!),
                      );
                      _focusNode.requestFocus();
                    },
                    navigateToReplyedMessage: () {
                      final replyId = item.chatData!.replyToId;
                      if (replyId != null && replyId != 0) {
                        _scrollToMessage(replyId.toString(), state);
                      }
                    },
                  );
                } else {
                  // Receiver message (Others) - from state.receivedMessages
                  return ReceiverMessageBubble(
                    key: _messageKeys[chatId],
                    chat: item.chatData!,
                    isHighlighted: item.chatData!.chatId.toString() == _highlightedChatId,
                    onReply: () {
                      context.read<TaskChatBloc>().add(
                        SetReplyTo(item.chatData!),
                      );
                      _focusNode.requestFocus();
                    },
                  );
                }
              } else if (item.isHistory && item.historyData != null) {
                return _buildHistoryItem(item.historyData!);
              }
            }
            currentIndex += entry.value.length;
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              context.read<TaskChatBloc>().add(const RefreshChat());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(TaskHistoryModel history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.history, size: 18, color: Colors.amber[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(history.statement, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  history.createdDate,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentionList() {
    final filteredMembers = _getFilteredTeamMembers();

    if (filteredMembers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  'Mention a team member',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    context.read<TaskChatBloc>().add(ClearMentions());
                    setState(() {
                      _showMentionList = false;
                      _mentionQuery = '';
                    });
                  },
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredMembers.length,
              itemBuilder: (context, index) {
                final member = filteredMembers[index];
                final initial = member.userName.isNotEmpty
                    ? member.userName[0].toUpperCase()
                    : '?';
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue[200],
                    child: Text(
                      initial,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  title: Text(
                    member.userName,
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    member.role,
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () => _onMentionSelected(member),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(ChatData replyTo) {
    return GestureDetector(
      onTap: () {
        final state = context.read<TaskChatBloc>().state;
        _scrollToMessage(replyTo.chatId.toString(), state);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          border: Border(top: BorderSide(color: Colors.blue[200]!)),
        ),
        child: Row(
          children: [
            Container(width: 3, height: 40, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Replying to ${replyTo.userName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    replyTo.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () {
                context.read<TaskChatBloc>().add(const ClearReplyTo());
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(TaskChatState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show selected attachments
        if (state.selectedAttachments.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.selectedAttachments.length} attachment(s)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.selectedAttachments.length,
                    itemBuilder: (context, index) {
                      final file = state.selectedAttachments[index];
                      final fileName = file.path.split('/').last;
                      final isImage =
                          fileName.toLowerCase().endsWith('.jpg') ||
                          fileName.toLowerCase().endsWith('.jpeg') ||
                          fileName.toLowerCase().endsWith('.png');

                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Stack(
                          children: [
                            if (isImage)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                ),
                              )
                            else
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.insert_drive_file,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Text(
                                        fileName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 9),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: InkWell(
                                onTap: () {
                                  context.read<TaskChatBloc>().add(
                                    RemoveAttachment(file),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        BlocBuilder<TaskChatBloc, TaskChatState>(
          builder: (context, state) {
            if (state.selectedMentions.isEmpty) {
              return const SizedBox();
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: state.selectedMentions.map((member) {
                  return Chip(
                    label: Text(member.userName),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      context.read<TaskChatBloc>().add(
                        RemoveMention(member.userId),
                      );
                    },
                  );
                }).toList(),
              ),
            );
          },
        ),

        // Message input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attachment button
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    AttachmentBottomSheet.show(
                      context,
                      onCameraPressed: () {
                        context.read<TaskChatBloc>().add(
                          const PickFromCamera(),
                        );
                      },
                      onGalleryPressed: () {
                        context.read<TaskChatBloc>().add(
                          const PickFromGallery(),
                        );
                      },
                      onDocumentsPressed: () {
                        context.read<TaskChatBloc>().add(const PickDocuments());
                      },
                    );
                  },
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.alternate_email, size: 20),
                          onPressed: () {
                            final cursorPos =
                                _messageController.selection.baseOffset;
                            if (cursorPos < 0) return;

                            final currentText = _messageController.text;
                            final newText =
                                currentText.substring(0, cursorPos) +
                                '@' +
                                currentText.substring(cursorPos);
                            _messageController.value = TextEditingValue(
                              text: newText,
                              selection: TextSelection.collapsed(
                                offset: cursorPos + 1,
                              ),
                            );
                            _focusNode.requestFocus();
                          },
                          tooltip: 'Mention someone',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                state.isSending
                    ? Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(12),
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => _sendMessage(state),
                          icon: const Icon(Icons.send, size: 20),
                          color: Colors.white,
                          padding: EdgeInsets.zero,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
