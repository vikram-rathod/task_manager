import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/task_list_models.dart';
import 'category_widget.dart';

class MainItemCard extends StatefulWidget {
  final TaskItem item;
  final String projectId;

  const MainItemCard({super.key, required this.item,required this.projectId});

  @override
  State<MainItemCard> createState() => MainItemCardState();
}

class MainItemCardState extends State<MainItemCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withOpacity(0.3)),
        color: cs.surface,
      ),
      child: Column(
        children: [
          /// ---------------- MAIN HEADER ----------------
          InkWell(
            onTap: () {
              setState(() => expanded = !expanded);
            },
            child: Padding(
              padding: const
                    .all(16),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.itemName,
                      style:  TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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

          /// ---------------- CATEGORY + TASKS ----------------
          if (expanded)
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, bottom: 16),
              child: Column(
                children: widget.item.categories
                    .map((category) =>
                    CategoryWidget(category: category,projectId: widget.projectId))
                    .toList(),
              ),
            )
        ],
      ),
    );
  }
}

