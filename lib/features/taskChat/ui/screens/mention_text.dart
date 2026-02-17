import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MentionText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? mentionStyle;
  final Function(String)? onMentionTap;

  const MentionText({
    super.key,
    required this.text,
    this.style,
    this.mentionStyle,
    this.onMentionTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = style ?? const TextStyle(fontSize: 14);
    final defaultMentionStyle = mentionStyle ??
        TextStyle(
          fontSize: 14,
          color: Colors.blue[700],
          fontWeight: FontWeight.w600,
        );

    // Parse text for mentions (@username)
    final List<InlineSpan> spans = [];
    final RegExp mentionRegex = RegExp(r'@(\w+(?:\s+\w+)*)');
    int lastMatchEnd = 0;

    for (final match in mentionRegex.allMatches(text)) {
      // Add text before mention
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: defaultStyle,
          ),
        );
      }

      // Add mention
      final mentionText = match.group(0)!;
      spans.add(
        TextSpan(
          text: mentionText,
          style: defaultMentionStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (onMentionTap != null) {
                onMentionTap!(mentionText);
              }
            },
        ),
      );

      lastMatchEnd = match.end;
    }

    // Add remaining text
    if (lastMatchEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastMatchEnd),
          style: defaultStyle,
        ),
      );
    }

    if (spans.isEmpty) {
      return Text(text, style: defaultStyle);
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}