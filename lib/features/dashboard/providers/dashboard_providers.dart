import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/dashboard_summary.dart';
import '../repositories/api_dashboard_repository.dart';
import '../repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return ApiDashboardRepository(ref.watch(apiClientProvider));
});

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardSummary>(
      DashboardNotifier.new,
    );

class DashboardNotifier extends AsyncNotifier<DashboardSummary> {
  @override
  Future<DashboardSummary> build() async {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) return DashboardSummary.empty;
    final _ = auth.session?.user.id;
    return ref.read(dashboardRepositoryProvider).fetchSummary();
  }

  Future<void> refresh() async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) {
      state = const AsyncData(DashboardSummary.empty);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(dashboardRepositoryProvider).fetchSummary(),
    );
  }
}
