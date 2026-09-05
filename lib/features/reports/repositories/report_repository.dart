import '../models/daily_report.dart';

abstract class ReportRepository {
  Future<DailyReport> fetchDailyReport();
}
