
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/role_capabilities.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/land_parcel.dart';
import '../repositories/api_land_repository.dart';
import '../repositories/land_repository.dart';

final landRepositoryProvider = Provider<LandRepository>((ref) {
  return ApiLandRepository(ref.watch(apiClientProvider));
});

final landSearchProvider =
    NotifierProvider<LandSearchNotifier, String>(LandSearchNotifier.new);

class LandSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

final landParcelsProvider =
    AsyncNotifierProvider<LandParcelsNotifier, List<LandParcel>>(
  LandParcelsNotifier.new,
);

class LandParcelsNotifier extends AsyncNotifier<List<LandParcel>> {
  @override
  Future<List<LandParcel>> build() async {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) return const [];
    final _ = auth.session?.user.id;
    return ref.read(landRepositoryProvider).fetchParcels();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(landRepositoryProvider).fetchParcels(),
    );
  }

  Future<LandParcel> createParcel(CreateLandParcelInput input) async {
    final created = await ref.read(landRepositoryProvider).createParcel(input);
    await refresh();
    return created;
  }

  Future<LandParcel> updateParcel(String id, UpdateLandParcelInput input) async {
    final updated =
        await ref.read(landRepositoryProvider).updateParcel(id, input);
    await refresh();
    return updated;
  }

  Future<void> deleteParcel(String id) async {
    await ref.read(landRepositoryProvider).deleteParcel(id);
    await refresh();
  }
}

final visibleLandParcelsProvider =
    Provider<AsyncValue<List<LandParcel>>>((ref) {
  final query = ref.watch(landSearchProvider).trim().toLowerCase();
  final parcels = ref.watch(landParcelsProvider);
  return parcels.whenData((items) {
    if (query.isEmpty) return items;
    return items
        .where(
          (p) =>
              p.name.toLowerCase().contains(query) ||
              p.location.toLowerCase().contains(query) ||
              p.ownerName.toLowerCase().contains(query) ||
              p.parcelId.toLowerCase().contains(query) ||
              p.status.label.toLowerCase().contains(query),
        )
        .toList();
  });
});

final canManageLandProvider = Provider<bool>((ref) {
  final role = ref.watch(sessionProvider)?.user.role;
  return RoleCapabilities.can(role, AppCapability.viewProjects) &&
      RoleCapabilities.isManagerOrAbove(role);
});
