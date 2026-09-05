import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/sales_summary.dart';
import 'sales_repository.dart';

/// Live sales from `GET /api/v1/sales/summary` plus `GET /api/v1/leads`.
class ApiSalesRepository implements SalesRepository {
  ApiSalesRepository(this._client);

  final ApiClient _client;

  @override
  Future<SalesSummary> fetchSummary() async {
    final summaryResponse = await _client.get<dynamic>(
      ApiEndpoints.salesSummary,
    );
    final summaryJson = ApiEnvelope.dataMap(summaryResponse.data);
    final leads = await _fetchLeads();
    final parsed = SalesSummary.fromJson({...summaryJson, 'leadItems': leads});
    final leadCount = summaryJson['leads'] is Map
        ? (summaryJson['leads']['total'] as num?)?.toInt() ?? leads.length
        : leads.length;
    final converted = summaryJson['leads'] is Map
        ? (summaryJson['leads']['converted'] as num?)?.toInt() ?? 0
        : parsed.conversions;
    final commentary =
        'Pipeline ${parsed.pipelineValue.toStringAsFixed(0)} INR across $leadCount leads. $converted converted.';
    return SalesSummary(
      monthToDate: parsed.monthToDate,
      target: parsed.target,
      pipelineValue: parsed.pipelineValue,
      newLeads: parsed.newLeads,
      conversions: parsed.conversions,
      outstandingOrders: parsed.outstandingOrders,
      commentary: commentary,
      leads: leads,
    );
  }

  Future<List<SalesLead>> _fetchLeads() async {
    final leads = <SalesLead>[];
    var page = 1;
    var totalPages = 1;
    while (page <= totalPages && page <= 20) {
      final response = await _client.get<dynamic>(
        ApiEndpoints.leads,
        queryParameters: {'page': '$page', 'limit': '100'},
      );
      final items = ApiEnvelope.dataList(response.data);
      for (final item in items) {
        try {
          leads.add(SalesLead.fromJson(item));
        } catch (_) {}
      }
      final meta = ApiEnvelope.meta(response.data);
      final reported = meta?['totalPages'];
      totalPages = reported is num && reported > 0 ? reported.toInt() : 1;
      if (items.isEmpty) break;
      page += 1;
    }
    return leads;
  }

  @override
  Future<SalesLead> createLead({
    required String name,
    required String source,
    String? companyName,
    String? phone,
    String? email,
    double? estimatedValue,
  }) async {
    final body = <String, dynamic>{
      'name': name.trim(),
      'source': source,
    };
    if (companyName != null && companyName.trim().isNotEmpty) {
      body['companyName'] = companyName.trim();
    }
    if (phone != null && phone.trim().isNotEmpty) body['phone'] = phone.trim();
    if (email != null && email.trim().isNotEmpty) body['email'] = email.trim();
    if (estimatedValue != null && estimatedValue > 0) {
      body['estimatedValue'] = estimatedValue.round();
    }
    final response = await _client.post<dynamic>(
      ApiEndpoints.leads,
      data: body,
    );
    return SalesLead.fromJson(ApiEnvelope.dataMap(response.data));
  }
}
