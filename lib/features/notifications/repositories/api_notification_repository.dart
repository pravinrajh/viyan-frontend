import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/app_notification.dart';
import 'notification_repository.dart';

/// Live notifications from `GET /api/v1/notifications`.
class ApiNotificationRepository implements NotificationRepository {
  ApiNotificationRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    final items = <AppNotification>[];
    var page = 1;
    var totalPages = 1;
    while (page <= totalPages && page <= 20) {
      final response = await _client.get<dynamic>(
        ApiEndpoints.notifications,
        queryParameters: {'page': '$page', 'limit': '100'},
      );
      final rows = ApiEnvelope.dataList(response.data);
      for (final row in rows) {
        try {
          items.add(AppNotification.fromJson(row));
        } catch (_) {}
      }
      final meta = ApiEnvelope.meta(response.data);
      final reported = meta?['totalPages'];
      totalPages = reported is num && reported > 0 ? reported.toInt() : 1;
      if (rows.isEmpty) break;
      page += 1;
    }
    return items;
  }

  @override
  Future<int> fetchUnreadCount() async {
    final response = await _client.get<dynamic>(
      ApiEndpoints.notificationUnreadCount,
    );
    final data = ApiEnvelope.dataMap(response.data);
    return (data['count'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<AppNotification> markRead(String id) async {
    final response = await _client.patch<dynamic>(
      ApiEndpoints.notificationRead(id),
    );
    return AppNotification.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<void> markAllRead() async {
    await _client.patch<dynamic>(ApiEndpoints.notificationsReadAll);
  }
}
