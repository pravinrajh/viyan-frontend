import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/crm_overview.dart';
import 'crm_repository.dart';

/// CRM overview from `GET /api/v1/sales/summary` and follow-ups.
class ApiCrmRepository implements CrmRepository {
  ApiCrmRepository(this._client);

  final ApiClient _client;

  @override
  Future<CrmOverview> fetchOverview() async {
    final summaryResponse = await _client.get<dynamic>(
      ApiEndpoints.salesSummary,
    );
    final summary = ApiEnvelope.dataMap(summaryResponse.data);
    final leads = summary['leads'] is Map
        ? Map<String, dynamic>.from(summary['leads'] as Map)
        : const <String, dynamic>{};
    final customers = summary['customers'] is Map
        ? Map<String, dynamic>.from(summary['customers'] as Map)
        : const <String, dynamic>{};
    final opportunities = summary['opportunities'] is Map
        ? Map<String, dynamic>.from(summary['opportunities'] as Map)
        : const <String, dynamic>{};
    final pipeline = summary['pipeline'] is Map
        ? Map<String, dynamic>.from(summary['pipeline'] as Map)
        : const <String, dynamic>{};

    var openFollowUps = 0;
    try {
      final followUpsResponse = await _client.get<dynamic>(
        ApiEndpoints.salesFollowUps,
      );
      final followUps = ApiEnvelope.dataMap(followUpsResponse.data);
      final leadBlock = followUps['leads'];
      final oppBlock = followUps['opportunities'];
      if (leadBlock is Map) {
        openFollowUps += (leadBlock['total'] as num?)?.toInt() ?? 0;
      }
      if (oppBlock is Map) {
        openFollowUps += (oppBlock['total'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {}

    final message =
        '${leads['total'] ?? 0} leads (${leads['converted'] ?? 0} converted), '
        '${customers['active'] ?? 0} active customers, '
        '${opportunities['open'] ?? 0} open opportunities, '
        'pipeline ${pipeline['totalValue'] ?? 0}. '
        '$openFollowUps follow-ups due.';

    return CrmOverview(message: message, openFollowUps: openFollowUps);
  }
}
