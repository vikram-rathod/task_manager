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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: scheme.surface,
        title: Text(
          'Task #${widget.taskModel.taskId}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
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
            return const Center(
              child: CircularProgressIndicator(),
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
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Oops! Something went wrong',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<TaskDetailsBloc>().add(
                          FetchTaskDetails(
                              widget.taskModel.taskId.toString()),
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
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
                        color: Colors.black.withOpacity(0.05),
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
                      ),
                      _buildBadge(
                        label: 'Priority',
                        value: task.taskPriority,
                        icon: Icons.flag_rounded,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Task Description
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Description'),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          task.taskDescription.isNotEmpty
                              ? task.taskDescription
                              : 'No description available',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: task.taskDescription.isNotEmpty
                                ? Colors.grey.shade800
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Project Information
                if (task.projectName.isNotEmpty)
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Project'),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.folder_rounded,
                          label: 'Project',
                          value: task.projectName,
                        ),
                        if (task.taskType != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.category_rounded,
                            label: 'Type',
                            value: task.taskType!,
                          ),
                        ],
                      ],
                    ),
                  ),

                // Team Section
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Team'),
                      const SizedBox(height: 16),
                      if (task.userName.isNotEmpty)
                        _buildRoleRow(
                          role: 'Assigned To',
                          name: task.userName,
                        ),
                      if (task.makerName.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildRoleRow(
                          role: 'Maker',
                          name: task.makerName,
                        ),
                      ],
                      if (task.checkerName.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildRoleRow(
                          role: 'Checker',
                          name: task.checkerName,
                        ),
                      ],
                      if (task.pcEngrName.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildRoleRow(
                          role: 'PC Engineer',
                          name: task.pcEngrName,
                        ),
                      ],
                      if (task.createdByName != null &&
                          task.createdByName!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildRoleRow(
                          role: 'Created By',
                          name: task.createdByName!,
                        ),
                      ],
                    ],
                  ),
                ),

                // Team Members
                if (task.teamMembers.isNotEmpty)
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                            'Team Members (${task.teamMembers.length})'),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: task.teamMembers.length,
                            separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final member = task.teamMembers[index];
                              return _buildTeamMemberCard(member);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                // Timeline
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Timeline'),
                      const SizedBox(height: 16),
                      if (task.taskRegisteredDate != null &&
                          task.taskRegisteredDate != '---')
                        _buildTimelineRow(
                          icon: Icons.event_available_rounded,
                          label: 'Registered',
                          value: task.taskRegisteredDate!,
                        ),
                      if (task.taskStartDate != null &&
                          task.taskStartDate != '---') ...[
                        const SizedBox(height: 12),
                        _buildTimelineRow(
                          icon: Icons.play_circle_outline_rounded,
                          label: 'Start Date',
                          value: task.taskStartDate!,
                        ),
                      ],
                      if (task.taskEndDate != null &&
                          task.taskEndDate != '---') ...[
                        const SizedBox(height: 12),
                        _buildTimelineRow(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'End Date',
                          value: task.taskEndDate!,
                        ),
                      ],
                      if (task.targetedDate != null &&
                          task.targetedDate != '---') ...[
                        const SizedBox(height: 12),
                        _buildTimelineRow(
                          icon: Icons.flag_circle_outlined,
                          label: 'Target Date',
                          value: task.targetedDate!,
                        ),
                      ],
                      if (task.dueDate != null && task.dueDate != '---') ...[
                        const SizedBox(height: 12),
                        _buildTimelineRow(
                          icon: Icons.schedule_rounded,
                          label: 'Due Date',
                          value: task.dueDate!,
                          isHighlight: true,
                        ),
                      ],
                    ],
                  ),
                ),

                // Prochat Information
                if (task.prochatTaskId != null)
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Prochat Information'),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Task ID',
                          value: task.prochatTaskId!,
                        ),
                        if (task.prochatRemark != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.shade100,
                              ),
                            ),
                            child: Text(
                              task.prochatRemark!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade900,
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

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade900,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.grey.shade700),
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
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'N/A',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
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
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(member) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
                color: Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: member.userProfileUrl != null
                  ? Image.network(
                member.userProfileUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildAvatarFallback(member.userName);
                },
              )
                  : _buildAvatarFallback(member.userName),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            member.userName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    return Container(
      color: Colors.blue.shade100,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade700,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlight ? Colors.orange.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighlight ? Colors.orange.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isHighlight ? Colors.orange.shade700 : Colors.grey.shade600,
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
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isHighlight
                        ? Colors.orange.shade900
                        : Colors.grey.shade900,
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