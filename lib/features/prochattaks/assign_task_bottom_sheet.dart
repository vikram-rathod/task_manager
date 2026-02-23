import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/task_model.dart';
import '../../../reusables/searchable_dropdown.dart';
import 'bloc/prochat_task_bloc.dart';

class AssignTaskBottomSheet extends StatelessWidget {
  final TMTasksModel task;

  const AssignTaskBottomSheet({super.key, required this.task});

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case '1':
        return const Color(0xFFEF4444);
      case '2':
        return const Color(0xFFF59E0B);
      case '3':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final priority = task.taskPriority ?? task.priority;

    return BlocConsumer<ProchatTaskBloc, ProchatTaskState>(
      listenWhen: (prev, curr) => prev.assignStatus != curr.assignStatus,
      listener: (context, state) {
        if (state.assignStatus == ProchatAssignStatus.success) {
          Navigator.pop(context, true); // true = assigned
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text('Task assigned successfully'),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
          context.read<ProchatTaskBloc>().add(const ProchatAssignReset());
        } else if (state.assignStatus == ProchatAssignStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.assignErrorMessage),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting =
            state.assignStatus == ProchatAssignStatus.loading;

        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ── Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // ── Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                            const Color(0xFF10B981).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.assignment_turned_in_rounded,
                            color: Color(0xFF10B981),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Assign Task',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                  isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                'ProChat Task · ${task.prochatTaskId ?? ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            context
                                .read<ProchatTaskBloc>()
                                .add(const ProchatAssignReset());
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Task summary strip
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.grey.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (priority?.isNotEmpty ?? false)
                          _InfoChip(
                            icon: Icons.flag_outlined,
                            label: 'P-$priority',
                            color: _getPriorityColor(priority),
                          ),
                        if (task.taskType?.isNotEmpty ?? false) ...[
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.forward_rounded,
                            label: task.taskType!,
                            color: theme.primaryColor,
                          ),
                        ],
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task.taskDescription ?? '—',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 12),

                  // ── Scrollable dropdowns + button
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        // Project
                        SearchableDropdown(
                          label: 'Project',
                          hint: 'Select project',
                          icon: Icons.folder_outlined,
                          items: state.projects,
                          selectedItem: state.selectedProject,
                          itemAsString: (p) => p.projectName,
                          onChanged: (p) {
                            if (p != null) {
                              context
                                  .read<ProchatTaskBloc>()
                                  .add(ProchatProjectSelected(p));
                            } else {
                              context
                                  .read<ProchatTaskBloc>()
                                  .add(const ProchatProjectCleared());
                            }
                          },
                          isEnabled: !state.projectListLoading,
                          isLoading: state.projectListLoading,
                          isRequired: true,
                          validator: (p) =>
                          p == null ? 'Please select a project' : null,
                        ),

                        const SizedBox(height: 16),

                        // Checker
                        SearchableDropdown(
                          label: 'Checker',
                          hint: 'Select checker',
                          icon: Icons.person_outline,
                          items: state.checkers,
                          selectedItem: state.selectedChecker,
                          itemAsString: (u) => u.userName ?? '',
                          onChanged: (u) {
                            if (u != null) {
                              context
                                  .read<ProchatTaskBloc>()
                                  .add(ProchatCheckerSelected(u));
                            } else {
                              context
                                  .read<ProchatTaskBloc>()
                                  .add(const ProchatCheckerCleared());
                            }
                          },
                          isEnabled: state.selectedProject != null &&
                              !state.checkerListLoading,
                          isLoading: state.checkerListLoading,
                        ),

                        const SizedBox(height: 16),

                        // Maker
                        SearchableDropdown(
                          label: 'Maker',
                          hint: 'Select maker',
                          icon: Icons.engineering_outlined,
                          items: state.makers,
                          selectedItem: state.selectedMaker,
                          itemAsString: (u) => u.userName ?? '',
                          onChanged: (u) {
                            if (u != null) {
                              context
                                  .read<ProchatTaskBloc>()
                                  .add(ProchatMakerSelected(u));
                            } else {
                              context
                                  .read<ProchatTaskBloc>()
                                  .add(const ProchatMakerCleared());
                            }
                          },
                          isEnabled: state.selectedChecker != null &&
                              !state.makerListLoading,
                          isLoading: state.makerListLoading,
                        ),

                        const SizedBox(height: 16),

                        // Planner/Coordinator
                        SearchableDropdown(
                          label: 'Planner/Coordinator',
                          hint: 'Select coordinator',
                          icon: Icons.manage_accounts_outlined,
                          items: state.pcEngineers,
                          selectedItem: state.selectedPcEngineer,
                          itemAsString: (u) => u.userName ?? '',
                          onChanged: (u) {
                            if (u != null) {
                              context
                                  .read<ProchatTaskBloc>()
                                  .add(ProchatPcEngineerSelected(u));
                            } else {
                              context
                                  .read<ProchatTaskBloc>()
                                  .add(const ProchatPcEngineerCleared());
                            }
                          },
                          isEnabled: state.selectedMaker != null &&
                              !state.pcEngineerListLoading,
                          isLoading: state.pcEngineerListLoading,
                        ),

                        const SizedBox(height: 28),

                        // Confirm button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: state.isAssignFormValid
                                  ? const Color(0xFF10B981)
                                  : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: isSubmitting || !state.isAssignFormValid
                                ? null
                                : () {
                              context.read<ProchatTaskBloc>().add(
                                ProchatAssignTaskSubmitted(task),
                              );
                            },
                            icon: isSubmitting
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(
                                Icons.assignment_turned_in_rounded),
                            label: Text(
                              isSubmitting
                                  ? 'Assigning...'
                                  : 'Confirm Assignment',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // // Cancel
                        // SizedBox(
                        //   width: double.infinity,
                        //   child: TextButton(
                        //     onPressed: isSubmitting
                        //         ? null
                        //         : () {
                        //       context
                        //           .read<ProchatTaskBloc>()
                        //           .add(const ProchatAssignReset());
                        //       Navigator.pop(context);
                        //     },
                        //     style: TextButton.styleFrom(
                        //       padding:
                        //       const EdgeInsets.symmetric(vertical: 14),
                        //     ),
                        //     child: Text(
                        //       'Cancel',
                        //       style: TextStyle(
                        //         fontSize: 15,
                        //         color: isDark
                        //             ? Colors.grey[400]
                        //             : Colors.grey[600],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Chip helper ───────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}