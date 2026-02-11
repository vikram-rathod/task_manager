import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';

class QuickActionSection extends StatelessWidget {
  const QuickActionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (p, c) =>
          p.quickActions != c.quickActions ||
          p.isQuickActionsLoading != c.isQuickActionsLoading,
      builder: (context, state) {
        if (state.isQuickActionsLoading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.quickActions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  // Icon + Label 
                  Row(
                    children: [
                      Icon(
                        Icons.flash_on_rounded,
                        color: scheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "Quick Actions",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Count badge at end
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${state.quickActions.length}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: state.quickActions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final action = state.quickActions[index];
                  final showPendingBreakdown =
                      (action.id == 'dueToday' || action.id == 'overDue') &&
                      action.count > 0;

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      switch (action.id) {
                        case 'addTask':
                          break;
                        case 'prochat':
                          break;
                        case 'dueToday':
                          break;
                        case 'overDue':
                          break;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: action.isHighlighted
                            ? scheme.primary.withOpacity(0.75)
                            : scheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: action.isHighlighted
                              ? Colors.transparent
                              : scheme.outline.withOpacity(0.5),
                          width: action.isHighlighted ? 0 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: action.isHighlighted
                                  ? scheme.surface
                                  : _getIconBackgroundColor(context, action.id),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              action.icon,
                              size: 18,
                              color: action.isHighlighted
                                  ? scheme.primary
                                  : _getIconColor(action.id),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                action.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: action.isHighlighted
                                      ? scheme.onPrimary
                                      : scheme.onSurface,
                                  height: 1.1,
                                ),
                              ),
                              if (showPendingBreakdown) ...[
                                const SizedBox(height: 3),
                                _buildPendingCount(
                                  action.pendingAtMe,
                                  action.count,
                                  action.isHighlighted,
                                  action.id,
                                ),
                              ] else if (action.count > 0) ...[
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: action.isHighlighted
                                        ? scheme.primary
                                        : _getIconBackgroundColor(
                                            context,
                                            action.id,
                                          ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${action.count}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: action.isHighlighted
                                          ? scheme.onPrimary
                                          : _getIconColor(action.id),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPendingCount(
    int pendingAtMe,
    int total,
    bool isHighlighted,
    String actionId,
  ) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$pendingAtMe',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isHighlighted ? Colors.white : _getIconColor(actionId),
            ),
          ),
          TextSpan(
            text: '/$total ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 10,
              color: isHighlighted
                  ? Colors.white.withOpacity(0.8)
                  : Colors.grey.shade600,
            ),
          ),
          TextSpan(
            text: 'at me',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: isHighlighted
                  ? Colors.white.withOpacity(0.7)
                  : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getIconBackgroundColor(BuildContext context, String id) {
    final scheme = Theme.of(context).colorScheme;
    switch (id) {
      case 'addTask':
        return scheme.primary.withOpacity(0.1);
      case 'prochat':
        return Colors.purple.shade50;
      case 'dueToday':
        return Colors.orange.shade50;
      case 'overDue':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getIconColor(String id) {
    switch (id) {
      case 'addTask':
        return Colors.blue.shade600;
      case 'prochat':
        return Colors.purple.shade600;
      case 'dueToday':
        return Colors.orange.shade600;
      case 'overDue':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}
