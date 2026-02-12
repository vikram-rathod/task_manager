import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/task/screen/widget/_main_item_card.dart';
import '../../createtask/bloc/task_create_bloc.dart';
import '../../createtask/bloc/taskcreate_event.dart';
import '../../createtask/bloc/taskcreate_state.dart';
import '../bloc/task_list_bloc.dart';
import '../bloc/task_list_event.dart';
import '../bloc/task_list_state.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  int _selectedTabIndex = 1;

  final List<String> _tabs = [
    "Collection → Filling of Documents",
    "Collection → Review & Commenting",
    "Creation of Source Documents → Handoff"
  ];

  @override
  void initState() {
    super.initState();
    context.read<CreateTaskBloc>().add(LoadProjectList());
  }

  void _loadHierarchy(String projectId) {
    context.read<TaskListBloc>().add(
      LoadTaskHierarchy(
        projectId: projectId,
        tabId: (_selectedTabIndex + 1).toString(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task-List"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<CreateTaskBloc, CreateTaskState>(
          builder: (context, projectState) {
            if (projectState.projectListLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (projectState.errorMessage != null) {
              return Center(child: Text(projectState.errorMessage!));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ---------------- TABS ----------------
                SizedBox(
                  height: 45,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabs.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final isSelected =
                          _selectedTabIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = index;
                          });

                          if (projectState.selectedProject !=
                              null) {
                            _loadHierarchy(projectState
                                .selectedProject!.projectId
                                .toString());
                          }
                        },
                        child: AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18),
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(30),
                            color: isSelected
                                ? primary
                                : Colors.transparent,
                            border: Border.all(
                              color: primary,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                /// ---------------- SELECT PROJECT ----------------
                Text(
                  "Select Project",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: primary),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(16),
                    border: Border.all(
                        color:
                        Colors.grey.withOpacity(0.5)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      isExpanded: true,
                      value: projectState.selectedProject,
                      hint: const Text("Choose Project"),
                      items: projectState.projects
                          .map((project) {
                        return DropdownMenuItem(
                          value: project,
                          child: Text(
                            project.projectName,
                            overflow:
                            TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (project) {
                        if (project != null) {
                          context
                              .read<CreateTaskBloc>()
                              .add(
                              ProjectSelected(project));

                          _loadHierarchy(
                              project.projectId
                                  .toString());
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// ---------------- TASK HIERARCHY ----------------
                Expanded(
                  child:
                  BlocBuilder<TaskListBloc,
                      TaskListState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(
                            child:
                            CircularProgressIndicator());
                      }

                      if (state.items.isEmpty) {
                        return const Center(
                          child:
                          Text("No Task Lists Found"),
                        );
                      }

                      return ListView.builder(
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final selectedProject = projectState.selectedProject;

                          if (selectedProject == null) {
                            return const SizedBox(); // safety
                          }

                          return MainItemCard(
                            item: state.items[index],
                            projectId: selectedProject.projectId.toString(),
                          );
                        },
                      );

                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

