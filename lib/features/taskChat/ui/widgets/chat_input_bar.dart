// All hardcoded colours replaced with Theme.of(context).colorScheme tokens.
//
// Token map:
//   primary                → send button bg, attach icon, focus border, progress indicator
//   onPrimary              → send button icon
//   secondary              → mention chip border
//   secondaryContainer     → mention chip background
//   onSecondaryContainer   → mention chip text & delete icon
//   tertiary               → "mention required" warning text
//   error                  → remove-attachment button background
//   onError                → remove-attachment icon colour
//   surface                → input row background
//   surfaceContainerLow    → attachment strip background
//   surfaceContainerLowest → mentions row background
//   surfaceContainerHighest→ text field fill colour
//   onSurface              → text field text colour
//   onSurfaceVariant       → hint text, secondary icons, file icon
//   outlineVariant         → borders throughout
//   shadow                 → box-shadow base colour

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/taskchat/team_member.dart';
import '../../../../reusables/attachment_bottom_sheet.dart';
import '../../bloc/task_chat_bloc.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController messageController;
  final FocusNode focusNode;
  final VoidCallback onSend;

  const ChatInputBar({
    super.key,
    required this.messageController,
    required this.focusNode,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskChatBloc, TaskChatState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.selectedAttachments.isNotEmpty)
              _AttachmentPreviewStrip(attachments: state.selectedAttachments),
            _SelectedMentionsRow(mentions: state.selectedMentions),
            _InputRow(
              messageController: messageController,
              focusNode: focusNode,
              onSend: onSend,
              isSending: state.isSending,
            ),
          ],
        );
      },
    );
  }
}

// ─── Attachment Preview Strip ──────────────────────────────────────────────────

class _AttachmentPreviewStrip extends StatelessWidget {
  final List<dynamic> attachments;

  const _AttachmentPreviewStrip({required this.attachments});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${attachments.length} attachment(s) selected',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: attachments.length,
              itemBuilder: (context, index) =>
                  _AttachmentThumbnail(file: attachments[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentThumbnail extends StatelessWidget {
  final dynamic file;

  const _AttachmentThumbnail({required this.file});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fileName = (file.path as String).split('/').last;
    final isImage = ['.jpg', '.jpeg', '.png']
        .any((ext) => fileName.toLowerCase().endsWith(ext));

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Stack(
        children: [
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                file,
                fit: BoxFit.cover,
                width: 80,
                height: 80,
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insert_drive_file, color: cs.onSurfaceVariant),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 9, color: cs.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          Positioned(
            top: 2,
            right: 2,
            child: InkWell(
              onTap: () =>
                  context.read<TaskChatBloc>().add(RemoveAttachment(file)),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cs.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 12, color: cs.onError),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Selected Mentions Row ─────────────────────────────────────────────────────

class _SelectedMentionsRow extends StatelessWidget {
  final List<TeamMember> mentions;

  const _SelectedMentionsRow({required this.mentions});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: mentions.isEmpty
          ? Row(
        children: [
          Icon(Icons.alternate_email,
              size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            'Mention at least one member to send',
            style: TextStyle(
              fontSize: 12,
              color: cs.tertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      )
          : Wrap(
        spacing: 6,
        runSpacing: 4,
        children: mentions.map((member) {
          return Chip(
            label: Text(
              '@${member.userName}',
              style: TextStyle(
                  fontSize: 12, color: cs.onSecondaryContainer),
            ),
            deleteIcon: Icon(Icons.close,
                size: 14, color: cs.onSecondaryContainer),
            onDeleted: () => context
                .read<TaskChatBloc>()
                .add(RemoveMention(member.userId)),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: cs.secondaryContainer,
            side: BorderSide(color: cs.secondary),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Input Row ─────────────────────────────────────────────────────────────────

class _InputRow extends StatelessWidget {
  final TextEditingController messageController;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool isSending;

  const _InputRow({
    required this.messageController,
    required this.focusNode,
    required this.onSend,
    required this.isSending,
  });

  void _pickAttachment(BuildContext context) {
    AttachmentBottomSheet.show(
      context,
      onCameraPressed: () =>
          context.read<TaskChatBloc>().add(const PickFromCamera()),
      onGalleryPressed: () =>
          context.read<TaskChatBloc>().add(const PickFromGallery()),
      onDocumentsPressed: () =>
          context.read<TaskChatBloc>().add(const PickDocuments()),
    );
  }

  void _insertAtSymbol(BuildContext context) {
    final cursorPos = messageController.selection.baseOffset;
    if (cursorPos < 0) return;
    final current = messageController.text;
    messageController.value = TextEditingValue(
      text: current.substring(0, cursorPos) +
          '@' +
          current.substring(cursorPos),
      selection: TextSelection.collapsed(offset: cursorPos + 1),
    );
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── Attach ──────────────────────────────────────────────────────
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () => _pickAttachment(context),
              color: cs.primary,
              tooltip: 'Add attachment',
            ),

            // ── Text field ───────────────────────────────────────────────────
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: TextField(
                  controller: messageController,
                  focusNode: focusNode,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(color: cs.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle:
                    TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                      BorderSide(color: cs.outlineVariant, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                      BorderSide(color: cs.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.alternate_email,
                          size: 20, color: cs.onSurfaceVariant),
                      onPressed: () => _insertAtSymbol(context),
                      tooltip: 'Mention someone',
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // ── Send / loading ───────────────────────────────────────────────
            isSending
                ? SizedBox(
              width: 48,
              height: 48,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.primary,
                ),
              ),
            )
                : SizedBox(
              width: 48,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onSend,
                  icon: Icon(Icons.send, size: 20, color: cs.onPrimary),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}