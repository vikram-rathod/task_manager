import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  HomeBottomNav
// ─────────────────────────────────────────────
class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              color: cs.surface,
              elevation: 0,
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.cottage_outlined,
                      activeIcon: Icons.cottage,
                      label: 'Home',
                      isSelected: currentIndex == 0,
                      onTap: () => onTap(0),
                      cs: cs,
                    ),
                    const SizedBox(width: 72),
                    _NavItem(
                      icon: Icons.fact_check_outlined,
                      activeIcon: Icons.fact_check,
                      label: 'Tasks',
                      isSelected: currentIndex == 1,
                      onTap: () => onTap(1),
                      cs: cs,
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _WaveBorderPainter(
                    borderColor: cs.primary.withOpacity(0.3),
                    borderWidth: 1.5,
                    centerX: screenWidth / 2,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WaveBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double centerX;

  // Constants
  static const double _waveWidth  = 90.0;  // half-spread from center
  static const double _waveDepth  = 40.0;  // dip depth (downward = into bar)
  static const double _cp1Offset  = 45.0;  // outer bezier control x
  static const double _cp2Offset  = 45.0;  // inner bezier control x

  _WaveBorderPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.centerX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = centerX;
    final double y0 = 0;

    final double dip = _waveDepth;

    final path = Path()
    // Left flat
      ..moveTo(0, y0)
      ..lineTo(cx - _waveWidth, y0)

      ..cubicTo(
        cx - _cp1Offset, y0,
        cx - _cp2Offset, dip,
        cx,               dip,
      )

      ..cubicTo(
        cx + _cp2Offset, dip,
        cx + _cp1Offset, y0,
        cx + _waveWidth, y0,
      )

    // Right flat
      ..lineTo(size.width, y0);

    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..strokeWidth = borderWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_WaveBorderPainter old) =>
      old.borderColor != borderColor ||
          old.borderWidth != borderWidth ||
          old.centerX != centerX;
}

// ─────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.cs,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _activeFade;
  late final Animation<double> _inactiveFade;
  late final Animation<Color?> _labelColor;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: widget.isSelected ? 1.0 : 0.0,
    );

    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _activeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );
    _inactiveFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _labelColor = ColorTween(
      begin: widget.cs.onSurfaceVariant,
      end: widget.cs.primary,
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    if (widget.isSelected != old.isSelected) {
      widget.isSelected ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => SizedBox(
                width: 28,
                height: 28,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    FadeTransition(
                      opacity: _inactiveFade,
                      child: Icon(widget.icon,
                          color: widget.cs.onSurfaceVariant, size: 24),
                    ),
                    FadeTransition(
                      opacity: _activeFade,
                      child: ScaleTransition(
                        scale: _scale,
                        child: Icon(widget.activeIcon,
                            color: widget.cs.primary, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedBuilder(
              animation: _labelColor,
              builder: (_, __) => Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                  widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: _labelColor.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}