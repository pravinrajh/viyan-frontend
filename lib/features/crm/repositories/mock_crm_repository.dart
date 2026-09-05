import '../../../core/utils/mock_delay.dart';
import '../models/crm_overview.dart';
import 'crm_repository.dart';

class MockCrmRepository implements CrmRepository {
  MockCrmRepository({this.delay});

  final Duration? delay;

  @override
  Future<CrmOverview> fetchOverview() {
    return withMockDelay(
      const CrmOverview(
        message: 'Full CRM is scheduled for a later increment.',
        openFollowUps: 0,
      ),
      delay: delay,
    );
  }
}
