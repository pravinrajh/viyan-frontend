import '../../../core/utils/mock_delay.dart';
import '../models/app_notification.dart';
import 'notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  MockNotificationRepository({this.delay});

  final Duration? delay;

  @override
  Future<List<AppNotification>> fetchNotifications() {
    final now = DateTime.now();
    return withMockDelay([
      AppNotification(
        id: 'ntf-1',
        title: 'Board pack pending',
        body: 'EA marked the Q3 pack as ready for MD review.',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      AppNotification(
        id: 'ntf-2',
        title: 'Vendor ABC overdue',
        body: 'Finance flagged invoice INV-8842 as 12 days overdue.',
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: false,
      ),
      AppNotification(
        id: 'ntf-3',
        title: 'Meeting in 45 minutes',
        body: 'Banker call — working capital.',
        createdAt: now.subtract(const Duration(minutes: 20)),
        isRead: true,
      ),
    ], delay: delay);
  }

  @override
  Future<int> fetchUnreadCount() async =>
      (await fetchNotifications()).where((item) => !item.isRead).length;

  @override
  Future<AppNotification> markRead(String id) async {
    return (await fetchNotifications())
        .firstWhere((item) => item.id == id)
        .copyWith(isRead: true);
  }

  @override
  Future<void> markAllRead() async {}
}
