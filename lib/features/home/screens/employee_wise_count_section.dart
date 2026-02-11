import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';

class EmployeeSection extends StatelessWidget {
  const EmployeeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (prev, curr) =>
          prev.isEmployeeWiseTaskListLoading !=
              curr.isEmployeeWiseTaskListLoading ||
          prev.employeeWiseTaskList != curr.employeeWiseTaskList,
      builder: (context, state) {
        if (state.isEmployeeWiseTaskListLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.employeeWiseTaskList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context, state.employeeWiseTaskList.length),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.employeeWiseTaskList.length.clamp(0, 10),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final employee = state.employeeWiseTaskList[index];
                    final scheme = Theme.of(context).colorScheme;

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        // Navigate to employee task list
                      },
                      child: Container(
                        width: 200,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: _getEmployeeBgColor(
                                    context,
                                    index,
                                  ),
                                  backgroundImage:
                                      employee.userProfileUrl.isNotEmpty
                                      ? NetworkImage(employee.userProfileUrl)
                                      : null,
                                  child: employee.userProfileUrl.isEmpty
                                      ? Text(
                                          employee.userName.isNotEmpty
                                              ? employee.userName[0]
                                                    .toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                            color: scheme.onSurface,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              employee.userName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _buildStatusChip(
                                  '${employee.completedTaskCount}',
                                  'Done',
                                  scheme.primary,
                                  scheme.primaryContainer,
                                ),
                                _buildStatusChip(
                                  '${employee.pendingAtMe}',
                                  'At me',
                                  scheme.secondary,
                                  scheme.secondaryContainer,
                                ),
                                _buildStatusChip(
                                  '${employee.totalPendingTask}',
                                  'Pending',
                                  scheme.error,
                                  scheme.errorContainer,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------- Helpers ----------

  Widget _buildStatusChip(
    String count,
    String label,
    Color textColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, int count) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          // Icon + Title + Count
          Row(
            children: [
              Icon(Icons.people_alt_rounded, size: 20, color: scheme.primary),
              const SizedBox(width: 6),
              const Text(
                "Employees",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$count",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // View all
          TextButton(
            onPressed: () {
              // Navigate to all employees
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "View all",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: scheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEmployeeBgColor(BuildContext context, int index) {
    final scheme = Theme.of(context).colorScheme;
    final colors = [
      scheme.primaryContainer,
      scheme.secondaryContainer,
      scheme.tertiaryContainer,
      scheme.errorContainer,
    ];
    return colors[index % colors.length];
  }
}
