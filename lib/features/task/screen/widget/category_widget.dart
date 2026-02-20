import 'package:flutter/material.dart';
import '../../model/task_list_models.dart';
import 'task_row.dart';

class CategoryWidget extends StatefulWidget {
  final TaskCategory category;
  final String projectId;

  const CategoryWidget({
    super.key,
    required this.category,
    required this.projectId,
  });

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  bool expanded = true; // open by default

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final totalTasks = widget.category.tasks.length;
    final doneTasks =
        widget.category.tasks.where((t) => t.transferStatus).length;
    final allDone = doneTasks == totalTasks && totalTasks > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: allDone
              ? cs.primary.withOpacity(0.3)
              : cs.outlineVariant.withOpacity(0.5),
          width: 0.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// CATEGORY HEADER
          InkWell(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(14)),
            onTap: () => setState(() => expanded = !expanded),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: allDone
                    ? cs.secondaryContainer.withOpacity(0.6)
                    : cs.secondaryContainer.withOpacity(0.3),
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  /// Accent bar
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: cs.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 10),

                  /// Category name
                  Expanded(
                    child: Text(
                      widget.category.categoryName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: cs.onSecondaryContainer,
                      ),
                    ),
                  ),

                  /// Done badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: allDone
                          ? cs.primaryContainer
                          : cs.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "$doneTasks/$totalTasks",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: allDone ? cs.primary : cs.secondary,
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  /// Expand arrow
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),

          /// TASKS
          if (expanded)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: widget.category.tasks
                    .map((task) => TaskRow(
                  task: task,
                  projectId: widget.projectId,
                ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}