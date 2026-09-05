import '../../../core/utils/mock_delay.dart';
import '../models/project_summary.dart';
import 'project_repository.dart';

class MockProjectRepository implements ProjectRepository {
  MockProjectRepository({this.delay});

  final Duration? delay;

  @override
  Future<List<ProjectSummary>> fetchProjects() {
    final now = DateTime.now();
    final projects = [
      ProjectSummary(
        id: 'prj-1',
        name: 'Chennai Villa',
        type: 'Construction',
        status: 'active',
        risk: 'medium',
        progress: 0.68,
        owner: 'Raj',
        location: 'ECR, Chennai',
        customerName: 'ABC Builders',
        contractValue: 25000000,
        budget: 22000000,
        actualExpense: 14800000,
        dueDate: now.add(const Duration(days: 90)),
        pendingTasks: 3,
        pendingPayments: 4800000,
      ),
      ProjectSummary(
        id: 'prj-2',
        name: 'Coimbatore Interior',
        type: 'Interior',
        status: 'active',
        risk: 'low',
        progress: 0.75,
        owner: 'Priya',
        location: 'RS Puram, Coimbatore',
        customerName: 'Kumar Residence',
        contractValue: 8500000,
        budget: 7800000,
        actualExpense: 5600000,
        dueDate: now.add(const Duration(days: 45)),
        pendingTasks: 2,
        pendingPayments: 1200000,
      ),
      ProjectSummary(
        id: 'prj-3',
        name: 'OMR Commercial',
        type: 'Real Estate / Construction',
        status: 'active',
        risk: 'high',
        progress: 0.35,
        owner: 'Raj',
        location: 'OMR, Chennai',
        customerName: 'XYZ Developers',
        contractValue: 50000000,
        budget: 46000000,
        actualExpense: 15200000,
        dueDate: now.add(const Duration(days: 180)),
        pendingTasks: 4,
        pendingPayments: 8500000,
      ),
      ProjectSummary(
        id: 'prj-4',
        name: 'Madurai Showflat',
        type: 'Interior',
        status: 'active',
        risk: 'low',
        progress: 0.52,
        owner: 'Priya',
        location: 'Madurai',
        customerName: 'Green Homes',
        contractValue: 4200000,
        budget: 3900000,
        actualExpense: 2100000,
        dueDate: now.add(const Duration(days: 60)),
        pendingTasks: 1,
        pendingPayments: 600000,
      ),
      ProjectSummary(
        id: 'prj-5',
        name: 'Salem Warehouse Fit-out',
        type: 'Construction',
        status: 'completed',
        risk: 'low',
        progress: 1.0,
        owner: 'Ops',
        location: 'Salem',
        customerName: 'ABC Builders',
        contractValue: 6100000,
        budget: 5800000,
        actualExpense: 5750000,
        dueDate: now.subtract(const Duration(days: 20)),
        pendingTasks: 0,
        pendingPayments: 0,
      ),
    ];
    return withMockDelay(projects, delay: delay);
  }

  @override
  Future<ProjectSummary> createProject(CreateProjectInput input) async {
    await mockDelay(delay: delay);
    return ProjectSummary(
      id: 'prj-new',
      name: input.name,
      type: input.projectType,
      status: input.status,
      risk: 'low',
      progress: 0,
      owner: 'Manager',
      location: input.location,
      customerName: '',
      contractValue: input.budget,
      budget: input.budget,
      actualExpense: 0,
      dueDate: DateTime.now().add(const Duration(days: 90)),
    );
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
    final items = await fetchProjects();
    final existing = items.firstWhere((p) => p.id == id, orElse: () => items.first);
    return ProjectSummary(
      id: existing.id,
      name: name ?? existing.name,
      type: projectType ?? existing.type,
      status: status ?? existing.status,
      risk: existing.risk,
      progress: progress ?? existing.progress,
      owner: existing.owner,
      location: location ?? existing.location,
      customerName: existing.customerName,
      contractValue: budget ?? existing.contractValue,
      budget: budget ?? existing.budget,
      actualExpense: existing.actualExpense,
      dueDate: existing.dueDate,
      description: description ?? existing.description,
    );
  }

  @override
  Future<ProjectSummary> updateStatus(String id, String status) {
    return updateProject(id, status: status);
  }
}
