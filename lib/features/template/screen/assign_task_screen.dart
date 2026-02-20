import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../template/bloc/template_bloc.dart';
import '../../template/bloc/template_event.dart';
import '../../template/bloc/template_state.dart';
import '../../template/model/template_models.dart';
import '../model/assign_task_request.dart';

class AssignTaskScreen extends StatefulWidget {
  final String projectName;
  final String tabId;
  final String projectId;

  const AssignTaskScreen({
    super.key,
    required this.projectName,
    required this.tabId,
    required this.projectId,
  });

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  /// templateId -> Set<taskId>
  final Map<int, Set<int>> selectedTasks = {};
  final Set<int> expandedTemplates = {};

  @override
  void initState() {
    super.initState();
    context.read<TemplateBloc>().add(LoadTemplates(tabId: widget.tabId));
  }

  bool get hasSelection => selectedTasks.isNotEmpty;

  int get totalSelectedTasks =>
      selectedTasks.values.fold(0, (sum, tasks) => sum + tasks.length);
  int get totalSelectedTemplates => selectedTasks.keys.length;

  void clearAll() => setState(() => selectedTasks.clear());

  // ── TEMPLATE ──────────────────────────────────────────────

  void toggleTemplate(TemplateItem template) {
    final templateId = template.itemId!;
    setState(() {
      if (isTemplateFullySelected(template)) {
        selectedTasks.remove(templateId);
      } else {
        final allTaskIds = <int>{};
        for (var cat in template.categories) {
          for (var task in cat.tasks) allTaskIds.add(task.taskId);
        }
        if (allTaskIds.isNotEmpty) selectedTasks[templateId] = allTaskIds;
      }
    });
  }

  bool isTemplateFullySelected(TemplateItem template) {
    final templateId = template.itemId!;
    if (!selectedTasks.containsKey(templateId)) return false;
    final total =
    template.categories.fold(0, (s, c) => s + c.tasks.length);
    return selectedTasks[templateId]!.length == total;
  }

  bool isTemplatePartiallySelected(TemplateItem template) {
    final templateId = template.itemId!;
    if (!selectedTasks.containsKey(templateId)) return false;
    final total =
    template.categories.fold(0, (s, c) => s + c.tasks.length);
    final count = selectedTasks[templateId]!.length;
    return count > 0 && count < total;
  }

  // ── CATEGORY ──────────────────────────────────────────────

  void toggleCategory(int templateId, TemplateCategory category) {
    setState(() {
      selectedTasks.putIfAbsent(templateId, () => {});

      if (isCategoryFullySelected(templateId, category)) {
        // Deselect all tasks in this category
        for (var task in category.tasks) {
          selectedTasks[templateId]!.remove(task.taskId);
        }
      } else {
        // Select all tasks in this category
        for (var task in category.tasks) {
          selectedTasks[templateId]!.add(task.taskId);
        }
      }

      if (selectedTasks[templateId]!.isEmpty) {
        selectedTasks.remove(templateId);
      }
    });
  }

  bool isCategoryFullySelected(int templateId, TemplateCategory category) {
    if (!selectedTasks.containsKey(templateId)) return false;
    return category.tasks
        .every((t) => selectedTasks[templateId]!.contains(t.taskId));
  }

  bool isCategoryPartiallySelected(int templateId, TemplateCategory category) {
    if (!selectedTasks.containsKey(templateId)) return false;
    final count = category.tasks
        .where((t) => selectedTasks[templateId]!.contains(t.taskId))
        .length;
    return count > 0 && count < category.tasks.length;
  }

  // ── TASK ──────────────────────────────────────────────────

  void toggleTask(int templateId, int taskId) {
    setState(() {
      selectedTasks.putIfAbsent(templateId, () => {});
      if (selectedTasks[templateId]!.contains(taskId)) {
        selectedTasks[templateId]!.remove(taskId);
      } else {
        selectedTasks[templateId]!.add(taskId);
      }
      if (selectedTasks[templateId]!.isEmpty) selectedTasks.remove(templateId);
    });
  }

