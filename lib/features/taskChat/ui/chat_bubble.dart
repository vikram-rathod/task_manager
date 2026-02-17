// lib/features/taskChat/ui/chat_bubble.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:task_manager/features/taskChat/ui/screens/mention_text.dart';
import '../../../../core/models/taskchat/chat_data.dart';

class ChatBubble extends StatelessWidget {
  final ChatData chat;
  final bool isMe;
  final VoidCallback onReply;
  final int? currentUserId;

  const ChatBubble({
    super.key,
    required this.chat,
    required this.isMe,
    required this.onReply,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(chat.chatId),
      endActionPane: !isMe
          ? ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => onReply(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.reply,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      )
          : null,
      startActionPane: isMe
          ? ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => onReply(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.reply,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Row(
          mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Receiver avatar (left side)
            if (!isMe) ...[
              CircleAvatar(
                radius: 14,
                backgroundImage: chat.userProfileUrl.isNotEmpty
                    ? NetworkImage(chat.userProfileUrl)
                    : null,
                backgroundColor: _getAvatarColor(chat.userName),
                child: chat.userProfileUrl.isEmpty
                    ? Text(
                  _getInitials(chat.userName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 6),
            ],

            // Message bubble
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF005C4B) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMe ? 12 : 0),
                    topRight: Radius.circular(isMe ? 0 : 12),
                    bottomLeft: const Radius.circular(12),
                    bottomRight: const Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sender name (only for received messages)
                    if (!isMe)
                      Container(
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 12,
                          top: 8,
                        ),
                        child: Text(
                          chat.userName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _getUserNameColor(chat.userName),
                          ),
                        ),
                      ),

                    Padding(
                      padding: EdgeInsets.only(
                        left: 12,
                        right: 12,
                        top: isMe ? 8 : 4,
                        bottom: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Reply context if present
                          if (chat.replyToId != 0) ...[
                            _buildReplyContext(context, chat, isMe),
                            const SizedBox(height: 6),
                          ],

                          // Message text
                          MentionText(
                            text: chat.message,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.3,
                              color: isMe ? Colors.white : Colors.black87,
                            ),
                            mentionStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isMe
                                  ? const Color(0xFF00D9FF)
                                  : const Color(0xFF0095DA),
                            ),
                          ),

                          // Document attachments
                          if (chat.documentUrls.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ...chat.documentUrls.map(
                                  (url) => _buildAttachment(context, url, isMe),
                            ),
                          ],

                          // Mentioned users chips
                          if (chat.mentionedUsers.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: chat.mentionedUsers.map((user) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (isMe
                                        ? Colors.white
                                        : const Color(0xFF005C4B))
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.alternate_email,
                                        size: 10,
                                        color: isMe
                                            ? Colors.white70
                                            : const Color(0xFF005C4B),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        user.userName,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isMe
                                              ? Colors.white70
                                              : const Color(0xFF005C4B),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],

                          // Time and status
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(chat.cdate),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isMe
                                      ? Colors.white60
                                      : Colors.black45,
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.done_all,
                                  size: 14,
                                  color: Colors.blue[200],
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Spacing for sender messages
            if (isMe) const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyContext(BuildContext context, ChatData chat, bool isMe) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (isMe ? Colors.white : const Color(0xFF005C4B))
            .withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.white70 : const Color(0xFF005C4B),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.reply,
                size: 12,
                color: isMe ? Colors.white70 : const Color(0xFF005C4B),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  chat.replyUser,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isMe ? Colors.white : const Color(0xFF005C4B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            chat.replyText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: (isMe ? Colors.white : Colors.black87).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachment(BuildContext context, String url, bool isMe) {
    final fileName = url.split('/').last;
    final isImage = fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png') ||
        fileName.toLowerCase().endsWith('.gif') ||
        fileName.toLowerCase().endsWith('.webp');

    if (isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildFileAttachment(fileName, isMe);
          },
        ),
      );
    }

    return _buildFileAttachment(fileName, isMe);
  }

  Widget _buildFileAttachment(String fileName, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color:
        (isMe ? Colors.white : const Color(0xFF005C4B)).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFileIcon(fileName),
            size: 16,
            color: isMe ? Colors.white70 : const Color(0xFF005C4B),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              fileName,
              style: TextStyle(
                fontSize: 12,
                color: isMe ? Colors.white : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatTime(String dateStr) {
    // Extract time from "24-12-2025 [06:04 pm]"
    final match = RegExp(r'\[(.+?)\]').firstMatch(dateStr);
    if (match != null) {
      return match.group(1) ?? dateStr;
    }
    return dateStr;
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF6B4CE6),
      const Color(0xFFE646B6),
      const Color(0xFF46E6B8),
      const Color(0xFFE6B446),
      const Color(0xFF46B8E6),
      const Color(0xFFB846E6),
      const Color(0xFF46E667),
      const Color(0xFFE67346),
    ];
    final hash = name.codeUnits.fold(0, (sum, code) => sum + code);
    return colors[hash % colors.length];
  }

  Color _getUserNameColor(String name) {
    final colors = [
      const Color(0xFF0095DA),
      const Color(0xFFD90095),
      const Color(0xFF00D995),
      const Color(0xFFD99500),
      const Color(0xFF9500D9),
      const Color(0xFF00D900),
      const Color(0xFFD90000),
    ];
    final hash = name.codeUnits.fold(0, (sum, code) => sum + code);
    return colors[hash % colors.length];
  }
}