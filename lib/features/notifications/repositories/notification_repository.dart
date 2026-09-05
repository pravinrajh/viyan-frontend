import '../models/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> fetchNotifications();
  Future<int> fetchUnreadCount();
  Future<AppNotification> markRead(String id);
  Future<void> markAllRead();
}
