import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/task_model.dart';
import '../../../reusables/task_history_list.dart';
import '../bloc/task_details_bloc.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TMTasksModel taskModel;

  const TaskDetailsScreen({super.key, required this.taskModel});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TaskDetailsBloc>().add(
      FetchTaskDetails(widget.taskModel.taskId.toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: scheme.surface,
        title: Text(
          'Task #${widget.taskModel.taskId}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: scheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: scheme.onSurfaceVariant),
            onPressed: () {
              context.read<TaskDetailsBloc>().add(
                FetchTaskDetails(widget.taskModel.taskId.toString()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<TaskDetailsBloc, TaskDetailsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: scheme.primary,
              ),
            );
          }

          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: scheme.error,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Oops! Something went wrong',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage!,
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<TaskDetailsBloc>().add(
                          FetchTaskDetails(widget.taskModel.taskId.toString()),
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final task = state.taskModel ?? widget.taskModel;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and Priority Badges
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildBadge(
                        label: 'Status',
                        value: task.taskStatus,
                        icon: Icons.circle,
                        scheme: scheme,
                      ),
                      _buildBadge(
                        label: 'Priority',
                        value: task.taskPriority ?? task.priority  ?? "--",
                        icon: Icons.flag_rounded,
                        scheme: scheme,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Task Description
                _buildCard(
                  scheme: scheme,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(Icons.description_rounded,'Description', scheme: scheme),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: scheme.outline,
                            width: 0.2,
                          ),
                        ),
                        child: Tooltip(
                          message: task.taskDescription,
                          child: Text(
                            task.taskDescription.isNotEmpty
                                ? task.taskDescription
                                : 'No description available',
                            maxLines: 10,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: task.taskDescription.isNotEmpty
                                  ? scheme.onSurface
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Project Information
                if (task.projectName.isNotEmpty)
                  _buildCard(
                    scheme: scheme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(Icons.folder_rounded,'Project & Task Type', scheme: scheme),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.folder_rounded,
                          label: 'Project',
                          value: task.projectName,
                          scheme: scheme,
                        ),
                        if (task.taskType != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.category_rounded,
                            label: 'Type',
                            value: task.taskType!,
                            scheme: scheme,
                          ),
                        ],
                      ],
                    ),
                  ),

                // Team Section
                _buildCard(
                  scheme: scheme,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(Icons.group_rounded, 'Team', scheme: scheme),
                      const SizedBox(height: 16),
                      if (task.userName.isNotEmpty)
                        _buildRoleRow(
                          role: 'UserName',
                          name: task.userName,
                          scheme: scheme,
                          url: task.userProfilePicUrl,
                        ),

                      if (task.checkerName.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildRoleRow(
                          role: 'Checker',
                          name: task.checkerName,
                          scheme: scheme,
                          url: task.checkerProfilePicUrl,
                        ),
                      ],

                      if (task.makerName.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildRoleRow(
                          role: 'Maker',
                          name: task.makerName,
                          scheme: scheme,
                          url: task.makerProfilePicUrl,
                        ),
                      ],

                      if (task.pcEngrName.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildRoleRow(
                          role: 'Planner/Coordinator',
                          name: task.pcEngrName,
                          scheme: scheme,
                          url: task.pcEngrProfilePicUrl,
                        ),
                      ],
                      if (task.createdByName != null &&
                          task.createdByName!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildRoleRow(
                          role: 'Created By Vikram Baba',
                          name: task.createdByName!,
                          scheme: scheme,
                          url: task.userProfilePicUrl,
                        ),
                      ],
                    ],
                  ),
                ),

                // // Team Members
                // if (task.teamMembers.isNotEmpty)
                //   _buildCard(
                //     scheme: scheme,
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         _buildSectionTitle(
                //           Icons.group_rounded,
                //           'Team Members (${task.teamMembers.length})',
                //           scheme: scheme,
                //         ),
                //         const SizedBox(height: 16),
                //         SizedBox(
                //           height: 90,
                //           child: ListView.separated(
                //             scrollDirection: Axis.horizontal,
                //             itemCount: task.teamMembers.length,
                //             separatorBuilder: (context, index) =>
                //             const SizedBox(width: 12),
                //             itemBuilder: (context, index) {
                //               final member = task.teamMembers[index];
                //               return _buildTeamMemberCard(member, scheme);
                //             },
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),

                // Timeline
                _buildCard(
                  scheme: scheme,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(Icons.timeline_rounded, 'Timeline', scheme: scheme),
                      const SizedBox(height: 16),
                      if (task.taskRegisteredDate != null)
                        _buildTimelineRow(
                          icon: Icons.event_available_rounded,
                          label: 'Registered',
                          value: task.taskRegisteredDate!,
                          scheme: scheme,
                        ),
                      if (task.taskStartDate != null) ...[
                        const SizedBox(height: 12),
                        _buildTimelineRow(
                          icon: Icons.play_circle_outline_rounded,
                          label: 'Start Date',
                          value: task.taskStartDate!,
                          scheme: scheme,
                        ),
                      ],
                      if (task.taskEndDate != null) ...[
                        const SizedBox(height: 12),
                        _buildTimelineRow(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'End Date',
                          value: task.taskEndDate!,
                          scheme: scheme,
                        ),
                      ],
                      if (task.targetedDate != null ) ...[
                        const SizedBox(height: 12),
                        _buildTimelineRow(
                          icon: Icons.flag_circle_outlined,
                          label: 'Target Date',
                          value: task.targetedDate!,
                          scheme: scheme,
                        ),
                      ],
                      if (task.dueDate != null) ...[
                        const SizedBox(height: 12),
                        _buildTimelineRow(
                          icon: Icons.schedule_rounded,
                          label: 'Due Date',
                          value: task.dueDate!,
                          isHighlight: true,
                          scheme: scheme,
                        ),
                      ],
                    ],
                  ),
                ),

                // Prochat Information
                if (task.prochatTaskId != null)
                  _buildCard(
                    scheme: scheme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(Icons.chat_bubble_outline_rounded, 'Prochat Information', scheme: scheme),                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Task ID',
                          value: task.prochatTaskId!,
                          scheme: scheme,
                        ),
                        if (task.prochatRemark != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: scheme.primary.withOpacity(0.4),
                                  width: 0.2
                              ),
                            ),
                            child: Text(
                              task.prochatRemark!,
                              style: TextStyle(
                                fontSize: 13,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                // Task History
                if (state.history.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TaskHistoryList(
                      historyItems: state.history
                          .map((item) => TaskHistoryData(
                        statement: item.statement ?? 'Activity recorded',
                        createdDate: item.createdDate ?? '',
                      ))
                          .toList(),
                      isLoading: false,
                      showViewAll: false,
                      title: 'Activity History',
                      emptyMessage: 'No history available',
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    required ColorScheme scheme,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildBadge({
    required String label,
    required String value,
    required IconData icon,
    required ColorScheme scheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outline,
          width: 0.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      IconData icon,
      String title, {
        required ColorScheme scheme,
      }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 18,
          color: scheme.primary,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
              letterSpacing: -0.25,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme scheme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'N/A',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleRow({
    required String role,
    required String name,
    required ColorScheme scheme,
    required String? url,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outline, width: 0.2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: scheme.primaryContainer,
            backgroundImage: (url != null && url.isNotEmpty)
                ? NetworkImage(url)
                : null,
            onBackgroundImageError: (url != null && url.isNotEmpty)
                ? (_, __) {} // falls back to child on error
                : null,
            child: (url == null || url.isEmpty)
                ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: scheme.onPrimaryContainer,
              ),
            )
                : null,
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
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(dynamic member, ColorScheme scheme) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline,width: 0.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: scheme.outlineVariant,
                width: 0.2,
              ),
            ),
            child: ClipOval(
              child: member.userProfileUrl != null
                  ? Image.network(
                member.userProfileUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildAvatarFallback(member.userName, scheme);
                },
              )
                  : _buildAvatarFallback(member.userName, scheme),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            member.userName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name, ColorScheme scheme) {
    return Container(
      color: scheme.primaryContainer,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: scheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

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
}