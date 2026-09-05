import 'package:flutter_test/flutter_test.dart';
import 'package:md_eao/core/auth/role_capabilities.dart';

void main() {
  group('RoleCapabilities.forRole', () {
    test('MD and ADMIN get every capability', () {
      final all = AppCapability.values.toSet();
      expect(RoleCapabilities.forRole('MD'), all);
      expect(RoleCapabilities.forRole('ADMIN'), all);
      expect(RoleCapabilities.forRole('md'), all, reason: 'role is case-insensitive');
    });

    test('MANAGER can manage business data but not manage users', () {
      final caps = RoleCapabilities.forRole('MANAGER');
      expect(caps.contains(AppCapability.viewUsers), isTrue);
      expect(caps.contains(AppCapability.manageUsers), isFalse);
      expect(caps.contains(AppCapability.viewFinance), isTrue);
      expect(caps.contains(AppCapability.viewSales), isTrue);
      expect(caps.contains(AppCapability.viewCrm), isTrue);
      expect(caps.contains(AppCapability.viewInvoices), isTrue);
      expect(caps.contains(AppCapability.viewVendors), isTrue);
      expect(caps.contains(AppCapability.viewBudgets), isTrue);
    });

    test('EMPLOYEE is scoped to their own work, not business-wide data', () {
      final caps = RoleCapabilities.forRole('EMPLOYEE');
      expect(caps.contains(AppCapability.viewTasks), isTrue);
      expect(caps.contains(AppCapability.viewMeetings), isTrue);
      expect(caps.contains(AppCapability.viewProjects), isTrue);
      expect(caps.contains(AppCapability.viewProfile), isTrue);

      // Business-wide / privileged surfaces must stay hidden.
      expect(caps.contains(AppCapability.viewUsers), isFalse);
      expect(caps.contains(AppCapability.viewFinance), isFalse);
      expect(caps.contains(AppCapability.viewSales), isFalse);
      expect(caps.contains(AppCapability.viewCrm), isFalse);
      expect(caps.contains(AppCapability.viewCollections), isFalse);
      expect(caps.contains(AppCapability.viewInvoices), isFalse);
      expect(caps.contains(AppCapability.viewVendors), isFalse);
      expect(caps.contains(AppCapability.viewLand), isFalse);
      expect(caps.contains(AppCapability.viewBudgets), isFalse);
      expect(caps.contains(AppCapability.viewMdNotes), isFalse);
      expect(caps.contains(AppCapability.viewReports), isFalse);
      expect(caps.contains(AppCapability.createTasks), isFalse);
      expect(caps.contains(AppCapability.manageUsers), isFalse);
    });

    test('an unknown or missing role only sees dashboard and profile', () {
      for (final role in [null, '', 'SOMETHING_NEW']) {
        final caps = RoleCapabilities.forRole(role);
        expect(caps, {AppCapability.viewDashboard, AppCapability.viewProfile});
      }
    });
  });

  group('RoleCapabilities.can', () {
    test('matches forRole membership', () {
      expect(RoleCapabilities.can('EMPLOYEE', AppCapability.viewTasks), isTrue);
      expect(RoleCapabilities.can('EMPLOYEE', AppCapability.viewUsers), isFalse);
    });
  });

  group('RoleCapabilities.isPrivileged / isManagerOrAbove', () {
    test('only MD/ADMIN are privileged', () {
      expect(RoleCapabilities.isPrivileged('MD'), isTrue);
      expect(RoleCapabilities.isPrivileged('ADMIN'), isTrue);
      expect(RoleCapabilities.isPrivileged('MANAGER'), isFalse);
      expect(RoleCapabilities.isPrivileged('EMPLOYEE'), isFalse);
    });

    test('MD/ADMIN/MANAGER count as manager-or-above', () {
      expect(RoleCapabilities.isManagerOrAbove('MANAGER'), isTrue);
      expect(RoleCapabilities.isManagerOrAbove('EMPLOYEE'), isFalse);
    });
  });

  group('RoleCapabilities.displayLabel', () {
    test('MANAGER is shown as Department Head, not the raw enum', () {
      expect(RoleCapabilities.displayLabel('MANAGER'), 'Department Head');
      expect(RoleCapabilities.displayLabel('MD'), 'Managing Director');
      expect(RoleCapabilities.displayLabel(null), 'User');
    });
  });
}
