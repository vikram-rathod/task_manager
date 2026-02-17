// lib/features/taskChat/ui/widgets/receiver_message_bubble.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:task_manager/features/taskChat/ui/screens/mention_text.dart';
import '../../../../core/models/taskchat/chat_data.dart';

class ReceiverMessageBubble extends StatelessWidget {
  final ChatData chat;
  final VoidCallback onReply;
  final bool isHighlighted;

  const ReceiverMessageBubble({
    super.key,
    required this.chat,
    required this.onReply,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(chat.chatId),
      endActionPane: ActionPane(
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
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: isHighlighted
            ? const Color(0xFF005C4B).withOpacity(0.25)
            : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // User avatar (left side)
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

              // Message bubble
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
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
                      // Sender name
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
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 12,
                          top: 4,
                          bottom: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Reply context if present
                            if (chat.replyToId != 0) ...[
                              _buildReplyContext(),
                              const SizedBox(height: 6),
                            ],

                            // Message text
                            MentionText(
                              text: chat.message,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.3,
                                color: Colors.black87,
                              ),
                              mentionStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0095DA), // Blue for mentions
                              ),
                            ),

                            // Document attachments
                            if (chat.documentUrls.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _buildAttachments(chat.documentUrls),
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
                                      color: const Color(0xFF005C4B)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.alternate_email,
                                          size: 10,
                                          color: Color(0xFF005C4B),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          user.userName,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF005C4B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],

                            // Time
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(chat.cdate),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplyContext() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF005C4B).withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: const Border(
          left: BorderSide(
            color: Color(0xFF005C4B),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.reply,
                size: 12,
                color: Color(0xFF005C4B),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  chat.replyUser,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF005C4B),
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
              color: Colors.black87.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachments(List<String> urls) {
    // Separate images and files
    final images = <String>[];
    final files = <String>[];

    for (final url in urls) {
      if (_isImage(url)) {
        images.add(url);
      } else {
        files.add(url);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display images
        if (images.isNotEmpty) _buildImageGrid(images),

        // Display files
        if (files.isNotEmpty && images.isNotEmpty)
          const SizedBox(height: 8),

        if (files.isNotEmpty)
          ...files.map((url) => _buildFileAttachment(url.split('/').last)),
      ],
    );
  }

  Widget _buildImageGrid(List<String> images) {
    if (images.length == 1) {
      // Single image - display larger
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          images[0],
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
          errorBuilder: (context, error, stackTrace) {
            return _buildFileAttachment(images[0].split('/').last);
          },
        ),
      );
    }

    // Multiple images - display in grid (2 columns)
    return Builder(
        builder: (context) {
          return Wrap(
            spacing: 4,
            runSpacing: 4,
            children: images.map((url) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: (MediaQuery.of(context).size.width * 0.75 - 32) / 2, // Divide by 2 for 2 columns
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: (MediaQuery.of(context).size.width * 0.75 - 32) / 2,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF005C4B).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.broken_image,
                            size: 24,
                            color: Color(0xFF005C4B),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Failed to load',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF005C4B),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        }
    );
  }

  bool _isImage(String url) {
    final fileName = url.toLowerCase();
    return fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.gif') ||
        fileName.endsWith('.webp');
  }

  Widget _buildFileAttachment(String fileName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF005C4B).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFileIcon(fileName),
            size: 16,
            color: const Color(0xFF005C4B),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              fileName,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
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