import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/template/screen/widget/template_category_widget.dart';

import '../../../../core/di/injection_container.dart';
import '../../bloc/template_bloc.dart';
import '../../bloc/template_event.dart';
import '../../model/template_models.dart';
import 'approval_bottom_sheet.dart';

class TemplateItemCard extends StatefulWidget {
  final TemplateItem item;

  const TemplateItemCard({super.key, required this.item});

  @override
  State<TemplateItemCard> createState() => _TemplateItemCardState();
}

class _TemplateItemCardState extends State<TemplateItemCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme
        .of(context)
        .primaryColor;
    final cs = Theme
        .of(context)
        .colorScheme;

    final isPending = widget.item.statusName == "Pending";
    final isApproved = widget.item.statusName == "Approved";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary),
      ),
      child: Column(
        children: [

          /// ---------------- HEADER ----------------
          InkWell(
            onTap: () {
              setState(() => expanded = !expanded);
            },
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 35,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      widget.item.itemName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:cs.outline
                      ),
                    ),
                  ),

                  /// STATUS TEXT (Clickable if Pending)
                  GestureDetector(
                    onTap: isPending
                        ? () {
                      print("🔥 Pending clicked");
                      _openAuthorityBottomSheet(context);
                    }
                        : null,
                    child: Text(
                      widget.item.statusName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isApproved
                            ? cs.primary
                            : Colors.lightBlueAccent,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: cs.primary,
                  ),
                ],
              ),
            ),
          ),

          /// ---------------- EXPANDED CONTENT ----------------
          if (expanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: widget.item.categories.map((cat) {
                  return _buildCategory(cat);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategory(TemplateCategory category) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        Row(
          children: [
            Container(
              width: 6,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.purpleAccent.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              category.categoryName,
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15,color:cs.outline.withOpacity(0.8) ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ...category.tasks.map((task) {
          return _buildTask(task);
        }).toList(),
      ],
    );
  }

  Widget _buildTask(TemplateTask task) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 30, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.description, size: 18,color: cs.primary,),
              ),
              const SizedBox(width: 10),
              Text(task.taskName,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),

          /// Attachments
          if (task.files.isNotEmpty) ...[
            const SizedBox(height: 12),

            /// Attachment Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.outline.withOpacity(0.05),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Title
                  Text(
                    "Attachments (${task.files.length})",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: cs.outline,
                    ),
                  ),

                  const SizedBox(height: 14),

                  ...task.files.map((file) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [

                          /// File Icon Box
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.attach_file,
                              color:cs.primary ,
                            ),
                          ),

                          const SizedBox(width: 14),

                          /// File Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:  [
                                Text(
                                  "File Name",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: cs.outline
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Size: 2.5 MB",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:  Theme.of(context).colorScheme.outline.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// Download Button
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color:  Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cloud_download,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  void _openAuthorityBottomSheet(BuildContext context) {

    final templateBloc = context.read<TemplateBloc>();
    

    templateBloc.add(
      FetchAuthorities(moduleId: "33"),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor:Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return BlocProvider.value(
          value: templateBloc,
          child: ApprovalBottomSheet(
            templateId: widget.item.itemId.toString(),
          ),
        );
      },
    );
  }

}

