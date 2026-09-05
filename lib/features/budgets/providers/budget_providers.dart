
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/role_capabilities.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/budget.dart';
import '../repositories/api_budget_repository.dart';
import '../repositories/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return ApiBudgetRepository(ref.watch(apiClientProvider));
});

final budgetSearchProvider =
    NotifierProvider<BudgetSearchNotifier, String>(BudgetSearchNotifier.new);

class BudgetSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

final budgetsProvider =
    AsyncNotifierProvider<BudgetsNotifier, List<Budget>>(BudgetsNotifier.new);

class BudgetsNotifier extends AsyncNotifier<List<Budget>> {
  @override
  Future<List<Budget>> build() async {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) return const [];
    final _ = auth.session?.user.id;
    return ref.read(budgetRepositoryProvider).fetchBudgets();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(budgetRepositoryProvider).fetchBudgets(),
    );
  }

  Future<Budget> createBudget(CreateBudgetInput input) async {
    final created = await ref.read(budgetRepositoryProvider).createBudget(input);
    await refresh();
    return created;
  }

  Future<Budget> updateBudget(String id, UpdateBudgetInput input) async {
    final updated =
        await ref.read(budgetRepositoryProvider).updateBudget(id, input);
    ref.invalidate(budgetSummaryProvider(id));
    await refresh();
    return updated;
  }

  Future<void> deleteBudget(String id) async {
    await ref.read(budgetRepositoryProvider).deleteBudget(id);
    await refresh();
  }
}

final budgetSummaryProvider =
    FutureProvider.family<BudgetSummary, String>((ref, id) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) {
    throw StateError('Not authenticated');
  }
  return ref.watch(budgetRepositoryProvider).fetchSummary(id);
});

final visibleBudgetsProvider = Provider<AsyncValue<List<Budget>>>((ref) {
  final query = ref.watch(budgetSearchProvider).trim().toLowerCase();
  final budgets = ref.watch(budgetsProvider);
  return budgets.whenData((items) {
    if (query.isEmpty) return items;
    return items
        .where(
          (b) =>
              b.name.toLowerCase().contains(query) ||
              b.budgetId.toLowerCase().contains(query) ||
              b.status.label.toLowerCase().contains(query),
        )
        .toList();
  });
});

final canManageBudgetsProvider = Provider<bool>((ref) {
  final role = ref.watch(sessionProvider)?.user.role;
  return RoleCapabilities.can(role, AppCapability.viewFinance) &&
      RoleCapabilities.isManagerOrAbove(role);
});
