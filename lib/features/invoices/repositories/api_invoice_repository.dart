import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/invoice.dart';
import 'invoice_repository.dart';

class ApiInvoiceRepository implements InvoiceRepository {
  ApiInvoiceRepository(this._client);

  final ApiClient _client;

  static const _pageSize = 100;

  @override
  Future<List<Invoice>> fetchInvoices() async {
    final invoices = <Invoice>[];
    var page = 1;
    var totalPages = 1;

    while (page <= totalPages && page <= 20) {
      final response = await _client.get<dynamic>(
        ApiEndpoints.invoices,
        queryParameters: {'page': '$page', 'limit': '$_pageSize'},
      );
      final items = ApiEnvelope.dataList(response.data);
      for (final item in items) {
        try {
          invoices.add(Invoice.fromJson(item));
        } catch (_) {}
      }
      final meta = ApiEnvelope.meta(response.data);
      final reported = meta?['totalPages'];
      totalPages = reported is num && reported > 0 ? reported.toInt() : 1;
      if (items.isEmpty) break;
      page += 1;
    }

    return invoices;
  }

  @override
  Future<Invoice> fetchInvoice(String id) async {
    final response = await _client.get<dynamic>(ApiEndpoints.invoice(id));
    return Invoice.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<Invoice> createInvoice(CreateInvoiceInput input) async {
    final body = <String, dynamic>{
      'customerId': input.customerId.trim(),
      'amount': input.amount,
    };
    final projectId = input.projectId?.trim();
    if (projectId != null && projectId.isNotEmpty) {
      body['projectId'] = projectId;
    }
    if (input.dueDate != null) {
      body['dueDate'] = input.dueDate!.toUtc().toIso8601String();
    }
    if (input.issueDate != null) {
      body['issueDate'] = input.issueDate!.toUtc().toIso8601String();
    }
    if (input.description.trim().isNotEmpty) {
      body['description'] = input.description.trim();
    }
    final response = await _client.post<dynamic>(
      ApiEndpoints.invoices,
      data: body,
    );
    return Invoice.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<Invoice> updateInvoice(String id, UpdateInvoiceInput input) async {
    final body = <String, dynamic>{};
    if (input.description != null) {
      body['description'] = input.description!.trim();
    }
    if (input.dueDate != null) {
      body['dueDate'] = input.dueDate!.toUtc().toIso8601String();
    }
    if (input.cancel) {
      body['status'] = 'CANCELLED';
    }
    final response = await _client.patch<dynamic>(
      ApiEndpoints.invoice(id),
      data: body,
    );
    return Invoice.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<void> deleteInvoice(String id) async {
    await _client.delete<dynamic>(ApiEndpoints.invoice(id));
  }

  @override
  Future<Invoice> recordPayment(
    String id,
    RecordInvoicePaymentInput input,
  ) async {
    // OpenAPI: paymentMethod, notes, postToFinance, accountId, categoryId
    final body = <String, dynamic>{'amount': input.amount};
    if (input.paymentMethod != null && input.paymentMethod!.isNotEmpty) {
      body['paymentMethod'] = input.paymentMethod;
    }
    if (input.notes.trim().isNotEmpty) {
      body['notes'] = input.notes.trim();
    }
    if (input.postToFinance) {
      body['postToFinance'] = true;
    }
    final accountId = input.accountId?.trim();
    if (accountId != null && accountId.isNotEmpty) {
      body['accountId'] = accountId;
    }
    final categoryId = input.categoryId?.trim();
    if (categoryId != null && categoryId.isNotEmpty) {
      body['categoryId'] = categoryId;
    }
    final response = await _client.post<dynamic>(
      ApiEndpoints.invoicePayments(id),
      data: body,
    );
    return Invoice.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<List<InvoiceCustomerOption>> fetchCustomers() async {
    final customers = <InvoiceCustomerOption>[];
    var page = 1;
    var totalPages = 1;

    while (page <= totalPages && page <= 20) {
      final response = await _client.get<dynamic>(
        ApiEndpoints.customers,
        queryParameters: {'page': '$page', 'limit': '$_pageSize'},
      );
      final items = ApiEnvelope.dataList(response.data);
      for (final item in items) {
        try {
          final option = InvoiceCustomerOption.fromJson(item);
          if (option.id.isNotEmpty) customers.add(option);
        } catch (_) {}
      }
      final meta = ApiEnvelope.meta(response.data);
      final reported = meta?['totalPages'];
      totalPages = reported is num && reported > 0 ? reported.toInt() : 1;
      if (items.isEmpty) break;
      page += 1;
    }

    return customers;
  }
}
