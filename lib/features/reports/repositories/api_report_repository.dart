import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/daily_report.dart';
import 'report_repository.dart';

/// Morning brief from `GET /api/v1/dashboard/morning-report`.
class ApiReportRepository implements ReportRepository {
  ApiReportRepository(this._client);

  final ApiClient _client;

  @override
  Future<DailyReport> fetchDailyReport() async {
    final response = await _client.get<dynamic>(
      ApiEndpoints.dashboardMorningReport,
    );
    return DailyReport.fromJson(ApiEnvelope.dataMap(response.data));
  }
}
