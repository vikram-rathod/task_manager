import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/task/screen/widget/_main_item_card.dart';
import '../../../core/di/injection_container.dart';
import '../../../reusables/searchable_dropdown.dart';
import '../../createtask/bloc/task_create_bloc.dart';
import '../../createtask/bloc/taskcreate_event.dart';
import '../../createtask/bloc/taskcreate_state.dart';
import '../../template/bloc/template_bloc.dart';
import '../../template/bloc/template_event.dart';
import '../../template/screen/assign_task_screen.dart';
import '../../template/screen/template_list_screen.dart';
import '../bloc/task_list_bloc.dart';
import '../bloc/task_list_event.dart';
import '../bloc/task_list_state.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  bool _isFabOpen = false;

  final List<String> _tabs = [
    "Collection → Filing of Documents",
    "Collection → Review & Commenting → Updated Doc Collection → Filing of Documents",
    "Creation of Source Documents → Handoff",
  ];

  @override
  void initState() {
    super.initState();
    context.read<CreateTaskBloc>().add(LoadProjectList());
    context.read<TaskListBloc>().add(LoadUserRole());
  }

  @override
  void dispose() {
    context.read<TaskListBloc>().add(ResetTaskList());
    context.read<CreateTaskBloc>().add(ProjectCleared());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task List"),
      ),
      floatingActionButton: _buildFloatingMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBody(cs),
      ),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    return BlocBuilder<CreateTaskBloc, CreateTaskState>(
      builder: (context, projectState) {
        if (projectState.projectListLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (projectState.errorMessage != null) {
          return Center(child: Text(projectState.errorMessage!));
        }

        return BlocBuilder<TaskListBloc, TaskListState>(
          builder: (context, taskState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TABS
                SizedBox(
                  height: 45,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final isSelected =
                          taskState.selectedTabIndex == index;

                      return GestureDetector(
                        onTap: () {
                          final tabId = (index + 1).toString();
                          context.read<TaskListBloc>().add(
                            ChangeTab(tabId: tabId, tabIndex: index),
                          );
                          if (projectState.selectedProject != null) {
                            context.read<TaskListBloc>().add(
                              LoadTaskHierarchy(
                                projectId: projectState
                                    .selectedProject!.projectId
                                    .toString(),
                                tabId: tabId,
                              ),
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: isSelected
                                ? cs.primary
                                : Colors.transparent,
                            border: Border.all(color: cs.primary),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? cs.onPrimary
                                  : cs.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                /// PROJECT SELECTION — using SearchableDropdown
                SearchableDropdown(
                  label: 'Project',
                  hint: 'Select project',
                  icon: Icons.folder_outlined,
                  items: projectState.projects,
                  selectedItem: projectState.selectedProject,
                  itemAsString: (project) => project.projectName,
                  onChanged: (project) {
                    if (project != null) {
                      context
                          .read<CreateTaskBloc>()
                          .add(ProjectSelected(project));
                      context.read<TaskListBloc>().add(
                        LoadTaskHierarchy(
                          projectId: project.projectId.toString(),
                          tabId: taskState.selectedTabId,
                        ),
                      );
                    } else {
                      context.read<TaskListBloc>().add(ClearTaskItems());
                      context.read<CreateTaskBloc>().add(ProjectCleared());
                    }
                  },
                  isEnabled: !projectState.projectListLoading,
                  isLoading: projectState.projectListLoading,
                ),

                const SizedBox(height: 20),

                /// TASK HIERARCHY
                Expanded(
                  child: Builder(
                    builder: (_) {
                      if (taskState.isLoading) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (projectState.selectedProject == null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open_rounded,
                                  size: 64,
                                  color: cs.onSurfaceVariant
                                      .withOpacity(0.4)),
                              const SizedBox(height: 12),
                              Text(
                                "Select a project to view tasks",
                                style: TextStyle(
                                    color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        );
                      }

                      if (taskState.items.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_rounded,
                                  size: 64,
                                  color: cs.onSurfaceVariant
                                      .withOpacity(0.4)),
                              const SizedBox(height: 12),
                              Text(
                                "No Task Lists Found",
                                style: TextStyle(
                                    color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: taskState.items.length,
                        itemBuilder: (context, index) {
                          return MainItemCard(
                            item: taskState.items[index],
                            projectId: projectState
                                .selectedProject!.projectId
                                .toString(),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFloatingMenu() {
    final cs = Theme.of(context).colorScheme;
    final taskState = context.watch<TaskListBloc>().state;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        /// CREATE TEMPLATE (Role Based)
        if (_isFabOpen && taskState.isFounderOrPartner)
          _buildMiniOption(
            icon: Icons.note_add,
            label: "Create Template",
            onTap: () {
              setState(() => _isFabOpen = false);
              _navigateToTemplateList();  // ✅ correct method
            },
          ),

        /// ASSIGN TASK
        if (_isFabOpen)
          _buildMiniOption(
            icon: Icons.assignment,
            label: "Assign Task",
            onTap: () {
              setState(() => _isFabOpen = false);
              _navigateToAssignTask();    // ✅ correct method
            },
          ),

        const SizedBox(height: 12),

        /// MAIN FAB
        FloatingActionButton(
          backgroundColor: cs.primary,
          onPressed: () => setState(() => _isFabOpen = !_isFabOpen),
          child: AnimatedRotation(
            turns: _isFabOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isFabOpen ? Icons.close : Icons.add,
              color: cs.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToAssignTask() {
    final tabId = context.read<TaskListBloc>().state.selectedTabId;
    final selectedProject = context.read<CreateTaskBloc>().state.selectedProject;
    final cs = Theme.of(context).colorScheme;

    if (selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select a project first"),
          backgroundColor: cs.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final templateBloc = sl<TemplateBloc>()..add(LoadTemplates(tabId: tabId));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: templateBloc,
          child: AssignTaskScreen(
            tabId: tabId,
            projectName: selectedProject.projectName,
            projectId: selectedProject.projectId.toString(),
          ),
        ),
      ),
    );
  }

  void _navigateToTemplateList() {
    final tabId = context.read<TaskListBloc>().state.selectedTabId;
    final tabName = _tabs[int.parse(tabId) - 1];

    final templateBloc = sl<TemplateBloc>()..add(LoadTemplates(tabId: tabId));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: templateBloc,
          child: TemplateListScreen(tabId: tabId, tabName: tabName),
        ),
      ),
    );
  }
  Widget _buildMiniOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withOpacity(0.08),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: label,
            mini: true,
            backgroundColor: cs.primaryContainer,
            onPressed: onTap,
            child: Icon(icon, color: cs.primary, size: 20),
          ),
        ],
      ),
    );
  }
}