import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';

class TaskHistorySection extends StatelessWidget {
  const TaskHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (p, c) =>
          p.isTaskHistoryLoading != c.isTaskHistoryLoading ||
          p.taskHistory != c.taskHistory,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    // Icon + Title
                    Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "Recent Activity",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // View all (only if data exists)
                    if (state.taskHistory.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          // navigate to full history page
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "View all",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              if (state.isTaskHistoryLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.taskHistory.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: scheme.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: scheme.onSurfaceVariant.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "No recent activity",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: scheme.onSurfaceVariant.withOpacity(0.2),
                      width: 1.2,
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.taskHistory.length.clamp(0, 5),
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: scheme.onSurfaceVariant.withOpacity(0.2),
                    ),
                    itemBuilder: (context, index) {
                      final item = state.taskHistory[index];
                      final isFirst = index == 0;
                      final isLast =
                          index == state.taskHistory.length - 1 || index == 4;

                      return InkWell(
                        onTap: () {
                          // Navigate to task details
                        },
                        borderRadius: BorderRadius.vertical(
                          top: isFirst
                              ? const Radius.circular(12)
                              : Radius.zero,
                          bottom: isLast
                              ? const Radius.circular(12)
                              : Radius.zero,
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
                                  color: _getActivityColor(
                                    item.statement,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getActivityIcon(item.statement),
                                  size: 18,
                                  color: _getActivityColor(item.statement),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.statement,
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
                                          _formatDate(item.createdDate),
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
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
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