  // ── BUILD ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocListener<TemplateBloc, TemplateState>(
      listener: (context, state) {
        if (state.assignSuccess == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? "Assigned Successfully"),
              backgroundColor: cs.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: cs.surfaceContainerLow,
        appBar: AppBar(
          backgroundColor: cs.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: cs.onSurface, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Assign Tasks",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: cs.onSurface),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: cs.outlineVariant),
          ),
        ),
        body: Column(
          children: [
            /// PROJECT BANNER
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.folder_open_rounded,
                        color: cs.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Project",
                            style: TextStyle(
                                fontSize: 11, color: cs.onSurfaceVariant)),
                        Text(
                          widget.projectName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasSelection)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$totalSelectedTemplates selected",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            /// LIST
            Expanded(
              child: BlocBuilder<TemplateBloc, TemplateState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return Center(
                        child: CircularProgressIndicator(color: cs.primary));
                  }
                  if (state.templates.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 64, color: cs.onSurfaceVariant),
                          const SizedBox(height: 12),
                          Text("No Templates Found",
                              style:
                              TextStyle(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: state.templates.length,
                    itemBuilder: (context, index) =>
                        _buildTemplateCard(state.templates[index], cs),
                  );
                },
              ),
            ),

            _buildBottomBar(cs),
          ],
        ),
      ),
    );
  }

  // ── TEMPLATE CARD ─────────────────────────────────────────

  Widget _buildTemplateCard(TemplateItem template, ColorScheme cs) {
    final templateId = template.itemId!;
    final expanded = expandedTemplates.contains(templateId);
    final isSelected = selectedTasks.containsKey(templateId);
    final isFull = isTemplateFullySelected(template);
    final isPartial = isTemplatePartiallySelected(template);

    final attachmentCount = template.categories
        .expand((c) => c.tasks)
        .fold<int>(0, (sum, t) => sum + t.files.length);
    final totalTasks =
    template.categories.fold(0, (s, c) => s + c.tasks.length);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? cs.primary : cs.outlineVariant,
          width: isSelected ? 0.4 : 0.2,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            /// Header row
            InkWell(
              onTap: () => setState(() => expanded
                  ? expandedTemplates.remove(templateId)
                  : expandedTemplates.add(templateId)),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.primaryContainer.withOpacity(0.25)
                      : cs.surface,
                ),
                child: Row(
                  children: [
                    /// Tristate checkbox for template
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: isFull ? true : (isPartial ? null : false),
                        tristate: true,
                        activeColor: cs.primary,
                        side: BorderSide(color: cs.outline, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        onChanged: (_) => toggleTemplate(template),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Container(
                      width: 4,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected ? cs.primary : cs.outlineVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.itemName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // show category meta badge
                              _metaBadge(
                                cs,
                                icon: Icons.category_rounded,
                                label: "${template.categories.length} category${template.categories.length > 1 ? 's' : ''}",
                                color: cs.secondary,
                                bg: cs.secondaryContainer,
                              ),
                              _metaBadge(cs,
                                  icon: Icons.task_alt_rounded,
                                  label: "$totalTasks tasks",
                                  color: cs.secondary,
                                  bg: cs.secondaryContainer),
                              if (attachmentCount > 0) ...[
                                const SizedBox(width: 6),
                                _metaBadge(cs,
                                    icon: Icons.attach_file_rounded,
                                    label: "$attachmentCount files",
                                    color: cs.tertiary,
                                    bg: cs.tertiaryContainer),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),

            /// Expanded categories
            if (expanded) ...[
              Divider(height: 1, color: cs.outlineVariant),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: template.categories
                      .map((cat) =>
                      _buildCategorySection(cat, templateId, cs))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── CATEGORY SECTION ──────────────────────────────────────

  Widget _buildCategorySection(
      TemplateCategory cat, int templateId, ColorScheme cs) {
    final isCatFull = isCategoryFullySelected(templateId, cat);
    final isCatPartial = isCategoryPartiallySelected(templateId, cat);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCatFull
              ? cs.secondary.withOpacity(0.2)
              : cs.outlineVariant.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Category header with tristate checkbox
          InkWell(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(14)),
            onTap: () => toggleCategory(templateId, cat),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isCatFull
                    ? cs.secondaryContainer.withOpacity(0.6)
                    : cs.secondaryContainer.withOpacity(0.3),
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  /// Tristate checkbox for category
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value:
                      isCatFull ? true : (isCatPartial ? null : false),
                      tristate: true,
                      activeColor: cs.secondary,
                      side:
                      BorderSide(color: cs.secondary, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      onChanged: (_) => toggleCategory(templateId, cat),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: cs.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      cat.categoryName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: cs.onSecondaryContainer,
                      ),
                    ),
                  ),

                  /// Selected count badge
                  Builder(builder: (_) {
                    final selected = cat.tasks
                        .where((t) =>
                    selectedTasks[templateId]
                        ?.contains(t.taskId) ??
                        false)
                        .length;
                    return Text(
                      selected > 0
                          ? "$selected / ${cat.tasks.length}"
                          : "${cat.tasks.length} tasks",
                      style: TextStyle(
                          fontSize: 11,
                          color: cs.secondary,
                          fontWeight: FontWeight.w600),
                    );
                  }),
                ],
              ),
            ),
          ),

          /// Tasks
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: cat.tasks
                  .map((task) => _buildTaskRow(task, templateId, cs))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── TASK ROW ──────────────────────────────────────────────

  Widget _buildTaskRow(
      TemplateTask task, int templateId, ColorScheme cs) {
    final selected =
        selectedTasks[templateId]?.contains(task.taskId) ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: selected ? cs.primaryContainer.withOpacity(0.3) : cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? cs.primary.withOpacity(0.2)
              : cs.outlineVariant.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => toggleTask(templateId, task.taskId),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: selected,
                  activeColor: cs.primary,
                  side: BorderSide(color: cs.outline, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  onChanged: (_) => toggleTask(templateId, task.taskId),
                ),
              ),
              const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.task_alt_rounded,
                    size: 14, color: cs.primary),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.taskName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    if (task.files.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.attach_file_rounded,
                              size: 12, color: cs.tertiary),
                          const SizedBox(width: 4),
                          Text(
                            "${task.files.length} attachment${task.files.length > 1 ? 's' : ''}",
                            style: TextStyle(
                                fontSize: 11,
                                color: cs.tertiary,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── BOTTOM BAR ────────────────────────────────────────────

  Widget _buildBottomBar(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant, width: 0.2)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: hasSelection ? clearAll : null,
              icon: const Icon(Icons.clear_rounded, size: 18),
              label: const Text("Clear"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: cs.outline),
                foregroundColor: cs.onSurface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: hasSelection ? _onAssign : null,
              icon: const Icon(Icons.assignment_turned_in_rounded, size: 18),
              label: Text(
                hasSelection
                    ? "Assign ($totalSelectedTemplates selected)"
                    : "Assign",
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                disabledBackgroundColor: cs.onSurface.withOpacity(0.12),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onAssign() {
    final state = context.read<TemplateBloc>().state;
    final selectedItems = <AssignItem>[];

    for (var template in state.templates) {
      final templateId = template.itemId!;
      if (!selectedTasks.containsKey(templateId)) continue;

      final selectedTaskIds = selectedTasks[templateId]!;
      final selectedCategories = <AssignCategory>[];

      for (var cat in template.categories) {
        final tasksForCategory = cat.tasks
            .where((t) => selectedTaskIds.contains(t.taskId))
            .map((t) => AssignTask(taskId: t.taskId, taskName: t.taskName))
            .toList();

        if (tasksForCategory.isNotEmpty) {
          selectedCategories.add(AssignCategory(
            categoryId: cat.categoryId,
            categoryName: cat.categoryName,
            tasks: tasksForCategory,
          ));
        }
      }

      if (selectedCategories.isNotEmpty) {
        selectedItems.add(AssignItem(
          itemId: template.itemId,
          itemName: template.itemName,
          categories: selectedCategories,
        ));
      }
    }

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one task")),
      );
      return;
    }

    context.read<TemplateBloc>().add(
      AssignTasks(
        request: AssignTaskRequest(
          projectId: widget.projectId,
          tabId: widget.tabId,
          data: selectedItems,
        ),
      ),
    );
  }

  Widget _metaBadge(
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
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}