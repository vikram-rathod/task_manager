import 'package:flutter/material.dart';

class HeaderTextAnimation extends StatefulWidget {
  final String designation;
  final String companyText;

  const HeaderTextAnimation({
    super.key,
    required this.designation,
    required this.companyText,
  });

  @override
  State<HeaderTextAnimation> createState() => _HeaderTextAnimationState();
}

class _HeaderTextAnimationState extends State<HeaderTextAnimation> {
  late List<String> _texts;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _texts = [widget.designation, widget.companyText];
    _loop();
  }

  @override
  void didUpdateWidget(HeaderTextAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.designation != widget.designation ||
        oldWidget.companyText != widget.companyText) {
      setState(() {
        _texts = [widget.designation, widget.companyText];
      });
    }
  }

  void _loop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _index = (_index + 1) % _texts.length;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
            return Stack(
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.hardEdge,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (Widget child, Animation<double> animation) {
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: child,
                ),
              ),
            );
          },
          child: Container(
            key: ValueKey<String>(_texts[_index]),
            alignment: Alignment.centerLeft,
            constraints: const BoxConstraints(
              minWidth: 0,
              maxWidth: double.infinity,
            ),
            child: Text(
              _texts[_index],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}