
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/sales_activity.dart';
import 'sales_activity_repository.dart';

class ApiSalesActivityRepository implements SalesActivityRepository {
  ApiSalesActivityRepository(this._client);

  final ApiClient _client;
  static const _pageSize = 100;

  @override
  Future<List<SalesActivity>> fetchActivities() async {
    final items = <SalesActivity>[];
    var page = 1;
    var totalPages = 1;
    while (page <= totalPages && page <= 20) {
      final response = await _client.get<dynamic>(
        ApiEndpoints.salesActivities,
        queryParameters: {'page': '$page', 'limit': '$_pageSize'},
      );
      final rows = ApiEnvelope.dataList(response.data);
      for (final row in rows) {
        try {
          items.add(SalesActivity.fromJson(row));
        } catch (_) {}
      }
      final meta = ApiEnvelope.meta(response.data);
      final reported = meta?['totalPages'];
      totalPages = reported is num && reported > 0 ? reported.toInt() : 1;
      if (rows.isEmpty) break;
      page += 1;
    }
    return items;
  }

  @override
  Future<SalesActivity> fetchActivity(String id) async {
    final response = await _client.get<dynamic>(ApiEndpoints.salesActivity(id));
    return SalesActivity.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<SalesActivity> createActivity(CreateSalesActivityInput input) async {
    final body = <String, dynamic>{
      'type': input.type.apiValue,
      'title': input.title.trim(),
    };
    if (input.description.trim().isNotEmpty) {
      body['description'] = input.description.trim();
    }
    void putId(String key, String? value) {
      final v = value?.trim();
      if (v != null && v.isNotEmpty) body[key] = v;
    }

    putId('leadId', input.leadId);
    putId('customerId', input.customerId);
    putId('opportunityId', input.opportunityId);
    putId('employeeId', input.employeeId);
    if (input.scheduledAt != null) {
      body['scheduledAt'] = input.scheduledAt!.toUtc().toIso8601String();
    }
    if (input.status != null) body['status'] = input.status!.apiValue;
    final response = await _client.post<dynamic>(
      ApiEndpoints.salesActivities,
      data: body,
    );
    return SalesActivity.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<SalesActivity> updateActivity(
    String id,
    UpdateSalesActivityInput input,
  ) async {
    final body = <String, dynamic>{};
    if (input.type != null) body['type'] = input.type!.apiValue;
    if (input.title != null) body['title'] = input.title!.trim();
    if (input.description != null) {
      body['description'] = input.description!.trim();
    }
    if (input.leadId != null) body['leadId'] = input.leadId;
    if (input.customerId != null) body['customerId'] = input.customerId;
    if (input.opportunityId != null) {
      body['opportunityId'] = input.opportunityId;
    }
    if (input.employeeId != null) body['employeeId'] = input.employeeId;
    if (input.scheduledAt != null) {
      body['scheduledAt'] = input.scheduledAt!.toUtc().toIso8601String();
    }
    final response = await _client.patch<dynamic>(
      ApiEndpoints.salesActivity(id),
      data: body,
    );
    return SalesActivity.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<SalesActivity> updateStatus(
    String id,
    SalesActivityStatus status,
  ) async {
    final response = await _client.patch<dynamic>(
      ApiEndpoints.salesActivityStatus(id),
      data: {'status': status.apiValue},
    );
    return SalesActivity.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<void> deleteActivity(String id) async {
    await _client.delete<dynamic>(ApiEndpoints.salesActivity(id));
  }
}
