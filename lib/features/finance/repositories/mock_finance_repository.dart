import '../../../core/utils/mock_delay.dart';
import '../models/finance_summary.dart';
import 'finance_repository.dart';

class MockFinanceRepository implements FinanceRepository {
  MockFinanceRepository({this.delay});

  final Duration? delay;

  static const _summary = FinanceSummary(
    cashOnHand: 42000000,
    receivables: 7800000,
    payables: 31000000,
    weeklyRequirement: 2450000,
    expectedCollections: 6500000,
    commentary: 'Weekly pressure from labour (Chennai Villa), Sri Materials settlement, and OMR legal retainer. Expected collections from ABC Builders and XYZ Developers this week.',
    plannedPayments: [
      'Labour — Chennai Villa — ₹9.5 L',
      'Vendor — Sri Materials — ₹6.2 L',
      'Land/Legal — OMR parcel — ₹5.0 L',
      'Material — OMR Commercial — ₹3.8 L',
    ],
  );

  @override
  Future<FinanceSummary> fetchSummary() {
    return withMockDelay(_summary, delay: delay);
  }

  @override
  Future<double> fetchWeeklyRequirement() {
    return withMockDelay(_summary.weeklyRequirement, delay: delay);
  }
}
