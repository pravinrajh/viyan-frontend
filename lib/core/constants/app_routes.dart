/// Named route paths used by [go_router].
abstract final class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String assistant = '/assistant';
  static const String tasks = '/tasks';
  static const String taskNew = '/tasks/new';
  static const String meetings = '/meetings';
  static const String projects = '/projects';
  static const String finance = '/finance';
  static const String notifications = '/notifications';
  static const String reports = '/reports';
  static const String sales = '/sales';
  static const String salesActivities = '/sales/activities';
  static const String crm = '/crm';
  static const String collections = '/collections';
  static const String invoices = '/invoices';
  static const String vendors = '/vendors';
  static const String land = '/land';
  static const String mdNotes = '/md-notes';
  static const String budgets = '/budgets';
  static const String reminders = '/reminders';
  static const String users = '/users';
  static const String profile = '/profile';

  static String taskDetail(String id) => '/tasks/$id';
  static String projectDetail(String id) => '/projects/$id';
  static String meetingDetail(String id) => '/meetings/$id';
}
