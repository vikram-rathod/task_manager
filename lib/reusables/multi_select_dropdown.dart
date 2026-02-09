import 'package:flutter/material.dart';

/// A reusable searchable dropdown for multiple item selection
/// 
/// Usage:
/// ```dart
/// MultiSelectDropdown<User>(
///   label: 'Select Users',
///   hint: 'Choose users',
///   icon: Icons.people,
///   items: users,
///   selectedItems: selectedUsers,
///   itemAsString: (user) => user.name,
///   onChanged: (users) {
///     setState(() => selectedUsers = users);
///   },
/// )
/// ```
class MultiSelectDropdown<T> extends StatefulWidget {
  /// Label text displayed above the dropdown
  final String label;
  
  /// Hint text shown when no items are selected
  final String hint;
  
  /// Icon displayed on the left side
  final IconData icon;
  
  /// List of items to display
  final List<T> items;
  
  /// Currently selected items
  final List<T> selectedItems;
  
  /// Callback when items are selected
  final ValueChanged<List<T>> onChanged;
  
  /// Function to convert item to string for display
  final String Function(T) itemAsString;
  
  /// Whether the dropdown is enabled
  final bool isEnabled;
  
  /// Whether to show loading indicator
  final bool isLoading;
  
  /// Whether to show clear button
  final bool showClear;
  
  /// Validator function
  final String? Function(List<T>)? validator;
  
  /// Whether this is a required field
  final bool isRequired;
  
  /// Custom search filter function (optional)
  final bool Function(T item, String query)? searchFilter;
  
  /// Maximum number of items that can be selected (null = unlimited)
  final int? maxSelection;
  
  /// Show selected count in the field
  final bool showSelectedCount;

  const MultiSelectDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    required this.itemAsString,
    this.isEnabled = true,
    this.isLoading = false,
    this.showClear = true,
    this.validator,
    this.isRequired = false,
    this.searchFilter,
    this.maxSelection,
    this.showSelectedCount = true,
  });

  @override
  State<MultiSelectDropdown<T>> createState() => _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];
  late List<T> _tempSelectedItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _tempSelectedItems = List.from(widget.selectedItems);
  }

  @override
  void didUpdateWidget(MultiSelectDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
      _searchController.clear();
    }
    if (oldWidget.selectedItems != widget.selectedItems) {
      _tempSelectedItems = List.from(widget.selectedItems);
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
          return widget.itemAsString(item)
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showSearchDialog() {
    _searchController.clear();
    _filteredItems = widget.items;
    _tempSelectedItems = List.from(widget.selectedItems);

    showDialog<List<T>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final canSelectMore = widget.maxSelection == null ||
                _tempSelectedItems.length < widget.maxSelection!;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 650),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(widget.icon,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    if (_tempSelectedItems.isNotEmpty)
                                      Text(
                                        '${_tempSelectedItems.length} selected${widget.maxSelection != null ? ' (max ${widget.maxSelection})' : ''}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Selected Items Chips (if any)
                    if (_tempSelectedItems.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceVariant
                              .withOpacity(0.3),
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.2),
                            ),
                          ),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tempSelectedItems.map((item) {
                            return Chip(
                              label: Text(
                                widget.itemAsString(item),
                                style: const TextStyle(fontSize: 12),
                              ),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setDialogState(() {
                                  _tempSelectedItems.remove(item);
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
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
                                  icon: const Icon(Icons.clear),
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
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
                                final isSelected = _tempSelectedItems.contains(item);
                                final canToggle = isSelected || canSelectMore;

                                return ListTile(
                                  enabled: canToggle,
                                  selected: isSelected,
                                  selectedTileColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  leading: Checkbox(
                                    value: isSelected,
                                    onChanged: canToggle
                                        ? (bool? value) {
                                            setDialogState(() {
                                              if (value == true) {
                                                if (canSelectMore) {
                                                  _tempSelectedItems.add(item);
                                                }
                                              } else {
                                                _tempSelectedItems.remove(item);
                                              }
                                            });
                                          }
                                        : null,
                                  ),
                                  title: Text(
                                    widget.itemAsString(item),
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  onTap: canToggle
                                      ? () {
                                          setDialogState(() {
                                            if (isSelected) {
                                              _tempSelectedItems.remove(item);
                                            } else if (canSelectMore) {
                                              _tempSelectedItems.add(item);
                                            }
                                          });
                                        }
                                      : null,
                                );
                              },
                            ),
                    ),

                    // Action Buttons
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.2),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (_tempSelectedItems.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                setDialogState(() {
                                  _tempSelectedItems.clear();
                                });
                              },
                              icon: const Icon(Icons.clear_all),
                              label: const Text('Clear All'),
                            ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, _tempSelectedItems);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((selectedItems) {
      if (selectedItems != null) {
        widget.onChanged(selectedItems);
      }
    });
  }

  String _getDisplayText() {
    if (widget.selectedItems.isEmpty) {
      return widget.hint;
    }
    
    if (widget.showSelectedCount) {
      return '${widget.selectedItems.length} selected';
    }
    
    if (widget.selectedItems.length == 1) {
      return widget.itemAsString(widget.selectedItems.first);
    }
    
    return widget.selectedItems
        .take(2)
        .map((item) => widget.itemAsString(item))
        .join(', ') +
        (widget.selectedItems.length > 2
            ? ' +${widget.selectedItems.length - 2} more'
            : '');
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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

        // Dropdown Field
        InkWell(
          onTap: widget.isEnabled && !widget.isLoading ? _showSearchDialog : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: widget.isEnabled
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
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
                      : Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.5),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _getDisplayText(),
                    style: TextStyle(
                      color: widget.selectedItems.isNotEmpty
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
                else if (widget.showClear && widget.selectedItems.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: widget.isEnabled
                        ? () => widget.onChanged([])
                        : null,
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

        // Selected Items Preview (chips below field)
        if (widget.selectedItems.isNotEmpty && !widget.showSelectedCount)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.selectedItems.take(5).map((item) {
                return Chip(
                  label: Text(
                    widget.itemAsString(item),
                    style: const TextStyle(fontSize: 11),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: widget.isEnabled
                      ? () {
                          final updatedList = List<T>.from(widget.selectedItems)
                            ..remove(item);
                          widget.onChanged(updatedList);
                        }
                      : null,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              }).toList()
                ..addAll(
                  widget.selectedItems.length > 5
                      ? [
                          Chip(
                            label: Text(
                              '+${widget.selectedItems.length - 5} more',
                              style: const TextStyle(fontSize: 11),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ]
                      : [],
                ),
            ),
          ),

        // Validation Error
        if (widget.validator != null)
          Builder(
            builder: (context) {
              final error = widget.validator!(widget.selectedItems);
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
