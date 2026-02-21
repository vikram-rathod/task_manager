import 'package:flutter/material.dart';
import '../../../../core/models/taskchat/team_member.dart';

/// Shows a dialog listing all team members for the current task.
Future<void> showTeamMembersDialog(
    BuildContext context, List<TeamMember> members) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Team Members'),
      content: SizedBox(
        width: double.maxFinite,
        child: members.isEmpty
            ? const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No team members available'),
        )
            : ListView.builder(
          shrinkWrap: true,
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final initial = member.userName.isNotEmpty
                ? member.userName[0].toUpperCase()
                : '?';
            return ListTile(
              leading: CircleAvatar(child: Text(initial)),
              title: Text(member.userName.isNotEmpty
                  ? member.userName
                  : 'Unknown'),
              subtitle: Text(member.role),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}