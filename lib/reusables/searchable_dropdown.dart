import 'package:flutter/material.dart';

/// A reusable searchable dropdown for single item selection
///
/// Usage:
/// ```dart
/// SearchableDropdown<User>(
///   label: 'Select User',
///   hint: 'Choose a user',
///   icon: Icons.person,
///   items: users,
///   selectedItem: selectedUser,
///   itemAsString: (user) => user.name,
///   onChanged: (user) {
///     setState(() => selectedUser = user);
///   },
/// )
/// ```
class SearchableDropdown<T> extends StatefulWidget {
  /// Label text displayed above the dropdown
  final String label;

  /// Hint text shown when no item is selected
  final String hint;

  /// Icon displayed on the left side
  final IconData icon;

  /// List of items to display
  final List<T> items;

  /// Currently selected item
  final T? selectedItem;

  /// Callback when an item is selected
  final ValueChanged<T?> onChanged;

  /// Function to convert item to string for display
  final String Function(T) itemAsString;

  /// Whether the dropdown is enabled
  final bool isEnabled;

  /// Whether to show loading indicator
  final bool isLoading;

  /// Whether to show clear button
  final bool showClear;

  /// Validator function
  final String? Function(T?)? validator;

  /// Whether this is a required field
  final bool isRequired;

  /// Custom search filter function (optional)
  final bool Function(T item, String query)? searchFilter;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.itemAsString,
    this.isEnabled = true,
    this.isLoading = false,
    this.showClear = true,
    this.validator,
    this.isRequired = false,
    this.searchFilter,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void didUpdateWidget(SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          if (widget.searchFilter != null) {
            return widget.searchFilter!(item, query);
          }
          return widget
              .itemAsString(item)
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showSearchDialog() {
    _searchController.clear();
    _filteredItems = widget.items;

    showDialog<T>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.icon,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.label,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    // Search Field
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    setDialogState(() {
                                      _searchController.clear();
                                      _filterItems('');
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setDialogState(() {
                            _filterItems(value);
                          });
                        },
                      ),
                    ),

                    // Items List
                    Flexible(
                      child: _filteredItems.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No items found',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                final isSelected = widget.selectedItem == item;

                                return ListTile(
                                  selected: isSelected,
                                  selectedTileColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1),
                                  leading: isSelected
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        )
                                      : Icon(
                                          Icons.radio_button_unchecked,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withOpacity(0.5),
                                        ),
                                  title: Text(
                                    widget.itemAsString(item),
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context, item);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((selectedItem) {
      if (selectedItem != null) {
        widget.onChanged(selectedItem);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              widget.label,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (widget.isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Drop-Down Field
        InkWell(
          onTap: widget.isEnabled && !widget.isLoading
              ? _showSearchDialog
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: widget.isEnabled
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              boxShadow: widget.isEnabled
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: widget.isEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.selectedItem != null
                        ? widget.itemAsString(widget.selectedItem as T)
                        : widget.hint,
                    style: TextStyle(
                      color: widget.selectedItem != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (widget.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (widget.showClear && widget.selectedItem != null)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: widget.isEnabled
                          ? () => widget.onChanged(null)
                          : null,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.clear, size: 20),
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),

        // Validation Error
        if (widget.validator != null)
          Builder(
            builder: (context) {
              final error = widget.validator!(widget.selectedItem);
              if (error != null) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }
}
