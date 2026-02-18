import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'task_history_item.dart';

/// Generic model for task history
/// This can be used to map your different history models
class TaskHistoryData {
  final String statement;
  final String createdDate;
  final int? taskId;

  TaskHistoryData({
    required this.statement,
    required this.createdDate,
    this.taskId,
  });
}

/// Reusable Task History List Widget
/// Can be used in Home screen, Task Details, or any other screen
class TaskHistoryList extends StatelessWidget {
  final List<TaskHistoryData> historyItems;
  final bool isLoading;
  final bool showViewAll;
  final VoidCallback? onViewAllTap;
  final Function(TaskHistoryData)? onItemTap;
  final int? maxItems;
  final String title;
  final String emptyMessage;

  const TaskHistoryList({
    super.key,
    required this.historyItems,
    this.isLoading = false,
    this.showViewAll = false,
    this.onViewAllTap,
    this.onItemTap,
    this.maxItems,
    this.title = 'Recent Activity',
    this.emptyMessage = 'No recent activity',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final displayItems = maxItems != null
        ? historyItems.take(maxItems!).toList()
        : historyItems;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // View all button
                if (showViewAll && historyItems.isNotEmpty && !isLoading)
                  TextButton(
                    onPressed: onViewAllTap,
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
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Content
          if (isLoading)
            _buildLoadingState(context)
          else if (historyItems.isEmpty)
            _buildEmptyState(scheme)
          else
            _buildHistoryList(scheme, displayItems),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.onSurfaceVariant.withOpacity(0.2),
          width: 1.2,
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: scheme.onSurfaceVariant.withOpacity(0.2),
          ),
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                // Icon placeholder
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                // Text placeholders
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 100,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme scheme) {
    return Container(
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
              emptyMessage,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(ColorScheme scheme, List<TaskHistoryData> items) {
    return Container(
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
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: scheme.onSurfaceVariant.withOpacity(0.2),
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final isFirst = index == 0;
          final isLast = index == items.length - 1;

          return TaskHistoryItem(
            statement: item.statement,
            createdDate: item.createdDate,
            onTap: onItemTap != null ? () => onItemTap!(item) : null,
            showChevron: onItemTap != null,
            isFirst: isFirst,
            isLast: isLast,
          );
        },
      ),
    );
  }
}