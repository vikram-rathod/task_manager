import 'package:flutter/material.dart';
import 'package:task_manager/core/models/task_model.dart';

class CompactTaskCard extends StatelessWidget {
  final TMTasksModel task;
  final VoidCallback? onTap;

  const CompactTaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;


    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.07) : Colors.grey.shade100,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Top accent bar ────────────────────────────────────────────
              Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Title + Priority ──────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.taskDescription.isEmpty
                                ? 'Untitled Task'
                                : task.taskDescription,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (task.priority != null && task.priority!.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flag_rounded,
                                    size: 11
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  task.priority.toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ── Status Badge ──────────────────────────────────────
                    if (task.taskStatus.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              task.taskStatus,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // ── Divider ───────────────────────────────────────────
                    Divider(
                      height: 1,
                      color: isDark
                          ? Colors.white.withOpacity(0.07)
                          : Colors.grey.shade100,
                    ),

                    const SizedBox(height: 12),

                    // ── Project ───────────────────────────────────────────
                    if (task.projectName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.folder_rounded,
                                size: 13, color: Colors.blue.shade400),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                task.projectName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── People Chips ──────────────────────────────────────
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (task.checkerName.isNotEmpty)
                          _TaskPersonChip(
                            icon: Icons.verified_rounded,
                            label: task.checkerName,
                            color: colorScheme.secondary.withOpacity(0.8),
                            role: 'Checker',
                            isDark: isDark,
                          ),
                        if (task.makerName.isNotEmpty)
                          _TaskPersonChip(
                            icon: Icons.edit_rounded,
                            label: task.makerName,
                            color: colorScheme.primary.withOpacity(0.8),
                            role: 'Maker',
                            isDark: isDark,
                          ),

                        if (task.pcEngrName.isNotEmpty)
                          _TaskPersonChip(
                            icon: Icons.manage_accounts_rounded,
                            label: task.pcEngrName,
                            color: colorScheme.secondary.withOpacity(0.8),
                            role: 'PC',
                            isDark: isDark,
                          ),
                      ],
                    ),

                    // ── Due Date ──────────────────────────────────────────
                    if (task.dueDate != null && task.dueDate!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            task.dueDate!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                            ),
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

}

// ── Person Chip ───────────────────────────────────────────────────────────────

class _TaskPersonChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String role;
  final bool isDark;

  const _TaskPersonChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.role,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(icon, size: 11, color: color.withOpacity(0.8)),
          const SizedBox(width: 4),
          Text(
            '$role: ',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.6),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}