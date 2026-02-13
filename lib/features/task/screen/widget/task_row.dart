import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/task_list_bloc.dart';
import '../../bloc/task_list_event.dart';
import '../../model/task_list_models.dart';

class TaskRow extends StatefulWidget {
  final TaskData task;
  final String projectId;

  const TaskRow({
    super.key,
    required this.task,
    required this.projectId,
  });

  @override
  State<TaskRow> createState() => TaskRowState();
}

class TaskRowState extends State<TaskRow> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final cs = Theme.of(context).colorScheme;


    final hasDetails =
        widget.task.transferStatus &&
            widget.task.taskDetails != null;

    return Column(
      children: [
        /// ---------------- TASK HEADER ----------------
        InkWell(
          onTap: hasDetails
              ? () {
            setState(() => expanded = !expanded);
          }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                /// ICON
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    size: 18,
                    color: primary,
                  ),
                ),
                const SizedBox(width: 12),

                /// TASK NAME
                Expanded(
                  child: Text(
                    widget.task.taskName,
                    style: TextStyle(fontSize: 14,color: cs.outline ),
                  ),
                ),

                /// STATUS / TRANSFER ICON
                if (widget.task.transferStatus)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 18,
                      color: Colors.purpleAccent,
                    ),
                  )
                else
                  InkWell(
                    onTap: () {
                      context.read<TaskListBloc>().add(
                        TransferTaskRequested(
                          taskId:
                          widget.task.taskId.toString(),
                          projectId: widget.projectId,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: primary,
                      ),
                    ),
                  ),

                /// SHOW ARROW ONLY IF DETAILS EXIST
                if (hasDetails) ...[
                  const SizedBox(width: 8),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: primary,
                  ),
                ]
              ],
            ),
          ),
        ),

        /// ---------------- EXPANDED DETAILS ----------------
        if (expanded && hasDetails)
          Padding(
            padding:
            const EdgeInsets.only(left: 50, bottom: 16),
            child: Column(
              children: [
                _infoCard(
                  "Maker",
                  widget.task.taskDetails?.makerName?.isNotEmpty == true
                      ? widget.task.taskDetails!.makerName!
                      : "-",
                ),
                const SizedBox(height: 10),
                _infoCard(
                  "Checker",
                  widget.task.taskDetails?.checkerName?.isNotEmpty == true
                      ? widget.task.taskDetails!.checkerName!
                      : "-",
                ),
                const SizedBox(height: 10),
                _infoCard(
                  "PC Engineer",
                  widget.task.taskDetails?.pcEngrName?.isNotEmpty == true
                      ? widget.task.taskDetails!.pcEngrName!
                      : "-",
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

