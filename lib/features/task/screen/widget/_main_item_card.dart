import 'package:flutter/material.dart';
import '../../model/task_list_models.dart';
import 'category_widget.dart';

class MainItemCard extends StatefulWidget {
  final TaskItem item;
  final String projectId;

  const MainItemCard({super.key, required this.item, required this.projectId});

  @override
  State<MainItemCard> createState() => MainItemCardState();
}

class MainItemCardState extends State<MainItemCard>
    with SingleTickerProviderStateMixin {
  bool expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => expanded = !expanded);
    expanded ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final totalTasks =
    widget.item.categories.fold(0, (s, c) => s + c.tasks.length);
    final transferredTasks = widget.item.categories
        .expand((c) => c.tasks)
        .where((t) => t.transferStatus)
        .length;
    final allDone = transferredTasks == totalTasks && totalTasks > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant, width: 0.2),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            /// HEADER
            InkWell(
              onTap: _toggleExpand,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: expanded
                      ? cs.primaryContainer.withOpacity(0.2)
                      : cs.surface,
                ),
                child: Row(
                  children: [
                    /// Accent bar
                    Container(
                      width: 5,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 12),

                    /// Item name + meta badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.itemName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              _badge(
                                cs,
                                icon: Icons.category_rounded,
                                label:
                                "${widget.item.categories.length} categories",
                                color: cs.secondary,
                                bg: cs.secondaryContainer,
                              ),
                              const SizedBox(width: 6),
                              _badge(
                                cs,
                                icon: Icons.task_alt_rounded,
                                label: "$transferredTasks/$totalTasks Assigned",
                                color: allDone ? cs.primary : cs.tertiary,
                                bg: allDone
                                    ? cs.primaryContainer
                                    : cs.tertiaryContainer,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// Expand arrow
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          color: cs.primary),
                    ),
                  ],
                ),
              ),
            ),

            /// EXPANDED CONTENT
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                children: [
                  Divider(height: 1, color: cs.outlineVariant.withOpacity(0.4),),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                    child: Column(
                      children: widget.item.categories
                          .map((category) => CategoryWidget(
                        category: category,
                        projectId: widget.projectId,
                      ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(
      ColorScheme cs, {
        required IconData icon,
        required String label,
        required Color color,
        required Color bg,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}