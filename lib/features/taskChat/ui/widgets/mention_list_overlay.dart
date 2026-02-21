import 'package:flutter/material.dart';
import '../../../../core/models/taskchat/team_member.dart';

class MentionListOverlay extends StatelessWidget {
  final List<TeamMember> members;
  final ValueChanged<TeamMember> onSelected;
  final VoidCallback onDismiss;

  const MentionListOverlay({
    super.key,
    required this.members,
    required this.onSelected,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
            child: Row(
              children: [
                Text(
                  'Mention a team member',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: cs.onSurfaceVariant),
                  onPressed: onDismiss,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final initial = member.userName.isNotEmpty
                    ? member.userName[0].toUpperCase()
                    : '?';
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      initial,
                      style: textTheme.labelSmall?.copyWith(
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(
                    member.userName,
                    style: textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    member.role,
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  onTap: () => onSelected(member),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}