import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────

class NotificationDt {
  NotificationDt._();

  // Neutral palette — light
  static const Color ink = Color(0xFF111827);
  static const Color ink2 = Color(0xFF6B7280);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF9FAFB);
  static const Color border = Color(0xFFE5E7EB);

  // Neutral palette — dark
  static const Color inkDark = Color(0xFFF3F4F6);
  static const Color ink2Dark = Color(0xFF9CA3AF);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color surfaceAltDark = Color(0xFF2C2C2E);
  static const Color borderDark = Color(0xFF3A3A3C);

  // Single interactive accent
  static const Color accent = Color(0xFF2563EB);

  // Semantic
  static const Color positive = Color(0xFF16A34A);
  static const Color negative = Color(0xFFDC2626);

  // Per-type indicator dots
  static const Color dotAction = Color(0xFFDC2626);
  static const Color dotNew = Color(0xFF2563EB);
  static const Color dotCheckerPending = Color(0xFFD97706);
  static const Color dotInProgress = Color(0xFF2563EB);
  static const Color dotStatusChange = Color(0xFF7C3AED);
  static const Color dotCheckerChange = Color(0xFF0891B2);
  static const Color dotMention = Color(0xFF059669);
  static const Color dotDefault = Color(0xFF6B7280);

  // Spacing
  static const double sp4 = 4;
  static const double sp8 = 8;
  static const double sp12 = 12;
  static const double sp16 = 16;
  static const double sp20 = 20;
  static const double sp24 = 24;

  // Radii
  static const double r4 = 4;
  static const double r8 = 8;
  static const double r12 = 12;
}

// ─────────────────────────────────────────────────────────────────────────────
// Context colour helpers  (free functions — import anywhere)
// ─────────────────────────────────────────────────────────────────────────────

bool ntfIsDark(BuildContext ctx) =>
    Theme.of(ctx).brightness == Brightness.dark;

Color ntfSurface(BuildContext ctx) =>
    ntfIsDark(ctx) ? NotificationDt.surfaceDark : NotificationDt.surface;

Color ntfSurfaceAlt(BuildContext ctx) =>
    ntfIsDark(ctx) ? NotificationDt.surfaceAltDark : NotificationDt.surfaceAlt;

Color ntfInk(BuildContext ctx) =>
    ntfIsDark(ctx) ? NotificationDt.inkDark : NotificationDt.ink;

Color ntfInk2(BuildContext ctx) =>
    ntfIsDark(ctx) ? NotificationDt.ink2Dark : NotificationDt.ink2;

Color ntfBorder(BuildContext ctx) =>
    ntfIsDark(ctx) ? NotificationDt.borderDark : NotificationDt.border;