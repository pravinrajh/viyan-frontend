
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/land_parcel.dart';
import 'land_repository.dart';

class ApiLandRepository implements LandRepository {
  ApiLandRepository(this._client);

  final ApiClient _client;
  static const _pageSize = 100;

  @override
  Future<List<LandParcel>> fetchParcels() async {
    final items = <LandParcel>[];
    var page = 1;
    var totalPages = 1;
    while (page <= totalPages && page <= 20) {
      final response = await _client.get<dynamic>(
        ApiEndpoints.landParcels,
        queryParameters: {'page': '$page', 'limit': '$_pageSize'},
      );
      final rows = ApiEnvelope.dataList(response.data);
      for (final row in rows) {
        try {
          items.add(LandParcel.fromJson(row));
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
  Future<LandParcel> fetchParcel(String id) async {
    final response = await _client.get<dynamic>(ApiEndpoints.landParcel(id));
    return LandParcel.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<LandParcel> createParcel(CreateLandParcelInput input) async {
    final body = <String, dynamic>{'name': input.name.trim()};
    if (input.location.trim().isNotEmpty) body['location'] = input.location.trim();
    if (input.areaNote.trim().isNotEmpty) body['areaNote'] = input.areaNote.trim();
    if (input.ownerName.trim().isNotEmpty) body['ownerName'] = input.ownerName.trim();
    if (input.askingPrice != null) body['askingPrice'] = input.askingPrice;
    if (input.status != null) body['status'] = input.status!.apiValue;
    final projectId = input.projectId?.trim();
    if (projectId != null && projectId.isNotEmpty) body['projectId'] = projectId;
    if (input.notes.trim().isNotEmpty) body['notes'] = input.notes.trim();
    final response = await _client.post<dynamic>(
      ApiEndpoints.landParcels,
      data: body,
    );
    return LandParcel.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<LandParcel> updateParcel(String id, UpdateLandParcelInput input) async {
    final body = <String, dynamic>{};
    if (input.name != null) body['name'] = input.name!.trim();
    if (input.location != null) body['location'] = input.location!.trim();
    if (input.areaNote != null) body['areaNote'] = input.areaNote!.trim();
    if (input.ownerName != null) body['ownerName'] = input.ownerName!.trim();
    if (input.askingPrice != null) body['askingPrice'] = input.askingPrice;
    if (input.status != null) body['status'] = input.status!.apiValue;
    if (input.projectId != null) body['projectId'] = input.projectId;
    if (input.notes != null) body['notes'] = input.notes!.trim();
    final response = await _client.patch<dynamic>(
      ApiEndpoints.landParcel(id),
      data: body,
    );
    return LandParcel.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<void> deleteParcel(String id) async {
    await _client.delete<dynamic>(ApiEndpoints.landParcel(id));
  }
}
