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

/// Mirrors _ProjectCard exactly:
///   icon-row (36×36 box + chevron) → SizedBox(8) → Expanded name → SizedBox(6) → chip Row
class _ProjectShimmerCard extends StatelessWidget {
  const _ProjectShimmerCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),      // Grey 300 — clearly visible
      highlightColor: const Color(0xFFF5F5F5), // Grey 100 — bright sweep
      child: Container(
        width: 210, // matches real card
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: cs.outlineVariant.withOpacity(0.2), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // ── Icon row placeholder ──────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 34,  // matches padding(7)*2 + icon(20) = 34
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Name placeholder — Expanded like real card ────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 130,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 90,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // ── Chip row placeholder — three Expanded siblings ────────────
            Row(
              children: List.generate(3, (i) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              }),
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

  Color _projectColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return [
      cs.primary,
      cs.secondary,
      cs.tertiary,
      cs.error,
      cs.primaryContainer,
    ][index % 5];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final projectColor = _projectColor(context);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () =>
          Navigator.of(context).pushNamed('/project-details', arguments: project),
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: cs.outlineVariant.withOpacity(0.2), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon row ────────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: projectColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.folder_outlined,
                      size: 20, color: projectColor),
                ),
                const Spacer(),
                Icon(Icons.chevron_right,
                    size: 18, color: cs.onSurfaceVariant),
              ],
            ),

            const SizedBox(height: 8),

            // ── Project name ─────────────────────────────────────────────────
            Expanded(
              child: Text(
                project.projectName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ── Chips — Row + Expanded so they never overflow ─────────────
            Row(
              children: [
                _ProjectStatusChip(
                  count: project.completedTaskCount,
                  label: 'Done',
                  textColor: cs.onPrimaryContainer,
                  bgColor: cs.primaryContainer,
                ),
                const SizedBox(width: 4),
                _ProjectStatusChip(
                  count: project.inProgressTaskCount,
                  label: 'Progress',
                  textColor: cs.onErrorContainer,
                  bgColor: cs.errorContainer,
                ),
                const SizedBox(width: 4),
                _ProjectStatusChip(
                  count: project.totalTaskCount,
                  label: 'To Client',
                  textColor: cs.onSecondaryContainer,
                  bgColor: cs.secondaryContainer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status Chip ───────────────────────────────────────────────────────────────

class _ProjectStatusChip extends StatelessWidget {
  final int count;
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
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
          const SizedBox(width: 6),
          Text(
            " ($count)",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),

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