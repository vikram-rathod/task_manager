import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';
import '../model/project_count_model.dart';

class ProjectSection extends StatelessWidget {
  const ProjectSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (prev, curr) =>
      prev.isProjectsLoading != curr.isProjectsLoading ||
          prev.projects != curr.projects,
      builder: (context, state) {
        if (!state.isProjectsLoading && state.projects.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProjectHeader(count: state.projects.length),
              SizedBox(
                height: 140,
                child: state.isProjectsLoading
                    ? const _ProjectShimmerList()
                    : _ProjectList(projects: state.projects),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Shimmer List ─────────────────────────────────────────────────────────────

class _ProjectShimmerList extends StatelessWidget {
  const _ProjectShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, __) => const _ProjectShimmerCard(),
    );
  }
}

class _ProjectShimmerCard extends StatelessWidget {
  const _ProjectShimmerCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.surfaceContainerLowest,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.onSurface,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 120,
              height: 12,
              decoration: BoxDecoration(
                color: scheme.onSurface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 80,
              height: 10,
              decoration: BoxDecoration(
                color: scheme.onSurface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Spacer(),
            Row(
              children: List.generate(
                3,
                    (_) => Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Container(
                    width: 44,
                    height: 22,
                    decoration: BoxDecoration(
                      color: scheme.onSurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Real Project List ─────────────────────────────────────────────────────────

class _ProjectList extends StatelessWidget {
  final List projects;

  const _ProjectList({required this.projects});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: projects.length.clamp(0, 10),
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (context, index) => _ProjectCard(
        project: projects[index],
        index: index,
      ),
    );
  }
}

// ── Reusable Project Card ────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final ProjectCountModel project;
  final int index;

  const _ProjectCard({required this.project, required this.index});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final projectColor = _getProjectColor(context, index);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        // Navigate to project details
        Navigator.of(context).pushNamed('/project-details', arguments: project);
      },
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant.withOpacity(0.2), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: projectColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.folder_outlined,
                    size: 20,
                    color: projectColor,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                project.projectName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            Wrap(
              spacing: 4,
              runSpacing: 2,
              children: [
                _ProjectStatusChip(
                  count: '${project.completedTaskCount}',
                  label: 'Done',
                  textColor: Colors.green.shade700,
                  bgColor: Colors.green.shade50,
                ),
                _ProjectStatusChip(
                  count: '${project.inProgressTaskCount}',
                  label: 'Progress',
                  textColor: Colors.orange.shade700,
                  bgColor: Colors.orange.shade50,
                ),
                _ProjectStatusChip(
                  count: '${project.totalTaskCount}',
                  label: 'To Client',
                  textColor: Colors.blue.shade700,
                  bgColor: Colors.blue.shade50,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProjectColor(BuildContext context, int index) {
    final scheme = Theme.of(context).colorScheme;
    final colors = [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      Colors.orange.shade600,
      Colors.red.shade600,
    ];
    return colors[index % colors.length];
  }
}

// ── Reusable Status Chip ─────────────────────────────────────────────────────

class _ProjectStatusChip extends StatelessWidget {
  final String count;
  final String label;
  final Color textColor;
  final Color bgColor;

  const _ProjectStatusChip({
    required this.count,
    required this.label,
    required this.textColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _ProjectHeader extends StatelessWidget {
  final int count;

  const _ProjectHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.folder_open_rounded, size: 20, color: scheme.primary),
          const SizedBox(width: 6),
          Text(
            "Projects",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: scheme.onSurface,
            ),
          ),
          const Spacer(),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          //   decoration: BoxDecoration(
          //     color: scheme.surfaceContainerHighest,
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Text(
          //     "$count",
          //     style: TextStyle(
          //       fontSize: 12,
          //       fontWeight: FontWeight.w600,
          //       color: scheme.onSurfaceVariant,
          //     ),
          //   ),
          // ),
          // const SizedBox(width: 6),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "View all",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}