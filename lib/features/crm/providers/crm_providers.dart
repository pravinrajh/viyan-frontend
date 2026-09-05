import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/crm_overview.dart';
import '../repositories/api_crm_repository.dart';
import '../repositories/crm_repository.dart';

final crmRepositoryProvider = Provider<CrmRepository>((ref) {
  return ApiCrmRepository(ref.watch(apiClientProvider));
});

final crmOverviewProvider = FutureProvider<CrmOverview>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) {
    return const CrmOverview(message: '', openFollowUps: 0);
  }
  return ref.watch(crmRepositoryProvider).fetchOverview();
});
