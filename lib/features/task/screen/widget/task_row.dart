import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/task_list_bloc.dart';
import '../../bloc/task_list_event.dart';
import '../../model/task_list_models.dart';

class TaskRow extends StatefulWidget {
  final TaskData task;
  final String projectId;

  const TaskRow({super.key, required this.task, required this.projectId});

  @override
  State<TaskRow> createState() => TaskRowState();
}

class TaskRowState extends State<TaskRow> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasDetails =
        widget.task.transferStatus && widget.task.taskDetails != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.task.transferStatus
            ? cs.primaryContainer.withOpacity(0.2)
            : cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.task.transferStatus
              ? cs.primary.withOpacity(0.3)
              : cs.outlineVariant.withOpacity(0.4),
          width: 0.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap:
        hasDetails ? () => setState(() => expanded = !expanded) : null,
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              /// TASK HEADER ROW
              Row(
                children: [
                  /// Task icon
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.description_outlined,
                        size: 16, color: cs.primary),
                  ),
                  const SizedBox(width: 10),

                  /// Task name
                  Expanded(
                    child: Text(
                      widget.task.taskName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  /// Transfer or Done pill
                  if (widget.task.transferStatus)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 13, color: cs.primary),
                          const SizedBox(width: 4),
                          Text(
                            "Done",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        context.read<TaskListBloc>().add(
                          TransferTaskRequested(
                            taskId: widget.task.taskId.toString(),
                            projectId: widget.projectId,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: cs.tertiaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_forward_rounded,
                                size: 13, color: cs.tertiary),
                            const SizedBox(width: 4),
                            Text(
                              "Transfer",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: cs.tertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  /// Expand arrow
                  if (hasDetails) ...[
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          size: 20, color: cs.onSurfaceVariant),
                    ),
                  ],
                ],
              ),

              /// EXPANDED DETAILS
              if (expanded && hasDetails) ...[
                const SizedBox(height: 10),
                Divider(height: 1, color: cs.outlineVariant),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _infoChip(
                        cs,
                        icon: Icons.build_rounded,
                        label: "Maker",
                        value: widget.task.taskDetails?.makerName
                            ?.isNotEmpty ==
                            true
                            ? widget.task.taskDetails!.makerName!
                            : "-",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _infoChip(
                        cs,
                        icon: Icons.verified_rounded,
                        label: "Checker",
                        value: widget.task.taskDetails?.checkerName
                            ?.isNotEmpty ==
                            true
                            ? widget.task.taskDetails!.checkerName!
                            : "-",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _infoChip(
                  cs,
                  icon: Icons.engineering_rounded,
                  label: "Planner/Coordinator",
                  value: widget.task.taskDetails?.pcEngrName?.isNotEmpty ==
                      true
                      ? widget.task.taskDetails!.pcEngrName!
                      : "-",
                  fullWidth: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(
      ColorScheme cs, {
        required IconData icon,
        required String label,
        required String value,
        bool fullWidth = false,
      }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4), width: 0.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 13, color: cs.secondary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 10,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}