import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/finance_summary.dart';
import 'finance_repository.dart';

/// Live finance from `GET /api/v1/finance/summary` and weekly dashboard cash need.
class ApiFinanceRepository implements FinanceRepository {
  ApiFinanceRepository(this._client);

  final ApiClient _client;

  @override
  Future<FinanceSummary> fetchSummary() async {
    final summaryResponse = await _client.get<dynamic>(
      ApiEndpoints.financeSummary,
    );
    final summary = ApiEnvelope.dataMap(summaryResponse.data);
    final income = (summary['income'] as num?)?.toDouble() ?? 0;
    final expense = (summary['expense'] as num?)?.toDouble() ?? 0;
    final net = (summary['net'] as num?)?.toDouble() ?? (income - expense);

    var weeklyRequirement = 0.0;
    var expectedCollections = 0.0;
    var payables = expense;
    var commentary =
        'Net is income minus expense from completed ledger rows. It is not a bank cash balance. Project.actualExpense can differ until matching transactions exist. Invoices, receivables and vendor payables are not a separate module yet.';
    final planned = <String>[];

    try {
      final weeklyResponse = await _client.get<dynamic>(
        ApiEndpoints.dashboardWeeklyFinancial,
      );
      final weekly = ApiEnvelope.dataMap(weeklyResponse.data);
      expectedCollections = (weekly['expectedIncome'] as num?)?.toDouble() ?? 0;
      final plannedExpenses =
          (weekly['plannedExpenses'] as num?)?.toDouble() ?? 0;
      payables = plannedExpenses;
      final netRequirement =
          (weekly['netRequirement'] as num?)?.toDouble() ??
          (expectedCollections - plannedExpenses);
      weeklyRequirement = netRequirement < 0
          ? -netRequirement
          : plannedExpenses;
      final basis = weekly['basis'] as String?;
      if (basis != null && basis.isNotEmpty) commentary = basis;
      final items = weekly['items'];
      if (items is List) {
        for (final item in items) {
          if (item is! Map) continue;
          final category = item['category']?.toString() ?? 'Expense';
          final amount = item['amount'];
          planned.add('$category — $amount');
        }
      }
    } catch (_) {
      // Weekly requirement is MD/ADMIN/MANAGER only; keep transaction totals.
    }

    return FinanceSummary(
      cashOnHand: net,
      receivables: 0,
      payables: payables,
      weeklyRequirement: weeklyRequirement,
      expectedCollections: expectedCollections,
      commentary: commentary,
      plannedPayments: planned,
    );
  }

  @override
  Future<double> fetchWeeklyRequirement() async {
    final summary = await fetchSummary();
    return summary.weeklyRequirement;
  }
}
