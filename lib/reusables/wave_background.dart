// ─────────────────────────────────────────────────────────────────────────────
//  Wave Painter  (ported from ProChatWaveBackground.kt)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class _WavePainter extends CustomPainter {
  final Color  primaryColor;
  final double primaryWaveControl;
  final double secondaryWaveControl;
  final double wavePosition;
  final double primaryWaveAlpha;
  final double secondaryWaveAlpha;

  const _WavePainter({
    required this.primaryColor,
    required this.primaryWaveControl,
    required this.secondaryWaveControl,
    required this.wavePosition,
    required this.primaryWaveAlpha,
    required this.secondaryWaveAlpha,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final primaryWaveY   = size.height * wavePosition;
    final secondaryWaveY = size.height * (wavePosition + 0.10);
    final highlightY     = size.height * (wavePosition + 0.08);

    // Primary wave
    final primaryPath = Path()
      ..moveTo(0, primaryWaveY)
      ..cubicTo(
        size.width * 0.25, primaryWaveY + size.height * (primaryWaveControl * 0.10),
        size.width * 0.70, primaryWaveY - size.height * (primaryWaveControl * 0.10),
        size.width,        primaryWaveY + size.height * (primaryWaveControl * 0.05),
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      primaryPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [
            primaryColor.withOpacity(primaryWaveAlpha / 2),
            primaryColor.withOpacity(primaryWaveAlpha),
          ],
        ).createShader(
          Rect.fromLTWH(0, primaryWaveY, size.width, size.height - primaryWaveY),
        ),
    );

    // Secondary wave
    final secondaryPath = Path()
      ..moveTo(0, secondaryWaveY)
      ..cubicTo(
        size.width * 0.35, secondaryWaveY - size.height * (secondaryWaveControl * 0.08),
        size.width * 0.65, secondaryWaveY + size.height * (secondaryWaveControl * 0.08),
        size.width,        secondaryWaveY - size.height * (secondaryWaveControl * 0.04),
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      secondaryPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [
            primaryColor.withOpacity(secondaryWaveAlpha / 2),
            primaryColor.withOpacity(secondaryWaveAlpha),
          ],
        ).createShader(
          Rect.fromLTWH(0, secondaryWaveY, size.width, size.height - secondaryWaveY),
        ),
    );

    // Highlight stroke
    final highlightPath = Path()
      ..moveTo(0, highlightY)
      ..cubicTo(
        size.width * 0.30, highlightY + size.height * (secondaryWaveControl * 0.06),
        size.width * 0.60, highlightY - size.height * (secondaryWaveControl * 0.06),
        size.width,        highlightY + size.height * (secondaryWaveControl * 0.03),
      );

    canvas.drawPath(
      highlightPath,
      Paint()
        ..color       = Colors.white.withOpacity(0.30)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.primaryWaveControl   != primaryWaveControl   ||
          old.secondaryWaveControl != secondaryWaveControl ||
          old.wavePosition         != wavePosition;
}

// ─────────────────────────────────────────────────────────────────────────────
//  ProChatWaveBackground
// ─────────────────────────────────────────────────────────────────────────────

class ProChatWaveBackground extends StatefulWidget {
  final Color  primaryColor;
  final double wavePosition;
  final double primaryWaveAlpha;
  final double secondaryWaveAlpha;
  final Widget child;

  const ProChatWaveBackground({
    super.key,
    required this.primaryColor,
    this.wavePosition       = 0.75,
    this.primaryWaveAlpha   = 0.30,
    this.secondaryWaveAlpha = 0.35,
    required this.child,
  });

  @override
  State<ProChatWaveBackground> createState() => _ProChatWaveBackgroundState();
}

class _ProChatWaveBackgroundState extends State<ProChatWaveBackground>
    with TickerProviderStateMixin {

  late final AnimationController _primaryCtrl;
  late final AnimationController _secondaryCtrl;
  late final Animation<double>   _primaryAnim;
  late final Animation<double>   _secondaryAnim;

  @override
  void initState() {
    super.initState();
    _primaryCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
    _secondaryCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 5000),
    )..repeat(reverse: true);
    _primaryAnim = Tween<double>(begin: 0.2, end: 0.4).animate(
      CurvedAnimation(parent: _primaryCtrl, curve: Curves.fastOutSlowIn),
    );
    _secondaryAnim = Tween<double>(begin: 0.3, end: 0.5).animate(
      CurvedAnimation(parent: _secondaryCtrl, curve: Curves.fastOutSlowIn),
    );
  }

  @override
  void dispose() {
    _primaryCtrl.dispose();
    _secondaryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_primaryAnim, _secondaryAnim]),
      child: widget.child,
      builder: (context, child) => CustomPaint(
        painter: _WavePainter(
          primaryColor:         widget.primaryColor,
          primaryWaveControl:   _primaryAnim.value,
          secondaryWaveControl: _secondaryAnim.value,
          wavePosition:         widget.wavePosition,
          primaryWaveAlpha:     widget.primaryWaveAlpha,
          secondaryWaveAlpha:   widget.secondaryWaveAlpha,
        ),
        child: child,
      ),
    );
  }
}