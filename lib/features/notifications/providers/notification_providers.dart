import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/app_notification.dart';
import '../repositories/api_notification_repository.dart';
import '../repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return ApiNotificationRepository(ref.watch(apiClientProvider));
});

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
      NotificationsNotifier.new,
    );

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) return const [];
    return ref.read(notificationRepositoryProvider).fetchNotifications();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(notificationRepositoryProvider).fetchNotifications(),
    );
  }

  Future<void> markRead(String id) async {
    final items = state.asData?.value;
    if (items == null) return;
    final index = items.indexWhere((item) => item.id == id);
    if (index < 0 || items[index].isRead) return;
    final optimistic = [...items];
    optimistic[index] = optimistic[index].copyWith(isRead: true);
    state = AsyncData(optimistic);
    try {
      await ref.read(notificationRepositoryProvider).markRead(id);
    } catch (_) {
      state = AsyncData(items);
      rethrow;
    }
  }

  Future<void> markAllRead() async {
    final items = state.asData?.value;
    if (items == null || items.every((item) => item.isRead)) return;
    final optimistic = items
        .map((item) => item.copyWith(isRead: true))
        .toList();
    state = AsyncData(optimistic);
    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
    } catch (_) {
      state = AsyncData(items);
      rethrow;
    }
  }
}
