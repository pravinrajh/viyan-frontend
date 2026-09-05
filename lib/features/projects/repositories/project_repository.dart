import '../models/project_summary.dart';

class CreateProjectInput {
  const CreateProjectInput({
    required this.name,
    required this.projectType,
    required this.managerId,
    this.code = '',
    this.description = '',
    this.location = '',
    this.budget = 0,
    this.customerId,
    this.status = 'PLANNING',
  });

  final String name;
  final String projectType;
  final String managerId;
  final String code;
  final String description;
  final String location;
  final double budget;
  final String? customerId;
  final String status;
}

abstract class ProjectRepository {
  Future<List<ProjectSummary>> fetchProjects();
  Future<ProjectSummary> createProject(CreateProjectInput input);
  Future<ProjectSummary> updateProject(
    String id, {
    String? name,
    String? description,
    String? location,
    String? projectType,
    String? status,
    double? progress,
    double? budget,
  });
  Future<ProjectSummary> updateStatus(String id, String status);
}
