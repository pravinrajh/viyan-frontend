import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_eao/core/utils/greeting.dart';
import 'package:md_eao/features/dashboard/presentation/dashboard_screen.dart';
import 'package:md_eao/features/dashboard/providers/dashboard_providers.dart';
import 'package:md_eao/features/dashboard/repositories/mock_dashboard_repository.dart';

import '../helpers/auth_test_override.dart';

void main() {
  Future<void> pumpDashboard(
    WidgetTester tester, {
    MockDashboardRepository? repository,
  }) async {
    tester.view.physicalSize = const Size(1200, 3600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authOverride(),
          dashboardRepositoryProvider.overrideWithValue(
            repository ?? MockDashboardRepository(delay: Duration.zero),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: DashboardScreen())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dashboard displays task count and critical actions', (
    tester,
  ) async {
    await pumpDashboard(tester);

    expect(find.textContaining(executiveGreeting()), findsWidgets);
    expect(find.text('Alerts & Notifications'), findsOneWidget);
    expect(find.text('ABC Builders payment overdue'), findsWidgets);
    expect(find.text('18'), findsWidgets);
    expect(find.text('3 Overdue'), findsOneWidget);
  });

  testWidgets('dashboard displays sales pipeline', (tester) async {
    await pumpDashboard(tester);
    expect(find.text('₹8.40 Cr'), findsWidgets);
    expect(find.text('Sales Pipeline'), findsOneWidget);
  });

  testWidgets('dashboard displays collection amount', (tester) async {
    await pumpDashboard(tester);
    expect(find.text('₹42.00 L'), findsWidgets);
    expect(find.text('Collections'), findsOneWidget);
  });

  testWidgets('dashboard displays project risk', (tester) async {
    await pumpDashboard(tester);
    expect(find.text('OMR Commercial'), findsOneWidget);
    expect(find.text('At Risk'), findsWidgets);
    expect(find.text('Progress: 35%'), findsOneWidget);
  });

  testWidgets('dashboard shows error and retry', (tester) async {
    await pumpDashboard(
      tester,
      repository: MockDashboardRepository(
        delay: Duration.zero,
        forceError: true,
      ),
    );

    expect(find.text('Unable to load business data.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
