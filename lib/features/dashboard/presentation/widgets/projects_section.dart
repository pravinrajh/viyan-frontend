import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_surface_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/section_summaries.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key, required this.projects});

  final ProjectOverview projects;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Project Health',
            trailing: TextButton(
              onPressed: () => context.go(AppRoutes.projects),
              child: const Text('View all'),
            ),
          ),
          const SizedBox(height: 8),
          if (projects.items.isEmpty)
            const Text(
              'No project summaries available.',
              style: TextStyle(color: AppTheme.mutedText),
            )
          else
            ...projects.items.map((project) {
              final riskColor = switch (project.risk.toLowerCase()) {
                'high' => AppTheme.danger,
                'medium' => AppTheme.warning,
                _ => AppTheme.success,
              };
              final health = switch (project.risk.toLowerCase()) {
                'high' => 'At Risk',
                'medium' => 'Watch',
                _ => 'Healthy',
              };
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppTheme.ink,
                            ),
                          ),
                        ),
                        StatusChip(label: health, color: riskColor),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: project.progressFraction,
                        minHeight: 6,
                        color: riskColor,
                        backgroundColor: AppTheme.border,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Progress: ${(project.progressFraction * 100).round()}%',
                      style: const TextStyle(
                        color: AppTheme.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
