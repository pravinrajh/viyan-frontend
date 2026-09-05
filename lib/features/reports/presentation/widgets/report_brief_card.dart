import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../shared/widgets/app_surface_card.dart';
import '../../providers/report_providers.dart';

/// Self-contained AI morning brief. Watches its own provider so a failure
/// here never blocks the KPI/chart sections above from rendering.
class ReportBriefCard extends ConsumerWidget {
  const ReportBriefCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dailyReportProvider);

    return async.when(
      loading: () => const AppSurfaceCard(
        child: SizedBox(
          height: 72,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ),
        ),
      ),
      error: (error, _) => AppSurfaceCard(
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: AppTheme.mutedText,
              size: 18,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'The AI morning brief could not be loaded right now.',
                style: TextStyle(color: AppTheme.mutedText, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: () => ref.invalidate(dailyReportProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (report) {
        if (report.summary.trim().isEmpty) return const SizedBox.shrink();
        return AppSurfaceCard(
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.navy,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AppTheme.gold,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        report.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Generated ${DateFormatters.dateTime(report.generatedAt)}',
                  style: const TextStyle(color: Colors.white54, fontSize: 11.5),
                ),
                const SizedBox(height: 12),
                Text(
                  report.summary,
                  style: const TextStyle(color: Colors.white, height: 1.55),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
