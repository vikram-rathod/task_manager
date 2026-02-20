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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          return Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.hardEdge,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Determine direction: incoming slides up from bottom, outgoing slides out to top
          final isIncoming = animation.status == AnimationStatus.forward ||
              animation.status == AnimationStatus.completed;

          final slideIn = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

          final slideOut = Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInCubic));

          final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeIn),
          );

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: isIncoming ? slideIn : slideOut,
              child: Align(
                alignment: Alignment.centerLeft,
                child: child,
              ),
            ),
          );
        },
        child: SizedBox(
          key: ValueKey<String>(_texts[_index]),
          width: double.infinity,
          child: _MarqueeText(
            text: _texts[_index],
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double velocity; // pixels per second
  final Duration pauseDuration;

  const _MarqueeText({
    required this.text,
    required this.style,
    this.velocity = 40,
    this.pauseDuration = const Duration(seconds: 1),
  });

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _needsScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startMarquee());
  }

  @override
  void didUpdateWidget(_MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _scrollController.jumpTo(0);
      WidgetsBinding.instance.addPostFrameCallback((_) => _startMarquee());
    }
  }

  Future<void> _startMarquee() async {
    if (!mounted) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) {
      setState(() => _needsScroll = false);
      return;
    }

    setState(() => _needsScroll = true);

    while (mounted) {
      // Pause at start
      await Future.delayed(widget.pauseDuration);
      if (!mounted) break;

      // Scroll to end
      final duration = Duration(
        milliseconds: ((maxScroll / widget.velocity) * 1000).toInt(),
      );
      await _scrollController.animateTo(
        maxScroll,
        duration: duration,
        curve: Curves.linear,
      );
      if (!mounted) break;

      await Future.delayed(widget.pauseDuration);
      if (!mounted) break;

      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              Text(
                widget.text,
                style: widget.style,
                maxLines: 1,
              ),
              if (_needsScroll) const SizedBox(width: 24),
            ],
          ),
        );
      },
    );
  }
}