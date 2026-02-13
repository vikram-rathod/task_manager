import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/task/screen/widget/_main_item_card.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/storage/storage_service.dart';
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

  bool _isFabOpen = false;
  bool _isFounderOrPartner = false;

  final List<String> _tabs = [
    "Collection → Filling of Documents",
    "Collection → Review & Commenting",
    "Creation of Source Documents → Handoff"
  ];

  @override
  void initState() {
    super.initState();
    context.read<CreateTaskBloc>().add(LoadProjectList());
    _loadUserRole();
  }

  void _loadUserRole() async {
    final userType = await sl<StorageService>().read("userType");

    setState(() {
      _isFounderOrPartner =
          userType == "700372" || userType == "2"; // adjust if needed
    });
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildBody(),
          ),

          _buildFloatingMenu(), // 👈 Add this
        ],
      ),
    );
  }
  Widget _buildBody() {
    final primary = Theme.of(context).primaryColor;
    return BlocBuilder<CreateTaskBloc, CreateTaskState>(
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
                  fontWeight: FontWeight.w700,
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
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: projectState.selectedProject?.projectId,
                  hint: const Text("Choose Project"),
                  items: projectState.projects.map((project) {
                    return DropdownMenuItem<int>(
                      value: project.projectId,
                      child: Text(
                        project.projectName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (projectId) {
                    if (projectId != null) {
                      final selectedProject = projectState.projects
                          .firstWhere((p) => p.projectId == projectId);

                      context.read<CreateTaskBloc>().add(
                        ProjectSelected(selectedProject),
                      );

                      _loadHierarchy(projectId.toString());
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
                    return Center(
                      child:
                      Text("No Task Lists Found",style: TextStyle(color: Theme.of(context).colorScheme.outline),),
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
    );
  }

  Widget _buildFloatingMenu() {
    final primary = Theme.of(context).primaryColor;

    return Positioned(
      bottom: 30,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          /// CREATE TEMPLATE (Role Based)
          if (_isFabOpen )
            _buildMiniOption(
              icon: Icons.note_add,
              label: "Create Template",
              onTap: () {
                setState(() => _isFabOpen = false);
              },
            ),

          /// ASSIGN TASK
          if (_isFabOpen)
            _buildMiniOption(
              icon: Icons.assignment,
              label: "Assign Task",
              onTap: () {
                setState(() => _isFabOpen = false);
              },
            ),

          const SizedBox(height: 12),

          /// MAIN FAB
          FloatingActionButton(
            backgroundColor: primary,
            onPressed: () {
              setState(() => _isFabOpen = !_isFabOpen);
            },
            child: Icon(
              _isFabOpen ? Icons.close : Icons.add,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildMiniOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// Label
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color:Theme.of(context).colorScheme.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(label,style: TextStyle(color: Theme.of(context).colorScheme.outline,fontWeight: FontWeight.w700)),
          ),

          const SizedBox(width: 10),

          /// Icon Button
          FloatingActionButton(
            heroTag: label,
            mini: true,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            onPressed: onTap,
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

}

