import 'package:flutter/material.dart';

import '../../bloc/project_wise_task_state.dart';

class RoleFilterTabs extends StatelessWidget {
  final UserRoleType selectedRole;
  final ValueChanged<UserRoleType> onRoleSelected;

  const RoleFilterTabs({
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final roles = UserRoleType.values;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: roles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final role = roles[index];
          final isSelected = role == selectedRole;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.3),
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
                  : [],
            ),
            child: InkWell(
              onTap: () => onRoleSelected(role),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon per role
                    Icon(
                      _iconForRole(role),
                      size: 14,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      role.displayName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _iconForRole(UserRoleType role) {
    return switch (role) {
      UserRoleType.all         => Icons.dashboard_outlined,
      UserRoleType.maker       => Icons.engineering_outlined,
      UserRoleType.checker     => Icons.fact_check_outlined,
      UserRoleType.pcEngineer  => Icons.manage_accounts_outlined,
    };
  }
}