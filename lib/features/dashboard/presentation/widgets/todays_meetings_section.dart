import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/app_surface_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../models/meeting_summary.dart';

class TodaysMeetingsSection extends StatelessWidget {
  const TodaysMeetingsSection({super.key, required this.meetings});

  final List<MeetingSummary> meetings;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: "Today's Schedule",
            trailing: TextButton(
              onPressed: () => context.go(AppRoutes.meetings),
              child: const Text('View all'),
            ),
          ),
          const SizedBox(height: 8),
          if (meetings.isEmpty)
            const Text(
              'No meetings scheduled today.',
              style: TextStyle(color: AppTheme.mutedText),
            )
          else
            ...meetings.map((meeting) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 72,
                      child: Text(
                        meeting.timeLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppTheme.navy,
                        ),
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: AppTheme.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meeting.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (meeting.participants.isNotEmpty)
                                meeting.participants.join(', '),
                              if (meeting.location != null) meeting.location!,
                            ].join(' · '),
                            style: const TextStyle(
                              color: AppTheme.mutedText,
                              fontSize: 12,
                            ),
                          ),
                        ],
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
