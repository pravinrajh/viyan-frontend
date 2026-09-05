import '../../../core/utils/mock_delay.dart';
import '../models/daily_report.dart';
import 'report_repository.dart';

class MockReportRepository implements ReportRepository {
  MockReportRepository({this.delay});

  final Duration? delay;

  @override
  Future<DailyReport> fetchDailyReport() {
    return withMockDelay(
      DailyReport(
        id: 'rpt-daily-1',
        title: 'Daily MD brief',
        summary: '''
1. Today's tasks: Follow up ABC Builders collection; Chennai Villa site visit.
2. Overdue tasks: OMR Commercial foundation variation.
3. Today's meetings: Leadership standup, Chennai Villa review, banker call, OMR risk huddle.
4. Important follow-ups: Kumar Residence proposal; Green Homes site visit.
5. Sales updates: Pipeline ₹92 L · 4 new leads · 2 conversions.
6. Collection status: Pending ₹78 L · Overdue ₹48 L (ABC Builders).
7. Finance requirement: Weekly need ₹24.50 L · Available ₹4.20 Cr.
8. Project status: Chennai Villa 68% · Coimbatore Interior 75% · OMR Commercial 35%.
9. Project risks: OMR Commercial high risk.
10. Vendor payments: Sri Materials settlement pending.
11. Critical actions: 4 items requiring MD attention.
''',
        generatedAt: DateTime.now(),
      ),
      delay: delay,
    );
  }
}
