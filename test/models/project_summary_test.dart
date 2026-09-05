import 'package:flutter_test/flutter_test.dart';
import 'package:md_eao/features/projects/models/project_summary.dart';

void main() {
  test('ProjectSummary parses Swagger list payload', () {
    final project = ProjectSummary.fromJson({
      'id': '64f0c2a1b8e4d12a9c7f0011',
      'projectId': 'PROJ-000001',
      'name': 'Chennai Villa',
      'code': 'CHN-VILLA',
      'description': 'Residential villa',
      'location': 'ECR, Chennai',
      'projectType': 'RESIDENTIAL',
      'managerId': '64f0c2a1b8e4d12a9c7f0022',
      'manager': {
        'id': '64f0c2a1b8e4d12a9c7f0022',
        'name': 'Raj Kumar',
        'employeeCode': 'EMP-000001',
      },
      'status': 'ACTIVE',
      'progress': 68,
      'budget': 22000000,
      'actualExpense': 14800000,
      'startDate': '2026-01-15T00:00:00.000Z',
      'expectedEndDate': '2026-11-30T00:00:00.000Z',
    });

    expect(project.id, '64f0c2a1b8e4d12a9c7f0011');
    expect(project.projectId, 'PROJ-000001');
    expect(project.type, 'RESIDENTIAL');
    expect(project.owner, 'Raj Kumar');
    expect(project.progressPercent, 68);
    expect(project.progressFraction, closeTo(0.68, 0.001));
    expect(project.risk, 'low');
    expect(project.customerName, '');
  });

  test('hydrated customer name maps onto ProjectSummary', () {
    final project = ProjectSummary.fromJson({
      'id': '64f0c2a1b8e4d12a9c7f0011',
      'name': 'Chennai Residences',
      'status': 'ACTIVE',
      'progress': 42,
      'budget': 85000000,
      'actualExpense': 31200000,
      'customer': {
        'id': '64f0c2a1b8e4d12a9c7f0033',
        'name': 'Lakshmi Rao',
        'customerId': 'CUST-SEED-001',
      },
    });
    expect(project.customerName, 'Lakshmi Rao');
  });

  test('AT_RISK status maps to high risk', () {
    final project = ProjectSummary.fromJson({
      'id': '64f0c2a1b8e4d12a9c7f0012',
      'name': 'OMR Commercial',
      'status': 'AT_RISK',
      'progress': 35,
      'budget': 46000000,
      'actualExpense': 15200000,
    });
    expect(project.risk, 'high');
  });

  test('ProjectSummary reads Mongo _id when id is absent', () {
    final project = ProjectSummary.fromJson({
      '_id': '6a873d0aae502ed8e76cc1a2',
      'name': 'Coimbatore Internal Fit-out',
      'projectType': 'INTERNAL',
      'status': 'PLANNING',
      'progress': 10,
      'budget': 4500000,
      'actualExpense': 250000,
      'manager': {'name': 'Anand Kumar'},
      'expectedEndDate': '2026-11-18T10:00:00.000Z',
    });

    expect(project.id, '6a873d0aae502ed8e76cc1a2');
    expect(project.owner, 'Anand Kumar');
    expect(project.progressPercent, 10);
  });
}
