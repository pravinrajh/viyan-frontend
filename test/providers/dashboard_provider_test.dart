import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_eao/features/dashboard/providers/dashboard_providers.dart';
import 'package:md_eao/features/dashboard/repositories/mock_dashboard_repository.dart';

import '../helpers/auth_test_override.dart';

void main() {
  test('dashboard repository returns Day-2 mock data', () async {
    final repo = MockDashboardRepository(delay: Duration.zero);
    final summary = await repo.fetchSummary();

    expect(summary.tasks.total, 18);
    expect(summary.tasks.overdue, 3);
    expect(summary.meetings.today, 5);
    expect(summary.sales.pipelineValue, 84000000);
    expect(summary.collections.pending, 4200000);
    expect(summary.finance.weeklyRequirement, 5000000);
    expect(summary.finance.availableBalance, 11000000);
    expect(summary.projects.active, 5);
    expect(summary.projects.atRisk, 1);
    expect(summary.criticalActions, isNotEmpty);
  });

  test('dashboardProvider reaches success state', () async {
    final container = ProviderContainer.test(
      overrides: [
        authOverride(),
        dashboardRepositoryProvider.overrideWithValue(
          MockDashboardRepository(delay: Duration.zero),
        ),
      ],
    );

    final summary = await container.read(dashboardProvider.future);
    expect(summary.tasks.total, 18);
    expect(container.read(dashboardProvider).hasValue, isTrue);
  });

  test('dashboardProvider handles error state', () async {
    final container = ProviderContainer.test(
      overrides: [
        authOverride(),
        dashboardRepositoryProvider.overrideWithValue(
          MockDashboardRepository(delay: Duration.zero, forceError: true),
        ),
      ],
    );

    await expectLater(
      container.read(dashboardProvider.future),
      throwsA(isA<StateError>()),
    );
    expect(container.read(dashboardProvider).hasError, isTrue);
  });
}
