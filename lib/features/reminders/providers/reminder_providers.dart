
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/role_capabilities.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/reminder.dart';
import '../repositories/api_reminder_repository.dart';
import '../repositories/reminder_repository.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ApiReminderRepository(ref.watch(apiClientProvider));
});

enum ReminderListScope { all, today, upcoming }

final reminderScopeProvider =
    NotifierProvider<ReminderScopeNotifier, ReminderListScope>(
  ReminderScopeNotifier.new,
);

class ReminderScopeNotifier extends Notifier<ReminderListScope> {
  @override
  ReminderListScope build() => ReminderListScope.today;

  void setScope(ReminderListScope scope) => state = scope;
}

final reminderSearchProvider =
    NotifierProvider<ReminderSearchNotifier, String>(ReminderSearchNotifier.new);

class ReminderSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

final remindersProvider =
    AsyncNotifierProvider<RemindersNotifier, List<Reminder>>(
  RemindersNotifier.new,
);

class RemindersNotifier extends AsyncNotifier<List<Reminder>> {
  @override
  Future<List<Reminder>> build() async {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) return const [];
    final _ = auth.session?.user.id;
    final scope = ref.watch(reminderScopeProvider);
    final repo = ref.read(reminderRepositoryProvider);
    return switch (scope) {
      ReminderListScope.today => repo.fetchToday(),
      ReminderListScope.upcoming => repo.fetchUpcoming(),
      ReminderListScope.all => repo.fetchReminders(),
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final scope = ref.read(reminderScopeProvider);
    final repo = ref.read(reminderRepositoryProvider);
    state = await AsyncValue.guard(() async {
      return switch (scope) {
        ReminderListScope.today => repo.fetchToday(),
        ReminderListScope.upcoming => repo.fetchUpcoming(),
        ReminderListScope.all => repo.fetchReminders(),
      };
    });
  }

  Future<Reminder> createReminder(CreateReminderInput input) async {
    final created =
        await ref.read(reminderRepositoryProvider).createReminder(input);
    await refresh();
    return created;
  }

  Future<void> complete(String id) async {
    await ref.read(reminderRepositoryProvider).complete(id);
    await refresh();
  }

  Future<void> cancel(String id) async {
    await ref.read(reminderRepositoryProvider).cancel(id);
    await refresh();
  }

  Future<void> snooze(String id, DateTime scheduledAt) async {
    await ref.read(reminderRepositoryProvider).snooze(id, scheduledAt);
    await refresh();
  }
}

final visibleRemindersProvider = Provider<AsyncValue<List<Reminder>>>((ref) {
  final query = ref.watch(reminderSearchProvider).trim().toLowerCase();
  final reminders = ref.watch(remindersProvider);
  return reminders.whenData((items) {
    if (query.isEmpty) return items;
    return items
        .where(
          (r) =>
              r.title.toLowerCase().contains(query) ||
              r.description.toLowerCase().contains(query) ||
              r.reminderId.toLowerCase().contains(query) ||
              r.status.label.toLowerCase().contains(query),
        )
        .toList();
  });
});

final canManageRemindersProvider = Provider<bool>((ref) {
  final role = ref.watch(sessionProvider)?.user.role;
  return RoleCapabilities.isManagerOrAbove(role);
});
