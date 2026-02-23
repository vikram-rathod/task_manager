import 'package:flutter/material.dart';
import '../../../core/models/task_model.dart';

class TaskCard extends StatefulWidget {
  final TMTasksModel task;
  final VoidCallback? onTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onAssignTap;
  final EdgeInsetsGeometry? margin;
  final String searchQuery;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onChatTap,
    this.onAssignTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    this.searchQuery = '',
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  bool get _isProChatTask =>
      widget.task.prochatTaskId != null &&
          widget.task.prochatTaskId!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;


    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: Container(
          margin: widget.margin,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: _isPressed ? 12 : 8,
                offset: Offset(0, _isPressed ? 6 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient top accent bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      _getPriorityColor(widget.task.taskPriority ??
                          widget.task.priority),
                      _getPriorityColor(widget.task.taskPriority ??
                          widget.task.priority)
                          .withOpacity(0.5),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Priority + Task Type + Chat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Chat Button
                        if (widget.onChatTap != null)
                          _ModernChatButton(onTap: widget.onChatTap!),

                        const SizedBox(width: 12),

                        if (widget.task.taskType?.isNotEmpty ?? false)
                          _TaskTypeBadge(
                              taskType: widget.task.taskType!),
                      ],
                    ),


                    // Project Name
                    if (widget.task.projectName.isNotEmpty ?? false) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.work_outline_rounded,
                              size: 16,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: _HighlightedText(
                                text: widget.task.projectName,
                                query: widget.searchQuery,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Task Description
                    _HighlightedText(
                      text: widget.task.taskDescription ?? 'No description',
                      query: widget.searchQuery,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Priority Badge
                    if ((widget.task.taskPriority?.isNotEmpty ??
                        false) ||
                        (widget.task.priority?.isNotEmpty ?? false))
                      _ModernPriorityBadge(
                        priority: widget.task.taskPriority ??
                            widget.task.priority ??
                            '',
                      ),
                    const SizedBox(height: 12),
                    // Task Regn Date
                    if (widget.task.taskRegisteredDate != null)
                      _buildTimelineRow(
                        icon: Icons.event_available_rounded,
                        label: 'Registered',
                        value: widget.task.taskRegisteredDate!,
                        scheme: scheme,
                      ),
                    // Task Target Date

                    if (widget.task.targetedDate != null ) ...[
                      const SizedBox(height: 12),
                      _buildTimelineRow(
                        icon: Icons.flag_circle_outlined,
                        label: 'Target Date',
                        value: widget.task.targetedDate!,
                        scheme: scheme,
                      ),
                    ],


                    // ProChat Remark (if available)
                    if (_isProChatTask &&
                        (widget.task.prochatRemark?.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 8),
                      _ProChatRemark(
                        remark: widget.task.prochatRemark!,
                        isDark: isDark,
                      ),
                      if (widget.task.dueDate?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Due: ${widget.task.dueDate}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],

                    // Team Section
                    if (_hasTeamInfo) ...[
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          if (widget.task.makerName.isNotEmpty ?? false)
                            _ModernTeamMember(
                              role: 'Maker',
                              name: widget.task.makerName,
                              searchQuery: widget.searchQuery,
                              color: const Color(0xFF6366F1), // Indigo
                            ),
                          if (widget.task.checkerName.isNotEmpty ?? false) ...[
                            const SizedBox(height: 8),
                            _ModernTeamMember(
                              role: 'Checker',
                              name: widget.task.checkerName,
                              searchQuery: widget.searchQuery,
                              color: const Color(0xFF8B5CF6), // Purple
                            ),
                          ],
                          if (widget.task.pcEngrName.isNotEmpty ?? false) ...[
                            const SizedBox(height: 8),
                            _ModernTeamMember(
                              role: 'Planner/Coordinator',
                              name: widget.task.pcEngrName,
                              searchQuery: widget.searchQuery,
                              color: const Color(0xFF06B6D4), // Cyan
                            ),
                          ],
                        ],
                      ),
                    ],

                    // Status Badge
                    if (widget.task.taskStatus.isNotEmpty ?? false) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.task.taskStatus,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ProChat Assign Task Button
                    if (_isProChatTask && widget.onAssignTap != null) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _ProChatAssignTask(onTap: widget.onAssignTap!),
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

  bool get _hasTeamInfo =>
      (widget.task.makerName.isNotEmpty ?? false) ||
          (widget.task.checkerName.isNotEmpty ?? false) ||
          (widget.task.pcEngrName.isNotEmpty ?? false);

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case '1':
        return const Color(0xFFEF4444); // High - Red
      case '2':
        return const Color(0xFFF59E0B); // Medium - Orange
      case '3':
        return const Color(0xFF3B82F6); // Low - Blue
      default:
        return const Color(0xFF6B7280); // Default - Gray
    }
  }
}

// ========== Sub-Components ==========

Widget _buildTimelineRow({
  required IconData icon,
  required String label,
  required String value,
  bool isHighlight = false,
  required ColorScheme scheme,
}) {
  final highlightColor = isHighlight ? scheme.tertiary : scheme.primary;

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isHighlight
          ? scheme.tertiaryContainer.withOpacity(0.5)
          : scheme.surfaceContainerHighest.withOpacity(0.4),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
          color: isHighlight ? scheme.tertiary : scheme.outline,
          width: 0.2
      ),
    ),
    child: Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isHighlight ? scheme.tertiary : scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isHighlight ? scheme.onTertiaryContainer : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ModernPriorityBadge extends StatelessWidget {
  final String priority;

  const _ModernPriorityBadge({required this.priority});

  Color _getPriorityColor() {
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
    final color = _getPriorityColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_outlined, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            'P-$priority',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskTypeBadge extends StatelessWidget {
  final String taskType;

  const _TaskTypeBadge({required this.taskType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.forward_rounded, size: 14, color: theme.primaryColor),
          const SizedBox(width: 6),
          Text(
            taskType,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernChatButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ModernChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_rounded,
              size: 16,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              'Chat',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProChatAssignTask extends StatelessWidget {
  final VoidCallback onTap;

  const _ProChatAssignTask({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF10B981); // Green

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Assign Task',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.fast_forward_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

class _ProChatRemark extends StatelessWidget {
  final String remark;
  final bool isDark;

  const _ProChatRemark({required this.remark, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]?.withOpacity(0.5)
            : Colors.grey[200]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              remark,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernTeamMember extends StatelessWidget {
  final String role;
  final String name;
  final String searchQuery;
  final Color color;

  const _ModernTeamMember({
    required this.role,
    required this.name,
    required this.searchQuery,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Avatar Circle
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_rounded, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              _HighlightedText(
                text: name,
                query: searchQuery,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style);
    }

    final theme = Theme.of(context);
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int currentIndex = 0;

    while (currentIndex < text.length) {
      final matchIndex = lowerText.indexOf(lowerQuery, currentIndex);

      if (matchIndex == -1) {
        spans.add(TextSpan(text: text.substring(currentIndex)));
        break;
      } else {
        if (matchIndex > currentIndex) {
          spans.add(TextSpan(text: text.substring(currentIndex, matchIndex)));
        }

        spans.add(
          TextSpan(
            text: text.substring(matchIndex, matchIndex + query.length),
            style: TextStyle(
              backgroundColor:
              theme.primaryColor.withOpacity(0.3),
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

        currentIndex = matchIndex + query.length;
      }
    }

    return RichText(
      text: TextSpan(style: style, children: spans),
    );
  }
}