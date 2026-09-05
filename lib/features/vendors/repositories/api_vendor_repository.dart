
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/vendor.dart';
import 'vendor_repository.dart';

class ApiVendorRepository implements VendorRepository {
  ApiVendorRepository(this._client);

  final ApiClient _client;
  static const _pageSize = 100;

  @override
  Future<List<Vendor>> fetchVendors() async {
    final items = <Vendor>[];
    var page = 1;
    var totalPages = 1;
    while (page <= totalPages && page <= 20) {
      final response = await _client.get<dynamic>(
        ApiEndpoints.vendors,
        queryParameters: {'page': '$page', 'limit': '$_pageSize'},
      );
      final rows = ApiEnvelope.dataList(response.data);
      for (final row in rows) {
        try {
          items.add(Vendor.fromJson(row));
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
  Future<Vendor> fetchVendor(String id) async {
    final response = await _client.get<dynamic>(ApiEndpoints.vendor(id));
    return Vendor.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<Vendor> createVendor(CreateVendorInput input) async {
    final body = <String, dynamic>{'name': input.name.trim()};
    if (input.phone.trim().isNotEmpty) body['phone'] = input.phone.trim();
    if (input.email.trim().isNotEmpty) body['email'] = input.email.trim();
    if (input.location.trim().isNotEmpty) {
      body['location'] = input.location.trim();
    }
    if (input.taxId.trim().isNotEmpty) body['taxId'] = input.taxId.trim();
    if (input.notes.trim().isNotEmpty) body['notes'] = input.notes.trim();
    final response = await _client.post<dynamic>(
      ApiEndpoints.vendors,
      data: body,
    );
    return Vendor.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<Vendor> updateVendor(String id, UpdateVendorInput input) async {
    final body = <String, dynamic>{};
    if (input.name != null) body['name'] = input.name!.trim();
    if (input.phone != null) body['phone'] = input.phone!.trim();
    if (input.email != null) body['email'] = input.email!.trim();
    if (input.location != null) body['location'] = input.location!.trim();
    if (input.taxId != null) body['taxId'] = input.taxId!.trim();
    if (input.status != null) body['status'] = input.status!.apiValue;
    if (input.notes != null) body['notes'] = input.notes!.trim();
    final response = await _client.patch<dynamic>(
      ApiEndpoints.vendor(id),
      data: body,
    );
    return Vendor.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<void> deleteVendor(String id) async {
    await _client.delete<dynamic>(ApiEndpoints.vendor(id));
  }
}
