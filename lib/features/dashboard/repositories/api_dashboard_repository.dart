import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/dashboard_summary.dart';
import 'dashboard_repository.dart';

/// Live dashboard repository for MD_EAO_BACKEND `GET /api/v1/dashboard`.
class ApiDashboardRepository implements DashboardRepository {
  ApiDashboardRepository(this._client);

  final ApiClient _client;

  @override
  Future<DashboardSummary> fetchSummary() async {
    final response = await _client.get<dynamic>(ApiEndpoints.dashboard);
    return DashboardSummary.fromJson(ApiEnvelope.dataMap(response.data));
  }
}
