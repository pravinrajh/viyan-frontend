/// REST paths from MD_EAO_BACKEND Swagger (`http://localhost:5050/api-docs`).
/// Flutter never talks to MongoDB directly.
abstract final class ApiEndpoints {
  static const String health = '/api/v1/health';

  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String refresh = '/api/v1/auth/refresh';
  static const String me = '/api/v1/auth/me';
  static const String logout = '/api/v1/auth/logout';

  static const String users = '/api/v1/users';
  static String user(String id) => '/api/v1/users/$id';
  static String userStatus(String id) => '/api/v1/users/$id/status';

  static const String dashboard = '/api/v1/dashboard';
  static const String dashboardWeeklyFinancial =
      '/api/v1/dashboard/weekly-financial-requirement';
  static const String dashboardMorningReport =
      '/api/v1/dashboard/morning-report';

  static const String assistantQuery = '/api/v1/assistant/query';
  static const String assistantAction = '/api/v1/assistant/action';
  static const String assistantChat = '/api/v1/assistant/chat';
  static const String assistantImportMinutes =
      '/api/v1/assistant/import-minutes';
  static const String assistantHistory = '/api/v1/assistant/history';
  static String assistantActionConfirm(String actionId) =>
      '/api/v1/assistant/action/$actionId/confirm';

  static const String tasks = '/api/v1/tasks';
  static const String tasksMy = '/api/v1/tasks/my';
  static String task(String id) => '/api/v1/tasks/$id';
  static String taskStatus(String id) => '/api/v1/tasks/$id/status';
  static const String employees = '/api/v1/employees';

  static const String meetings = '/api/v1/meetings';
  static String meeting(String id) => '/api/v1/meetings/$id';
  static String meetingStatus(String id) => '/api/v1/meetings/$id/status';

  static const String projects = '/api/v1/projects';
  static String project(String id) => '/api/v1/projects/$id';
  static String projectStatus(String id) => '/api/v1/projects/$id/status';
  static String projectSummary(String id) => '/api/v1/projects/$id/summary';

  static const String salesSummary = '/api/v1/sales/summary';
  static const String salesFollowUps = '/api/v1/sales/follow-ups';
  static const String leads = '/api/v1/leads';
  static String lead(String id) => '/api/v1/leads/$id';
  static String leadConvert(String id) => '/api/v1/leads/$id/convert';
  static const String customers = '/api/v1/customers';
  static const String opportunities = '/api/v1/opportunities';

  static const String salesActivities = '/api/v1/sales-activities';
  static String salesActivity(String id) => '/api/v1/sales-activities/$id';
  static String salesActivityStatus(String id) =>
      '/api/v1/sales-activities/$id/status';

  static const String financeSummary = '/api/v1/finance/summary';
  static const String financeAccounts = '/api/v1/finance/accounts';
  static const String financeCategories = '/api/v1/finance/categories';
  static const String financeTransactions = '/api/v1/finance/transactions';
  static const String financeIncome = '/api/v1/finance/transactions/income';
  static const String financeExpense = '/api/v1/finance/transactions/expense';
  static const String financeBudgets = '/api/v1/finance/budgets';
  static String financeBudget(String id) => '/api/v1/finance/budgets/$id';
  static String financeBudgetSummary(String id) =>
      '/api/v1/finance/budgets/$id/summary';

  static const String invoices = '/api/v1/invoices';
  static String invoice(String id) => '/api/v1/invoices/$id';
  static String invoicePayments(String id) => '/api/v1/invoices/$id/payments';

  static const String vendors = '/api/v1/vendors';
  static String vendor(String id) => '/api/v1/vendors/$id';

  static const String landParcels = '/api/v1/land-parcels';
  static String landParcel(String id) => '/api/v1/land-parcels/$id';

  static const String mdNotes = '/api/v1/md-notes';
  static String mdNote(String id) => '/api/v1/md-notes/$id';

  static const String reminders = '/api/v1/reminders';
  static const String remindersToday = '/api/v1/reminders/today';
  static const String remindersUpcoming = '/api/v1/reminders/upcoming';
  static String reminder(String id) => '/api/v1/reminders/$id';
  static String reminderComplete(String id) => '/api/v1/reminders/$id/complete';
  static String reminderCancel(String id) => '/api/v1/reminders/$id/cancel';
  static String reminderSnooze(String id) => '/api/v1/reminders/$id/snooze';

  static const String notifications = '/api/v1/notifications';
  static const String notificationUnreadCount =
      '/api/v1/notifications/unread-count';
  static const String notificationsReadAll = '/api/v1/notifications/read-all';
  static String notificationRead(String id) => '/api/v1/notifications/$id/read';
  static String notificationUnread(String id) =>
      '/api/v1/notifications/$id/unread';
}
