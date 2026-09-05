
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/role_capabilities.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/vendor.dart';
import '../repositories/api_vendor_repository.dart';
import '../repositories/vendor_repository.dart';

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return ApiVendorRepository(ref.watch(apiClientProvider));
});

final vendorSearchProvider =
    NotifierProvider<VendorSearchNotifier, String>(VendorSearchNotifier.new);

class VendorSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

final vendorsProvider =
    AsyncNotifierProvider<VendorsNotifier, List<Vendor>>(VendorsNotifier.new);

class VendorsNotifier extends AsyncNotifier<List<Vendor>> {
  @override
  Future<List<Vendor>> build() async {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) return const [];
    final _ = auth.session?.user.id;
    return ref.read(vendorRepositoryProvider).fetchVendors();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(vendorRepositoryProvider).fetchVendors(),
    );
  }

  Future<Vendor> createVendor(CreateVendorInput input) async {
    final created = await ref.read(vendorRepositoryProvider).createVendor(input);
    await refresh();
    return created;
  }

  Future<Vendor> updateVendor(String id, UpdateVendorInput input) async {
    final updated =
        await ref.read(vendorRepositoryProvider).updateVendor(id, input);
    await refresh();
    return updated;
  }

  Future<void> deleteVendor(String id) async {
    await ref.read(vendorRepositoryProvider).deleteVendor(id);
    await refresh();
  }
}

final visibleVendorsProvider = Provider<AsyncValue<List<Vendor>>>((ref) {
  final query = ref.watch(vendorSearchProvider).trim().toLowerCase();
  final vendors = ref.watch(vendorsProvider);
  return vendors.whenData((items) {
    if (query.isEmpty) return items;
    return items
        .where(
          (v) =>
              v.name.toLowerCase().contains(query) ||
              v.email.toLowerCase().contains(query) ||
              v.phone.toLowerCase().contains(query) ||
              v.location.toLowerCase().contains(query) ||
              v.vendorId.toLowerCase().contains(query),
        )
        .toList();
  });
});

final canManageVendorsProvider = Provider<bool>((ref) {
  final role = ref.watch(sessionProvider)?.user.role;
  return RoleCapabilities.can(role, AppCapability.viewFinance) &&
      RoleCapabilities.isManagerOrAbove(role);
});
