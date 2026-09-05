import 'package:flutter_test/flutter_test.dart';
import 'package:md_eao/app/router.dart';
import 'package:md_eao/core/constants/app_routes.dart';

/// Covers the route guard that decides whether an authenticated user may
/// land on a given shell route for their role. Every shell route must be
/// covered here — an untested route is a silent RBAC gap.
void main() {
  const protectedRoutes = [
    AppRoutes.dashboard,
    AppRoutes.assistant,
    AppRoutes.tasks,
    AppRoutes.taskNew,
    AppRoutes.meetings,
    AppRoutes.projects,
    AppRoutes.users,
    AppRoutes.finance,
    AppRoutes.sales,
    AppRoutes.salesActivities,
    AppRoutes.crm,
    AppRoutes.collections,
    AppRoutes.invoices,
    AppRoutes.vendors,
    AppRoutes.land,
    AppRoutes.mdNotes,
    AppRoutes.budgets,
    AppRoutes.reminders,
    AppRoutes.reports,
    AppRoutes.notifications,
    AppRoutes.profile,
  ];

  test('MD and ADMIN can reach every shell route', () {
    for (final role in ['MD', 'ADMIN']) {
      for (final route in protectedRoutes) {
        expect(
          capabilityRedirect(route, role),
          isNull,
          reason: '$role should not be redirected away from $route',
        );
      }
    }
  });

  test('EMPLOYEE is redirected away from business-privileged routes', () {
    const privileged = [
      AppRoutes.users,
      AppRoutes.finance,
      AppRoutes.sales,
      AppRoutes.salesActivities,
      AppRoutes.crm,
      AppRoutes.collections,
      AppRoutes.invoices,
      AppRoutes.vendors,
      AppRoutes.land,
      AppRoutes.mdNotes,
      AppRoutes.budgets,
      AppRoutes.reports,
    ];
    for (final route in privileged) {
      expect(
        capabilityRedirect(route, 'EMPLOYEE'),
        AppRoutes.dashboard,
        reason: 'EMPLOYEE should be bounced away from $route',
      );
    }
  });

  test('EMPLOYEE keeps access to their own-work routes', () {
    const ownWork = [
      AppRoutes.dashboard,
      AppRoutes.assistant,
      AppRoutes.tasks,
      AppRoutes.meetings,
      AppRoutes.projects,
      AppRoutes.notifications,
      AppRoutes.profile,
      AppRoutes.reminders,
    ];
    for (final route in ownWork) {
      expect(capabilityRedirect(route, 'EMPLOYEE'), isNull);
    }
  });

  test('EMPLOYEE cannot create a task even though they can view the list', () {
    expect(capabilityRedirect(AppRoutes.tasks, 'EMPLOYEE'), isNull);
    expect(
      capabilityRedirect(AppRoutes.taskNew, 'EMPLOYEE'),
      AppRoutes.dashboard,
    );
  });

  test('sales and CRM are guarded by their own distinct capabilities', () {
    expect(capabilityRedirect(AppRoutes.sales, 'EMPLOYEE'), AppRoutes.dashboard);
    expect(capabilityRedirect(AppRoutes.crm, 'EMPLOYEE'), AppRoutes.dashboard);
    expect(capabilityRedirect(AppRoutes.sales, 'MANAGER'), isNull);
    expect(capabilityRedirect(AppRoutes.crm, 'MANAGER'), isNull);
  });

  test('MANAGER can reach invoices and related More routes', () {
    for (final route in [
      AppRoutes.invoices,
      AppRoutes.vendors,
      AppRoutes.land,
      AppRoutes.mdNotes,
      AppRoutes.budgets,
      AppRoutes.reminders,
    ]) {
      expect(capabilityRedirect(route, 'MANAGER'), isNull);
    }
  });

  test('an unrecognized or missing role is redirected off every route but dashboard/profile', () {
    for (final role in [null, '', 'CONTRACTOR']) {
      for (final route in protectedRoutes) {
        final result = capabilityRedirect(route, role);
        final allowed =
            route == AppRoutes.dashboard || route == AppRoutes.profile;
        expect(
          result,
          allowed ? isNull : AppRoutes.dashboard,
          reason: 'role "$role" on $route',
        );
      }
    }
  });

  test('routes with no declared guard fall through', () {
    expect(capabilityRedirect('/unknown-path', 'EMPLOYEE'), isNull);
  });
}
