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
    return Align(
      alignment: Alignment.centerLeft,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: Text(
          _texts[_index],
          key: ValueKey(_texts[_index]),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}