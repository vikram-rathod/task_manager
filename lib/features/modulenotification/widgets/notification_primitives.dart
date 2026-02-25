import 'package:flutter/material.dart';

import '../notification_design_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Meta entry data class
// ─────────────────────────────────────────────────────────────────────────────

class NotificationMetaEntry {
  final String key;
  final String value;
  const NotificationMetaEntry(this.key, this.value);
}

// ─────────────────────────────────────────────────────────────────────────────
// MetaGrid — inline key · value pairs
// ─────────────────────────────────────────────────────────────────────────────

class NotificationMetaGrid extends StatelessWidget {
  final List<NotificationMetaEntry> entries;

  const NotificationMetaGrid({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: NotificationDt.sp16,
      runSpacing: NotificationDt.sp4,
      children: entries
          .map(
            (e) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${e.key} ',
              style: TextStyle(
                fontSize: 12,
                color: ntfInk2(context).withOpacity(0.55),
              ),
            ),
            Text(
              e.value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ntfInk2(context),
              ),
            ),
          ],
        ),
      )
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QuoteBlock — mention message container
// ─────────────────────────────────────────────────────────────────────────────

class NotificationQuoteBlock extends StatelessWidget {
  final String message;
  final String? timestamp;
  final Color accentColor;
  final String username;

  const NotificationQuoteBlock({
    super.key,
    required this.message,
    required this.timestamp,
    required this.accentColor,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        NotificationDt.sp12,
        NotificationDt.sp8,
        NotificationDt.sp12,
        NotificationDt.sp8,
      ),
      decoration: BoxDecoration(
        color: ntfSurfaceAlt(context),
        borderRadius: BorderRadius.circular(NotificationDt.r8),
        border: Border(left: BorderSide(color: accentColor, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username header
          if (username.isNotEmpty)
            Row(
              children: [
                Icon(Icons.person_rounded, size: 12, color: accentColor),
                const SizedBox(width: 4),
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          const SizedBox(height: NotificationDt.sp4),

          // Message
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: ntfInk2(context),
            ),
          ),

          // Timestamp
          if (timestamp?.isNotEmpty ?? false) ...[
            const SizedBox(height: NotificationDt.sp4),
            Text(
              timestamp!,
              style: TextStyle(
                fontSize: 11,
                color: ntfInk2(context).withOpacity(0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RemarkBox — remark / note display
// ─────────────────────────────────────────────────────────────────────────────

class NotificationRemarkBox extends StatelessWidget {
  final String remark;

  const NotificationRemarkBox({super.key, required this.remark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(NotificationDt.sp12),
      decoration: BoxDecoration(
        color: ntfSurfaceAlt(context),
        borderRadius: BorderRadius.circular(NotificationDt.r8),
        border: Border.all(color: ntfBorder(context)),
      ),
      child: Text(
        remark,
        style: TextStyle(
          fontSize: 12,
          height: 1.6,
          color: ntfInk2(context),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PillLabel — status old → new pill
// ─────────────────────────────────────────────────────────────────────────────

class NotificationPillLabel extends StatelessWidget {
  final String label;
  final Color color;

  const NotificationPillLabel(this.label, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NotificationDt.sp8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NameTag — avatar + name for checker change
// ─────────────────────────────────────────────────────────────────────────────

class NotificationNameTag extends StatelessWidget {
  final String name;
  final Color color;

  const NotificationNameTag(this.name, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: color.withOpacity(0.1),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: ntfInk(context),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// StatusBadge — Completed · Cancelled · Hold (+ generic fallback)
// ─────────────────────────────────────────────────────────────────────────────

class _BadgeStyle {
  final Color color;
  final IconData icon;
  const _BadgeStyle({required this.color, required this.icon});
}

class NotificationStatusBadge extends StatelessWidget {
  final String status;

  const NotificationStatusBadge({super.key, required this.status});

  static const _amber = Color(0xFFD97706);

  _BadgeStyle get _style => switch (status) {
    'Completed' => const _BadgeStyle(
      color: NotificationDt.positive,
      icon: Icons.check_circle_outline_rounded,
    ),
    'Cancelled' => const _BadgeStyle(
      color: NotificationDt.negative,
      icon: Icons.cancel_outlined,
    ),
    'Hold' => const _BadgeStyle(
      color: _amber,
      icon: Icons.pause_circle_outline_rounded,
    ),
    _ => const _BadgeStyle(
      color: NotificationDt.dotDefault,
      icon: Icons.info_outline_rounded,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: s.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: s.color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 11, color: s.color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: s.color,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}