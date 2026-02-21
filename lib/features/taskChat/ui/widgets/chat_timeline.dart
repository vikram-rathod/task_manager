import 'package:flutter/material.dart';

import '../../../../core/models/taskchat/chat_data.dart';
import '../../../../reusables/date_header.dart';
import '../../../home/model/task_history_model.dart';
import '../../bloc/task_chat_bloc.dart';
import '../receiver_message_bubble.dart';
import '../sender_message_bubble.dart';

class ChatTimeline extends StatelessWidget {
  final TaskChatState state;
  final ScrollController scrollController;
  final Map<String, GlobalKey> messageKeys;
  final String? highlightedChatId;
  final void Function(String chatId) onReplyScrollRequest;
  final void Function(ChatData chat) onReply;
  final VoidCallback onRefresh;

  const ChatTimeline({
    super.key,
    required this.state,
    required this.scrollController,
    required this.messageKeys,
    required this.highlightedChatId,
    required this.onReplyScrollRequest,
    required this.onReply,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.timeline.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && state.timeline.isEmpty) {
      return _ErrorView(
        message: state.errorMessage ?? 'Failed to load chat',
        onRetry: onRefresh,
      );
    }

    if (state.timeline.isEmpty) {
      return _EmptyView();
    }

    final grouped = _groupMessagesByDate(state.timeline);

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: grouped.entries.fold(
          0,
          (sum, e) => sum! + e.value.length + 1,
        ),
        itemBuilder: (context, index) {
          int cursor = 0;
          for (final entry in grouped.entries) {
            if (index == cursor) return DateHeader(date: entry.key);
            cursor++;
            if (index < cursor + entry.value.length) {
              final item = entry.value[index - cursor];
              return _buildTimelineItem(context, item, state);
            }
            cursor += entry.value.length;
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    dynamic item,
    TaskChatState state,
  ) {
    if (item.isChat && item.chatData != null) {
      final chat = item.chatData as ChatData;
      final chatId = chat.chatId.toString();
      messageKeys.putIfAbsent(chatId, () => GlobalKey());

      final isSent = state.sentMessages.any(
        (m) => m.chatData?.chatId == chat.chatId,
      );

      if (isSent) {
        return SenderMessageBubble(
          key: messageKeys[chatId],
          chat: chat,
          isHighlighted: chatId == highlightedChatId,
          onReply: () => onReply(chat),
          navigateToReplyedMessage: () {
            final replyId = chat.replyToId;
            if (replyId != null && replyId != 0) {
              onReplyScrollRequest(replyId.toString());
            }
          },
        );
      } else {
        return ReceiverMessageBubble(
          key: messageKeys[chatId],
          chat: chat,
          isHighlighted: chatId == highlightedChatId,
          onReply: () => onReply(chat),
        );
      }
    }

    if (item.isHistory && item.historyData != null) {
      return _HistoryItem(history: item.historyData!);
    }

    return const SizedBox.shrink();
  }

  Map<DateTime, List<dynamic>> _groupMessagesByDate(List<dynamic> timeline) {
    final grouped = <DateTime, List<dynamic>>{};
    for (final item in timeline) {
      DateTime date;
      if (item.isChat && item.chatData != null) {
        date = _parseDate(item.chatData!.cdate);
      } else if (item.isHistory && item.historyData != null) {
        date = _parseDate(item.historyData!.createdDate);
      } else {
        continue;
      }
      final key = DateTime(date.year, date.month, date.day);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split(' ');
      if (parts.isNotEmpty) {
        final d = parts[0].split('-');
        if (d.length == 3) {
          return DateTime(int.parse(d[2]), int.parse(d[1]), int.parse(d[0]));
        }
      }
    } catch (_) {}
    return DateTime.now();
  }
}

// ─── History Item ──────────────────────────────────────────────────────────────

class _HistoryItem extends StatelessWidget {
  final TaskHistoryModel history;

  const _HistoryItem({required this.history});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline, width: 0.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.history, size: 18, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.statement,
                  style: TextStyle(fontSize: 13, color: colorScheme.secondary),
                ),
                const SizedBox(height: 4),
                Text(
                  history.createdDate,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.primary,
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
}

// ─── Empty View ────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}

// ─── Error View ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
