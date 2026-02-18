import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/module_notification_bloc.dart';
import '../notification_design_tokens.dart';
import '../widgets/notification_group_section.dart';
import '../widgets/notification_state_views.dart';


class ModuleNotificationScreen extends StatefulWidget {
  const ModuleNotificationScreen({super.key});

  @override
  State<ModuleNotificationScreen> createState() =>
      _ModuleNotificationScreenState();
}

class _ModuleNotificationScreenState extends State<ModuleNotificationScreen> {
  final Set<String> _collapsed = {};
  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void initState() {
    super.initState();
    context.read<ModuleNotificationBloc>().add(const NotificationFetched());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    _scaffoldMessenger?.hideCurrentSnackBar();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context
        .read<ModuleNotificationBloc>()
        .add(const NotificationRefreshed());
  }

  void _toggleGroup(String type) => setState(() {
    _collapsed.contains(type)
        ? _collapsed.remove(type)
        : _collapsed.add(type);
  });

  // ── AppBar ──────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ntfSurface(context),
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: ntfBorder(context),
      centerTitle: false,
      title: Text(
        'Task Notifications',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: ntfInk(context),
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        BlocBuilder<ModuleNotificationBloc, ModuleNotificationState>(
          buildWhen: (p, c) => p.pendingActionCount != c.pendingActionCount,
          builder: (_, state) {
            if (state.pendingActionCount == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: NotificationDt.sp16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NotificationDt.sp12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: NotificationDt.negative,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${state.pendingActionCount} pending',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: ntfBorder(context)),
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────────

  Widget _buildBody(
      BuildContext context,
      ModuleNotificationState state,
      ) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: NotificationDt.accent,
        ),
      );
    }

    if (state.isError && !state.hasData) {
      return NotificationErrorView(
        message: state.errorMessage,
        onRetry: () => context
            .read<ModuleNotificationBloc>()
            .add(const NotificationFetched()),
      );
    }

    if (state.isEmpty) return const NotificationEmptyView();

    return RefreshIndicator(
      color: NotificationDt.accent,
      onRefresh: _onRefresh,
      child: Stack(
        children: [
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(
                child: SizedBox(height: NotificationDt.sp8),
              ),
              for (final group in state.groups)
                if (group.list.isNotEmpty)
                  NotificationGroupSection(
                    group: group,
                    state: state,
                    isCollapsed: _collapsed.contains(group.type),
                    onToggle: () => _toggleGroup(group.type),
                  ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
          if (state.isRefreshing)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 2,
                color: NotificationDt.accent,
                backgroundColor: Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ntfSurfaceAlt(context),
      appBar: _buildAppBar(context),
      body: BlocConsumer<ModuleNotificationBloc, ModuleNotificationState>(
        listenWhen: (prev, curr) =>
        curr.isError && curr.errorMessage != prev.errorMessage,
        listener: (context, state) {
          _scaffoldMessenger
            ?..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: NotificationDt.negative,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NotificationDt.r12),
                ),
                margin: const EdgeInsets.all(NotificationDt.sp12),
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    _scaffoldMessenger?.hideCurrentSnackBar();
                    context
                        .read<ModuleNotificationBloc>()
                        .add(const NotificationErrorCleared());
                  },
                ),
              ),
            );
        },
        builder: _buildBody,
      ),
    );
  }
}