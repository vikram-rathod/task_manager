import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/taskchat/chat_data.dart';
import '../../bloc/task_chat_bloc.dart';

class ReplyPreviewBanner extends StatelessWidget {
  final ChatData replyTo;
  final VoidCallback onTap;

  const ReplyPreviewBanner({
    super.key,
    required this.replyTo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withOpacity(0.3),
          border: Border(top: BorderSide(color: cs.primary.withOpacity(0.3))),
        ),
        child: Row(
          children: [
            // ── Accent bar ───────────────────────────────────────────────────
            Container(
              width: 3,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // ── Reply content ────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Replying to ${replyTo.userName}',
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    replyTo.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // ── Dismiss button ───────────────────────────────────────────────
            IconButton(
              icon: Icon(Icons.close, size: 18, color: cs.onSurfaceVariant),
              onPressed: () =>
                  context.read<TaskChatBloc>().add(const ClearReplyTo()),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}