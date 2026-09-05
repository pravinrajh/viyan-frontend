import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/project_summary.dart';
import 'project_repository.dart';

/// Live projects from MD_EAO_BACKEND.
class ApiProjectRepository implements ProjectRepository {
  ApiProjectRepository(this._client);

  final ApiClient _client;

  static const _pageSize = 100;

  @override
  Future<List<ProjectSummary>> fetchProjects() async {
    final projects = <ProjectSummary>[];
    var page = 1;
    var totalPages = 1;

    while (page <= totalPages && page <= 20) {
      final response = await _client.get<dynamic>(
        ApiEndpoints.projects,
        queryParameters: {'page': '$page', 'limit': '$_pageSize'},
      );
      final items = ApiEnvelope.dataList(response.data);
      for (final item in items) {
        try {
          projects.add(ProjectSummary.fromJson(item));
        } catch (_) {
          // Skip a malformed row instead of emptying the whole list.
        }
      }

      final meta = ApiEnvelope.meta(response.data);
      final reported = meta?['totalPages'];
      totalPages = reported is num && reported > 0 ? reported.toInt() : 1;
      if (items.isEmpty) break;
      page += 1;
    }

    return projects;
  }

  @override
  Future<ProjectSummary> createProject(CreateProjectInput input) async {
    final body = <String, dynamic>{
      'name': input.name.trim(),
      'projectType': input.projectType,
      'managerId': input.managerId,
      'status': input.status,
    };
    if (input.code.trim().isNotEmpty) body['code'] = input.code.trim();
    if (input.description.trim().isNotEmpty) {
      body['description'] = input.description.trim();
    }
    if (input.location.trim().isNotEmpty) {
      body['location'] = input.location.trim();
    }
    if (input.budget > 0) body['budget'] = input.budget.round();
    if (input.customerId != null && input.customerId!.isNotEmpty) {
      body['customerId'] = input.customerId;
    }
    final response = await _client.post<dynamic>(
      ApiEndpoints.projects,
      data: body,
    );
    return ProjectSummary.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<ProjectSummary> updateProject(
    String id, {
    String? name,
    String? description,
    String? location,
    String? projectType,
    String? status,
    double? progress,
    double? budget,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name.trim();
    if (description != null) body['description'] = description.trim();
    if (location != null) body['location'] = location.trim();
    if (projectType != null) body['projectType'] = projectType;
    if (status != null) body['status'] = status;
    if (progress != null) body['progress'] = progress.round();
    if (budget != null) body['budget'] = budget.round();
    final response = await _client.patch<dynamic>(
      ApiEndpoints.project(id),
      data: body,
    );
    return ProjectSummary.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<ProjectSummary> updateStatus(String id, String status) async {
    final response = await _client.patch<dynamic>(
      ApiEndpoints.projectStatus(id),
      data: {'status': status},
    );
    return ProjectSummary.fromJson(ApiEnvelope.dataMap(response.data));
  }
}
