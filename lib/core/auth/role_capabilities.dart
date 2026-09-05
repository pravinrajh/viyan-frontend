/// Maps backend roles (`MD` | `ADMIN` | `MANAGER` | `EMPLOYEE`) to UI capabilities.
/// Backend remains the authorization authority; this only controls navigation/chrome.
enum AppCapability {
  viewDashboard,
  viewAssistant,
  viewTasks,
  createTasks,
  viewMeetings,
  createMeetings,
  viewProjects,
  createProjects,
  viewFinance,
  viewCollections,
  viewInvoices,
  viewVendors,
  viewLand,
  viewMdNotes,
  viewBudgets,
  viewReminders,
  viewSales,
  createLeads,
  viewCrm,
  viewReports,
  viewNotifications,
  viewUsers,
  manageUsers,
  viewProfile,
}

abstract final class RoleCapabilities {
  static const _all = AppCapability.values;

  static Set<AppCapability> forRole(String? role) {
    switch ((role ?? '').toUpperCase()) {
      case 'MD':
      case 'ADMIN':
        return _all.toSet();
      case 'MANAGER':
        return {
          AppCapability.viewDashboard,
          AppCapability.viewAssistant,
          AppCapability.viewTasks,
          AppCapability.createTasks,
          AppCapability.viewMeetings,
          AppCapability.createMeetings,
          AppCapability.viewProjects,
          AppCapability.createProjects,
          AppCapability.viewFinance,
          AppCapability.viewCollections,
          AppCapability.viewInvoices,
          AppCapability.viewVendors,
          AppCapability.viewLand,
          AppCapability.viewMdNotes,
          AppCapability.viewBudgets,
          AppCapability.viewReminders,
          AppCapability.viewSales,
          AppCapability.createLeads,
          AppCapability.viewCrm,
          AppCapability.viewReports,
          AppCapability.viewNotifications,
          AppCapability.viewUsers,
          AppCapability.viewProfile,
        };
      case 'EMPLOYEE':
        return {
          AppCapability.viewDashboard,
          AppCapability.viewAssistant,
          AppCapability.viewTasks,
          AppCapability.viewMeetings,
          AppCapability.viewProjects,
          AppCapability.viewNotifications,
          AppCapability.viewProfile,
          AppCapability.viewReminders,
        };
      default:
        return {AppCapability.viewProfile, AppCapability.viewDashboard};
    }
  }

  static bool can(String? role, AppCapability capability) {
    final caps = forRole(role);
    if (caps.contains(capability)) return true;
    // Invoices replace Collections in the UI; keep either capability valid.
    if (capability == AppCapability.viewInvoices &&
        caps.contains(AppCapability.viewCollections)) {
      return true;
    }
    if (capability == AppCapability.viewCollections &&
        caps.contains(AppCapability.viewInvoices)) {
      return true;
    }
    return false;
  }

  static bool isPrivileged(String? role) {
    final value = (role ?? '').toUpperCase();
    return value == 'MD' || value == 'ADMIN';
  }

  static bool isManagerOrAbove(String? role) {
    final value = (role ?? '').toUpperCase();
    return value == 'MD' || value == 'ADMIN' || value == 'MANAGER';
  }

  static String displayLabel(String? role) {
    switch ((role ?? '').toUpperCase()) {
      case 'MD':
        return 'Managing Director';
      case 'ADMIN':
        return 'Administrator';
      case 'MANAGER':
        return 'Department Head';
      case 'EMPLOYEE':
        return 'Employee';
      default:
        return role?.isNotEmpty == true ? role! : 'User';
    }
  }
}
