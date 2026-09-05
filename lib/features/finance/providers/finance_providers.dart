import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/finance_summary.dart';
import '../repositories/api_finance_repository.dart';
import '../repositories/finance_repository.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return ApiFinanceRepository(ref.watch(apiClientProvider));
});

final financeSummaryProvider = FutureProvider<FinanceSummary>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) {
    return const FinanceSummary(
      cashOnHand: 0,
      receivables: 0,
      payables: 0,
      weeklyRequirement: 0,
      expectedCollections: 0,
      commentary: '',
    );
  }
  return ref.watch(financeRepositoryProvider).fetchSummary();
});
