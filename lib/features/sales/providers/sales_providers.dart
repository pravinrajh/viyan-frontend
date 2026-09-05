import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/sales_summary.dart';
import '../repositories/api_sales_repository.dart';
import '../repositories/sales_repository.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return ApiSalesRepository(ref.watch(apiClientProvider));
});

final salesSummaryProvider =
    AsyncNotifierProvider<SalesSummaryNotifier, SalesSummary>(
      SalesSummaryNotifier.new,
    );

class SalesSummaryNotifier extends AsyncNotifier<SalesSummary> {
  @override
  Future<SalesSummary> build() async {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) {
      return const SalesSummary(
        monthToDate: 0,
        target: 0,
        pipelineValue: 0,
        newLeads: 0,
        conversions: 0,
        outstandingOrders: 0,
        commentary: '',
      );
    }
    return ref.read(salesRepositoryProvider).fetchSummary();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(salesRepositoryProvider).fetchSummary(),
    );
  }

  Future<SalesLead> createLead({
    required String name,
    required String source,
    String? companyName,
    String? phone,
    String? email,
    double? estimatedValue,
  }) async {
    final created = await ref
        .read(salesRepositoryProvider)
        .createLead(
          name: name,
          source: source,
          companyName: companyName,
          phone: phone,
          email: email,
          estimatedValue: estimatedValue,
        );
    await refresh();
    return created;
  }
}
