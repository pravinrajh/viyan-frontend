import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/role_capabilities.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/invoice.dart';
import '../repositories/api_invoice_repository.dart';
import '../repositories/invoice_repository.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return ApiInvoiceRepository(ref.watch(apiClientProvider));
});

final invoiceSearchProvider =
    NotifierProvider<InvoiceSearchNotifier, String>(InvoiceSearchNotifier.new);

class InvoiceSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

final invoicesProvider =
    AsyncNotifierProvider<InvoicesNotifier, List<Invoice>>(InvoicesNotifier.new);

class InvoicesNotifier extends AsyncNotifier<List<Invoice>> {
  @override
  Future<List<Invoice>> build() async {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) return const [];
    final _ = auth.session?.user.id;
    return ref.read(invoiceRepositoryProvider).fetchInvoices();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(invoiceRepositoryProvider).fetchInvoices(),
    );
  }

  Future<Invoice> createInvoice(CreateInvoiceInput input) async {
    final created =
        await ref.read(invoiceRepositoryProvider).createInvoice(input);
    await refresh();
    return created;
  }

  Future<Invoice> updateInvoice(String id, UpdateInvoiceInput input) async {
    final updated =
        await ref.read(invoiceRepositoryProvider).updateInvoice(id, input);
    ref.invalidate(invoiceDetailProvider(id));
    await refresh();
    return updated;
  }

  Future<void> deleteInvoice(String id) async {
    await ref.read(invoiceRepositoryProvider).deleteInvoice(id);
    await refresh();
  }

  Future<Invoice> recordPayment(
    String id,
    RecordInvoicePaymentInput input,
  ) async {
    final updated =
        await ref.read(invoiceRepositoryProvider).recordPayment(id, input);
    ref.invalidate(invoiceDetailProvider(id));
    await refresh();
    return updated;
  }
}

final invoiceDetailProvider = FutureProvider.family<Invoice, String>((ref, id) {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) {
    throw StateError('Not authenticated');
  }
  return ref.watch(invoiceRepositoryProvider).fetchInvoice(id);
});

final invoiceCustomersProvider =
    FutureProvider<List<InvoiceCustomerOption>>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) return const [];
  return ref.watch(invoiceRepositoryProvider).fetchCustomers();
});

final visibleInvoicesProvider = Provider<AsyncValue<List<Invoice>>>((ref) {
  final query = ref.watch(invoiceSearchProvider).trim().toLowerCase();
  final invoices = ref.watch(invoicesProvider);
  return invoices.whenData((items) {
    if (query.isEmpty) return items;
    return items
        .where(
          (invoice) =>
              invoice.invoiceNumber.toLowerCase().contains(query) ||
              invoice.invoiceId.toLowerCase().contains(query) ||
              invoice.customerId.toLowerCase().contains(query) ||
              invoice.description.toLowerCase().contains(query) ||
              invoice.status.label.toLowerCase().contains(query),
        )
        .toList();
  });
});

/// Invoices replace collections conceptually for MD/ADMIN/MANAGER.
final canManageInvoicesProvider = Provider<bool>((ref) {
  final role = ref.watch(sessionProvider)?.user.role;
  return RoleCapabilities.can(role, AppCapability.viewCollections) &&
      RoleCapabilities.isManagerOrAbove(role);
});
