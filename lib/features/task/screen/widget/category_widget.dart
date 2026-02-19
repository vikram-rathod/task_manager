import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/features/task/screen/widget/task_row.dart';

import '../../model/task_list_models.dart';

class CategoryWidget extends StatefulWidget {
  final TaskCategory category;
  final String projectId;

  const CategoryWidget({super.key, required this.category, required this.projectId});

  @override
  State<CategoryWidget> createState() =>
      CategoryWidgetState();
}

class CategoryWidgetState extends State<CategoryWidget> {
  bool expanded = true;

  @override
  Widget build(BuildContext context) {
    final purple = Colors.purpleAccent;
    final primary = Theme.of(context).primaryColor;
    final cs = Theme.of(context).colorScheme;


    return Column(
      children: [
        /// CATEGORY HEADER
        InkWell(
          onTap: () {
            setState(() => expanded = !expanded);
          },
          child: Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius:
                    BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.category.categoryName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: cs.outline
                    ),
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: primary,
                )
              ],
            ),
          ),
        ),

        /// TASKS
        if (expanded)
          Column(
            children: widget.category.tasks
                .map((task) =>
                TaskRow(task: task, projectId: widget.projectId))
                .toList(),
          )
      ],
    );
  }
}
