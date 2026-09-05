import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/utils/greeting.dart';
import '../../../auth/providers/auth_providers.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({
    super.key,
    required this.headline,
    required this.businessStatus,
  });

  final String headline;
  final String businessStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 900;
    final userName = ref.watch(sessionProvider)?.user.name ?? 'there';
    final statusColor = switch (businessStatus) {
      'Critical' => AppTheme.danger,
      'Attention Required' => AppTheme.warning,
      _ => AppTheme.success,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () => context.go(AppRoutes.assistant),
                    decoration: InputDecoration(
                      hintText: 'Ask about tasks, projects, pipeline…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: Theme.of(context).cardTheme.color,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: () => context.go(AppRoutes.notifications),
                  icon: const Icon(Icons.notifications_outlined),
                ),
                const SizedBox(width: 4),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.assistant),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('Ask Assistant'),
                ),
              ],
            ),
          ),
        Text(
          '${executiveGreeting()}, $userName',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: compact ? 24 : 28,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Here's what's happening across the organization today.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormatters.weekdayDate(DateTime.now()),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withValues(alpha: 0.45)),
            color: statusColor.withValues(alpha: 0.08),
          ),
          child: Text(
            'Business Status: $businessStatus',
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        if (headline.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.lightGold.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35)),
            ),
            child: Text(
              headline,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
