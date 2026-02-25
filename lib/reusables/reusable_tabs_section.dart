import 'package:flutter/material.dart';

class ReusableTabsSection extends StatefulWidget {
  final List<Tab> tabs;
  final List<Widget> views;
  final ValueChanged<int>? onTabChanged;
  final List<int>? tabCounts;
  final double? height;

  const ReusableTabsSection({
    super.key,
    required this.tabs,
    required this.views,
    this.onTabChanged,
    this.tabCounts,
    this.height, // null = Expanded mode, value = fixed height mode
  });

  @override
  State<ReusableTabsSection> createState() => _ReusableTabsSectionState();
}

class _ReusableTabsSectionState extends State<ReusableTabsSection>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: widget.tabs.length, vsync: this);
    _controller.addListener(() {
      if (!_controller.indexIsChanging) {
        widget.onTabChanged?.call(_controller.index);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildTabWithCount(Tab tab, int? count, bool isSelected) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (count == null) return tab;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tab.icon != null) ...[
          tab.icon!,
          const SizedBox(width: 4),
        ],
        if (tab.text != null)
          Flexible(
            child: Text(
              tab.text!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else if (tab.child != null)
          Flexible(child: tab.child!),

        if (count > 0) ...[
          const SizedBox(width: 5),
          Text(
            '($count)',
            style: TextStyle(
              color: isSelected
                  ? theme.primaryColor
                  : (isDark ? Colors.grey[500] : Colors.grey[500]),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTabBar(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _controller,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: isDark ? Colors.grey[700] : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: theme.primaryColor,
        unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.zero,
        tabs: List.generate(
          widget.tabs.length,
              (index) {
            final tab = widget.tabs[index];
            final count = widget.tabCounts != null &&
                index < widget.tabCounts!.length
                ? widget.tabCounts![index]
                : null;

            return Tab(
              height: 36,
              child: _buildTabWithCount(
                tab,
                count,
                _controller.index == index,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tabBarView = TabBarView(
      controller: _controller,
      children: widget.views,
    );

    // ── Mode 1: Fixed height ─────────────────────────────────────────────────
    if (widget.height != null) {
      return Column(
        children: [
          _buildTabBar(theme, isDark),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 100,
              maxHeight: widget.height!,
            ),
            child: tabBarView,
          ),
        ],
      );
    }

    // ── Mode 2: Expanded (no height param) ───────────────────────────────────
    return Column(
      children: [
        _buildTabBar(theme, isDark),
        const SizedBox(height: 16),
        Expanded(child: tabBarView),
      ],
    );
  }
}