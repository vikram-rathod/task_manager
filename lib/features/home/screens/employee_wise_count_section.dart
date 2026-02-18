import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:task_manager/features/home/model/employee_count_model.dart';

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
        // ❌ REMOVED: CircularProgressIndicator check
        if (!state.isEmployeeWiseTaskListLoading &&
            state.employeeWiseTaskList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EmployeeHeader(count: state.employeeWiseTaskList.length),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: state.isEmployeeWiseTaskListLoading
                    ? const _EmployeeShimmerList()
                    : _EmployeeList(employees: state.employeeWiseTaskList),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Shimmer List ─────────────────────────────────────────────────────────────

class _EmployeeShimmerList extends StatelessWidget {
  const _EmployeeShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, __) => const _EmployeeShimmerCard(),
    );
  }
}

class _EmployeeShimmerCard extends StatelessWidget {
  const _EmployeeShimmerCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant.withOpacity(0.2), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar placeholder
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Name placeholder
            Container(
              width: 110,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Spacer(),
            // Chips placeholder
            Row(
              children: List.generate(
                3,
                    (_) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Container(
                    width: 44,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Real Employee List ────────────────────────────────────────────────────────

class _EmployeeList extends StatelessWidget {
  final List employees;

  const _EmployeeList({required this.employees});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: employees.length.clamp(0, 10),
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (context, index) => _EmployeeCard(
        employee: employees[index],
        index: index,
      ),
    );
  }
}

// ── Reusable Employee Card ────────────────────────────────────────────────────

class _EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;
  final int index;

  const _EmployeeCard({required this.employee, required this.index});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.pushNamed(context, '/employeeTask', arguments: employee);
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant.withOpacity(0.2), width: 0.5),

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
                  backgroundColor: _getBgColor(context, index),
                  backgroundImage: employee.userProfileUrl.isNotEmpty
                      ? NetworkImage(employee.userProfileUrl)
                      : null,
                  child: employee.userProfileUrl.isEmpty
                      ? Text(
                    employee.userName.isNotEmpty
                        ? employee.userName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
                const Spacer(),
                Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
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
                _EmployeeStatusChip(
                  count: '${employee.completedTaskCount}',
                  label: 'Done',
                  textColor: scheme.primary,
                  bgColor: scheme.primaryContainer,
                ),
                _EmployeeStatusChip(
                  count: '${employee.pendingAtMe}',
                  label: 'At me',
                  textColor: scheme.secondary,
                  bgColor: scheme.secondaryContainer,
                ),
                _EmployeeStatusChip(
                  count: '${employee.totalPendingTask}',
                  label: 'Pending',
                  textColor: scheme.error,
                  bgColor: scheme.errorContainer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getBgColor(BuildContext context, int index) {
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

// ── Reusable Status Chip ──────────────────────────────────────────────────────

class _EmployeeStatusChip extends StatelessWidget {
  final String count;
  final String label;
  final Color textColor;
  final Color bgColor;

  const _EmployeeStatusChip({
    required this.count,
    required this.label,
    required this.textColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
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
}

// ── Header ────────────────────────────────────────────────────────────────────

class _EmployeeHeader extends StatelessWidget {
  final int count;

  const _EmployeeHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.people_alt_rounded, size: 20, color: scheme.primary),
          const SizedBox(width: 6),
           Text(
            "Employees",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: scheme.onSurface,),
          ),
          // const SizedBox(width: 8),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          //   decoration: BoxDecoration(
          //     color: Colors.grey.shade100,
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Text(
          //     "$count",
          //     style: TextStyle(
          //       fontSize: 12,
          //       fontWeight: FontWeight.w600,
          //       color: Colors.grey.shade700,
          //     ),
          //   ),
          // ),
          const Spacer(),
          TextButton(
            onPressed: () {},
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
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}