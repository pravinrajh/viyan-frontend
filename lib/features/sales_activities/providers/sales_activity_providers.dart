
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/role_capabilities.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/sales_activity.dart';
import '../repositories/api_sales_activity_repository.dart';
import '../repositories/sales_activity_repository.dart';

final salesActivityRepositoryProvider = Provider<SalesActivityRepository>((ref) {
  return ApiSalesActivityRepository(ref.watch(apiClientProvider));
});

final salesActivitySearchProvider =
    NotifierProvider<SalesActivitySearchNotifier, String>(
  SalesActivitySearchNotifier.new,
);

class SalesActivitySearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

final salesActivitiesProvider =
    AsyncNotifierProvider<SalesActivitiesNotifier, List<SalesActivity>>(
  SalesActivitiesNotifier.new,
);

class SalesActivitiesNotifier extends AsyncNotifier<List<SalesActivity>> {
  @override
  Future<List<SalesActivity>> build() async {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) return const [];
    final _ = auth.session?.user.id;
    return ref.read(salesActivityRepositoryProvider).fetchActivities();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(salesActivityRepositoryProvider).fetchActivities(),
    );
  }

  Future<SalesActivity> createActivity(CreateSalesActivityInput input) async {
    final created =
        await ref.read(salesActivityRepositoryProvider).createActivity(input);
    await refresh();
    return created;
  }

  Future<SalesActivity> updateActivity(
    String id,
    UpdateSalesActivityInput input,
  ) async {
    final updated = await ref
        .read(salesActivityRepositoryProvider)
        .updateActivity(id, input);
    await refresh();
    return updated;
  }

  Future<void> updateStatus(String id, SalesActivityStatus status) async {
    await ref.read(salesActivityRepositoryProvider).updateStatus(id, status);
    await refresh();
  }

  Future<void> deleteActivity(String id) async {
    await ref.read(salesActivityRepositoryProvider).deleteActivity(id);
    await refresh();
  }
}

final visibleSalesActivitiesProvider =
    Provider<AsyncValue<List<SalesActivity>>>((ref) {
  final query = ref.watch(salesActivitySearchProvider).trim().toLowerCase();
  final activities = ref.watch(salesActivitiesProvider);
  return activities.whenData((items) {
    if (query.isEmpty) return items;
    return items
        .where(
          (a) =>
              a.title.toLowerCase().contains(query) ||
              a.description.toLowerCase().contains(query) ||
              a.activityId.toLowerCase().contains(query) ||
              a.type.label.toLowerCase().contains(query) ||
              a.status.label.toLowerCase().contains(query),
        )
        .toList();
  });
});

final canManageSalesActivitiesProvider = Provider<bool>((ref) {
  final role = ref.watch(sessionProvider)?.user.role;
  return RoleCapabilities.can(role, AppCapability.viewSales) &&
      RoleCapabilities.isManagerOrAbove(role);
});
