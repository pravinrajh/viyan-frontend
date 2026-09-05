import '../models/finance_summary.dart';

abstract class FinanceRepository {
  Future<FinanceSummary> fetchSummary();
  Future<double> fetchWeeklyRequirement();
}
