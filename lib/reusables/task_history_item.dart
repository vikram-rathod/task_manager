import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskHistoryItem extends StatelessWidget {
  final String statement;
  final String createdDate;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool isFirst;
  final bool isLast;

  const TaskHistoryItem({
    super.key,
    required this.statement,
    required this.createdDate,
    this.onTap,
    this.showChevron = true,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(12) : Radius.zero,
        bottom: isLast ? const Radius.circular(12) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getActivityColor(statement).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getActivityIcon(statement),
                size: 18,
                color: _getActivityColor(statement),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statement,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(createdDate),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right,
                size: 18,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return difference.inMinutes <= 1
              ? 'Just now'
              : '${difference.inMinutes} mins ago';
        }
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM d, y').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  IconData _getActivityIcon(String statement) {
    final lowerStatement = statement.toLowerCase();

    if (lowerStatement.contains('created') ||
        lowerStatement.contains('added')) {
      return Icons.add_circle_outline;
    } else if (lowerStatement.contains('completed') ||
        lowerStatement.contains('finished')) {
      return Icons.check_circle_outline;
    } else if (lowerStatement.contains('updated') ||
        lowerStatement.contains('modified')) {
      return Icons.edit_outlined;
    } else if (lowerStatement.contains('deleted') ||
        lowerStatement.contains('removed')) {
      return Icons.delete_outline;
    } else if (lowerStatement.contains('assigned')) {
      return Icons.person_add_outlined;
    } else if (lowerStatement.contains('commented')) {
      return Icons.comment_outlined;
    }

    return Icons.history;
  }

  Color _getActivityColor(String statement) {
    final lowerStatement = statement.toLowerCase();

    if (lowerStatement.contains('created') ||
        lowerStatement.contains('added')) {
      return Colors.blue.shade600;
    } else if (lowerStatement.contains('completed') ||
        lowerStatement.contains('finished')) {
      return Colors.green.shade600;
    } else if (lowerStatement.contains('updated') ||
        lowerStatement.contains('modified')) {
      return Colors.orange.shade600;
    } else if (lowerStatement.contains('deleted') ||
        lowerStatement.contains('removed')) {
      return Colors.red.shade600;
    } else if (lowerStatement.contains('assigned')) {
      return Colors.purple.shade600;
    } else if (lowerStatement.contains('commented')) {
      return Colors.teal.shade600;
    }

    return Colors.grey.shade600;
  }
}