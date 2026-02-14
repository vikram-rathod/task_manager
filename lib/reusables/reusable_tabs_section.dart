import 'package:flutter/material.dart';

class ReusableTabsSection extends StatefulWidget {
  final List<Tab> tabs;
  final List<Widget> views;
  final ValueChanged<int>? onTabChanged;
  final List<int>? tabCounts; // Optional counts for each tab

  const ReusableTabsSection({
    super.key,
    required this.tabs,
    required this.views,
    this.onTabChanged,
    this.tabCounts,
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

    _controller = TabController(
      length: widget.tabs.length,
      vsync: this,
    );

    _controller.addListener(() {
      if (!_controller.indexIsChanging) {
        widget.onTabChanged?.call(_controller.index);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Build tab with optional count badge
  Widget _buildTabWithCount(Tab tab, int? count, bool isSelected) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // If no counts provided or count is null, return original tab
    if (count == null) {
      return tab;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 2),
        // Original tab content
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

        // Show count badge only if count > 0
        if (count > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.primaryColor.withOpacity(0.2)
                  : (isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey[300]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: isSelected
                    ? theme.primaryColor
                    : (isDark ? Colors.white70 : Colors.grey[700]),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        SizedBox(width: 2)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _controller,
            dividerColor: Colors.transparent,
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
            unselectedLabelColor:
            isDark ? Colors.grey[400] : Colors.grey[600],
            tabs: List.generate(
              widget.tabs.length,
                  (index) {
                final tab = widget.tabs[index];
                final count = widget.tabCounts != null &&
                    index < widget.tabCounts!.length
                    ? widget.tabCounts![index]
                    : null;

                return Tab(
                  child: _buildTabWithCount(
                    tab,
                    count,
                    _controller.index == index,
                  ),

                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: TabBarView(
            controller: _controller,
            children: widget.views,
          ),
        ),
      ],
    );
  }
}