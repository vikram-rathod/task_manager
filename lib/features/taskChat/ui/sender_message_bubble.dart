import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:task_manager/features/taskChat/ui/screens/mention_text.dart';
import '../../../../core/models/taskchat/chat_data.dart';
import '../../../core/utils/file_preview_screen.dart';

class SenderMessageBubble extends StatelessWidget {
  final bool isHighlighted;
  final ChatData chat;
  final VoidCallback onReply;
  final VoidCallback navigateToReplyedMessage;

  const SenderMessageBubble({
    super.key,
    required this.chat,
    required this.onReply,
    this.isHighlighted = false,
    required this.navigateToReplyedMessage,

  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(chat.chatId),
      startActionPane: ActionPane(
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
            ? Colors.yellow.withOpacity(0.25)
            : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Message bubble
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? const Color(0xFF005C4B).withOpacity(0.6)
                        : const Color(0xFF005C4B),
        
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(0),
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
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
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
                            color: Colors.white,
                          ),
                          mentionStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00D9FF), // Cyan for mentions
                          ),
                        ),
        
                        // Document attachments
                        if (chat.documentUrls.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildAttachments(chat.documentUrls,context),
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
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.alternate_email,
                                      size: 10,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      user.userName,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _formatTime(chat.cdate),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white60,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.done_all,
                              size: 14,
                              color: Colors.blue[200],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplyContext() {
    return InkWell(
      onTap: () {
        navigateToReplyedMessage();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: const Border(
            left: BorderSide(
              color: Colors.white70,
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
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    chat.replyUser,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachments(List<String> urls,BuildContext context) {
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
        if (images.isNotEmpty) _buildImageGrid(images,context),

        // Display files
        if (files.isNotEmpty && images.isNotEmpty)
          const SizedBox(height: 8),

        if (files.isNotEmpty)
          ...files.map((url) => _buildFileAttachment(url, context)),
      ],
    );
  }

  Widget _buildImageGrid(List<String> images,BuildContext context) {
    if (images.length == 1) {
      // Single image - display larger
      return InkWell(
        onTap: () {
          _openPreview(context, images[0]);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            images[0],
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
            errorBuilder: (_, __, ___) =>
                _buildFileAttachment(images[0], context),
          ),
        ),
      );
    }

    // Multiple images - display in grid (2 columns)
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: images.map((url) {
        return InkWell(
          onTap: () {
            _openPreview(context, url);
          },
          child: ClipRRect(
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
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 24,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Failed to load',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }).toList(),
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

  Widget _buildFileAttachment(String url, BuildContext context) {
    final fileName = url.split('/').last;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openPreview(context, url),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(_getFileIcon(fileName), size: 16, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fileName,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.open_in_new, size: 12, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _openPreview(BuildContext context, String url) {
    final fileName = url.split('/').last;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilePreviewScreen(
          fileUrl: url,
          fileName: fileName,
        ),
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
}