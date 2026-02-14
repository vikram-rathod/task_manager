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
    required this.projectId
  });

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {

  /// templateId -> Set<taskId>
  final Map<int, Set<int>> selectedTasks = {};

  /// template expand control
  final Set<int> expandedTemplates = {};

  @override
  void initState() {
    super.initState();
    context.read<TemplateBloc>().add(
      LoadTemplates(tabId: widget.tabId),
    );
  }

  bool get hasSelection => selectedTasks.isNotEmpty;

  int get totalSelectedTasks {
    int count = 0;
    for (var tasks in selectedTasks.values) {
      count += tasks.length;
    }
    return count;
  }

  void clearAll() {
    setState(() {
      selectedTasks.clear();
    });
  }

  // =========================================================
  // TEMPLATE TOGGLE
  // =========================================================

  void toggleTemplate(TemplateItem template) {
    final templateId = template.itemId!;

    setState(() {
      if (selectedTasks.containsKey(templateId)) {
        selectedTasks.remove(templateId);
      } else {
        final allTaskIds = <int>{};

        for (var cat in template.categories) {
          for (var task in cat.tasks) {
            allTaskIds.add(task.taskId);
          }
        }

        if (allTaskIds.isNotEmpty) {
          selectedTasks[templateId] = allTaskIds;
        }
      }
    });
  }


  // =========================================================
  // TASK TOGGLE
  // =========================================================

  void toggleTask(int templateId, int taskId) {
    setState(() {
      selectedTasks.putIfAbsent(templateId, () => {});

      if (selectedTasks[templateId]!.contains(taskId)) {
        selectedTasks[templateId]!.remove(taskId);
      } else {
        selectedTasks[templateId]!.add(taskId);
      }

      if (selectedTasks[templateId]!.isEmpty) {
        selectedTasks.remove(templateId);
      }
    });
  }


  bool isTemplateFullySelected(TemplateItem template) {
    final templateId = template.itemId!;
    if (!selectedTasks.containsKey(templateId)) return false;

    int totalTasks = 0;
    for (var cat in template.categories) {
      totalTasks += cat.tasks.length;
    }

    return selectedTasks[templateId]!.length == totalTasks;
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return BlocListener<TemplateBloc, TemplateState>(
        listener: (context, state) {
          if (state.assignSuccess == true) {

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? "Assigned Successfully")),
            );

            Navigator.pop(context); // go back
          }
        },
     child:  Scaffold(
      appBar: AppBar(
        title: const Text("Assign Tasks"),
      ),
      body: Column(
        children: [

          /// PROJECT HEADER
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                 Text("Project: ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,color: Theme.of(context).colorScheme.outline)),
                Expanded(
                  child: Text(
                    widget.projectName,
                    style:  TextStyle(fontSize: 15,color:Theme.of(context).colorScheme.primary),
                  ),
                )
              ],
            ),
          ),

          /// LIST
          Expanded(
            child: BlocBuilder<TemplateBloc, TemplateState>(
              builder: (context, state) {

                if (state.isLoading) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (state.templates.isEmpty) {
                  return const Center(
                      child: Text("No Templates Found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.templates.length,
                  itemBuilder: (context, index) {
                    final template = state.templates[index];
                    return _buildTemplateCard(template);
                  },
                );
              },
            ),
          ),

          _buildBottomButtons(primary),
        ],
      ),
    ),
    );
  }

  // =========================================================
  // TEMPLATE CARD
  // =========================================================

  Widget _buildTemplateCard(TemplateItem template) {

    final templateId = template.itemId!;
    final expanded = expandedTemplates.contains(templateId);

    final hasAttachments = template.categories.any(
          (c) => c.tasks.any((t) => t.files.isNotEmpty),
    );

    final attachmentCount = template.categories
        .expand((c) => c.tasks)
        .fold<int>(0, (sum, t) => sum + t.files.length);

    final templateSelected =
    selectedTasks.containsKey(templateId);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: templateSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        children: [

          /// HEADER
          InkWell(
            onTap: () {
              setState(() {
                if (expanded) {
                  expandedTemplates.remove(templateId);
                } else {
                  expandedTemplates.add(templateId);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Row(
                children: [

                  Checkbox(
                    value: templateSelected,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (_) => toggleTemplate(template),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.itemName,
                          style:  TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.outline
                          ),
                        ),
                        if (hasAttachments)
                          Padding(
                            padding:
                            const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                 Icon(
                                    Icons.attach_file,
                                    size: 14,
                                    color:
                                    Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  "$attachmentCount attachments",
                                  style:
                                   TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.primary),
                                )
                              ],
                            ),
                          )
                      ],
                    ),
                  ),

                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  )
                ],
              ),
            ),
          ),

          /// EXPANDED CONTENT
          if (expanded)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: template.categories.map((cat) {

                  return Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 10),

                      Text(
                        cat.categoryName,
                        style:  TextStyle(
                            fontWeight: FontWeight.w600,color: Theme.of(context).colorScheme.outline),
                      ),

                      const SizedBox(height: 10),

                      ...cat.tasks.map((task) {

                        final selected =
                            selectedTasks[templateId]
                                ?.contains(task.taskId) ??
                                false;

                        final totalSize = task.files
                            .fold<double>(
                            0,
                                (sum, f) =>
                            sum +
                                (25.5 ??
                                    0));

                        return Container(
                          margin:
                          const EdgeInsets.only(
                              bottom: 5),
                          padding:
                          const EdgeInsets.all(
                              5),
                          decoration:
                          BoxDecoration(
                            color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                            borderRadius:
                            BorderRadius
                                .circular(14),
                          ),
                          child: Row(
                            children: [

                              Checkbox(
                                value: selected,
                                activeColor:
                                Theme.of(context).colorScheme.primary,
                                onChanged: (_) =>
                                    toggleTask(
                                        templateId,
                                        task.taskId),
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [

                                    Text(
                                      task.taskName,
                                      style:  TextStyle(
                                          fontSize:
                                          14,color: Theme.of(context).colorScheme.outline),
                                    ),

                                    if (task.files
                                        .isNotEmpty)
                                      Padding(
                                        padding:
                                        const EdgeInsets
                                            .only(
                                            top:
                                            4),
                                        child: Row(
                                          children: [
                                             Icon(
                                                Icons
                                                    .cloud_download,
                                                size:
                                                13,
                                                color:
                                                Theme.of(context).colorScheme.primary),
                                            const SizedBox(
                                                width:
                                                4),
                                            Text(
                                              "${task.files.length} files • ${totalSize.toStringAsFixed(1)} MB",
                                              style:  TextStyle(
                                                  fontSize:
                                                  11,
                                                  color:
                                                  Theme.of(context).colorScheme.primary),
                                            )
                                          ],
                                        ),
                                      )
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      })
                    ],
                  );
                }).toList(),
              ),
            )
        ],
      ),
    );
  }

  // =========================================================
  // BOTTOM BUTTONS
  // =========================================================

  Widget _buildBottomButtons(Color primary) {
    return Container(
      padding:
      const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color:Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [

          Expanded(
            child: OutlinedButton(
              onPressed: hasSelection ? clearAll : null,
              style: OutlinedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(
                    vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(30),
                ),
              ),
              child: const Text("Clear"),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: hasSelection
                    ? primary
                    : Colors.grey,
                padding:
                const EdgeInsets.symmetric(
                    vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(30),
                ),
              ),
              onPressed: hasSelection
                  ? () async {

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
                        .map((t) => AssignTask(
                      taskId: t.taskId,
                      taskName: t.taskName,
                    ))
                        .toList();

                    if (tasksForCategory.isNotEmpty) {
                      selectedCategories.add(
                        AssignCategory(
                          categoryId: cat.categoryId,
                          categoryName: cat.categoryName,
                          tasks: tasksForCategory,
                        ),
                      );
                    }
                  }

                  if (selectedCategories.isNotEmpty) {
                    selectedItems.add(
                      AssignItem(
                        itemId: template.itemId,
                        itemName: template.itemName,
                        categories: selectedCategories,
                      ),
                    );
                  }
                }

                if (selectedItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Select at least one task"),
                    ),
                  );
                  return;
                }


                final request = AssignTaskRequest(
                  projectId: widget.projectId,
                  tabId: widget.tabId,
                  data: selectedItems,
                );

                context.read<TemplateBloc>().add(
                  AssignTasks(request: request),
                );
              }
                  : null,
              child: Text(
                  "Assign ($totalSelectedTasks)"),
            ),
          ),
        ],
      ),
    );
  }
}
