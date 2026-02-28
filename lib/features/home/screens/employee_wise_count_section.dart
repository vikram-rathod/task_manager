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
        if (!state.isEmployeeWiseTaskListLoading &&
            state.employeeWiseTaskList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EmployeeHeader(count: state.totalEmployeeWiseTaskList),
              SizedBox(
                height: 130,
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

// ── Shimmer List ──────────────────────────────────────────────────────────────

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

/// Mirrors _EmployeeCard exactly:
///   CircleAvatar (r18) → SizedBox(8) → Expanded name → SizedBox(6) → chip Row
class _EmployeeShimmerCard extends StatelessWidget {
  const _EmployeeShimmerCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.2), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Avatar
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFE0E0E0),
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(height: 8),

            // Name bars
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 80,
                  height: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),

            const Spacer(),  // pushes chips to bottom

            // Chip row
            Row(
              children: List.generate(3, (i) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }),
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

// ── Employee Card ─────────────────────────────────────────────────────────────

class _EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;
  final int index;

  const _EmployeeCard({required this.employee, required this.index});

  Color _avatarBg(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return [
      cs.primaryContainer,
      cs.secondaryContainer,
      cs.tertiaryContainer,
      cs.errorContainer,
    ][index % 4];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () =>
          Navigator.pushNamed(context, '/employeeTask', arguments: employee),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: cs.outlineVariant.withOpacity(0.2), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: _avatarBg(context),
              backgroundImage: employee.userProfileUrl.isNotEmpty
                  ? NetworkImage(employee.userProfileUrl)
                  : null,
              child: employee.userProfileUrl.isEmpty
                  ? Text(
                employee.userName.isNotEmpty
                    ? employee.userName[0].toUpperCase()
                    : '?',
                style: textTheme.labelMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),

            const SizedBox(height: 8),

            // Name
            Expanded(
              child: Text(
                employee.userName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Chips
            Row(
              children: [
                _StatusChip(
                  count: employee.totalPendingTask,
                  label: 'Pending',
                  textColor: cs.error,
                  bgColor: cs.errorContainer,
                ),
                const SizedBox(width: 4),
                _StatusChip(
                  count: employee.pendingAtOther,
                  label: 'At Others',
                  textColor: cs.primary,
                  bgColor: cs.primaryContainer,
                ),
                const SizedBox(width: 4),
                _StatusChip(
                  count: employee.pendingAtMe,
                  label: 'At Me',
                  textColor: cs.secondary,
                  bgColor: cs.secondaryContainer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status Chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final int count;
  final String label;
  final Color textColor;
  final Color bgColor;

  const _StatusChip({
    required this.count,
    required this.label,
    required this.textColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
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
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.people_alt_rounded, size: 20, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            'Employees',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          if (count > 0)
            Text(
              "($count)",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'View all',
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

