import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_surface_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/critical_action.dart';

class CriticalActionsSection extends StatelessWidget {
  const CriticalActionsSection({super.key, required this.actions});

  final List<CriticalAction> actions;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Alerts & Notifications',
            trailing: TextButton(
              onPressed: () => context.go(AppRoutes.notifications),
              child: const Text('View all'),
            ),
          ),
          const SizedBox(height: 4),
          if (actions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No alerts right now.',
                style: TextStyle(color: AppTheme.mutedText),
              ),
            )
          else
            ...actions.map((action) {
              final color = switch (action.priority) {
                CriticalPriority.critical => AppTheme.danger,
                CriticalPriority.high => AppTheme.warning,
                CriticalPriority.medium => AppTheme.info,
                CriticalPriority.low => AppTheme.success,
              };
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.circle_notifications_outlined,
                      color: color,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            action.title,
                            style: const TextStyle(
                              color: AppTheme.ink,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          if (action.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              action.subtitle!,
                              style: const TextStyle(
                                color: AppTheme.mutedText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(label: action.priority.label, color: color),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
