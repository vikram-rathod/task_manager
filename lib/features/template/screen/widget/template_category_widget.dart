import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/features/template/screen/widget/template_task_row.dart';

import '../../model/template_models.dart';

class TemplateCategoryWidget extends StatelessWidget {
  final TemplateCategory category;

  const TemplateCategoryWidget(
      {required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),

        Row(
          children: [
            Container(
              width: 5,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.purpleAccent,
                borderRadius:
                BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              category.categoryName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Column(
          children: category.tasks
              .map((t) =>
              TemplateTaskRow(task: t))
              .toList(),
        )
      ],
    );
  }
}
