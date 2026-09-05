import 'package:flutter_test/flutter_test.dart';
import 'package:md_eao/features/dashboard/models/dashboard_summary.dart';
import 'package:md_eao/features/dashboard/models/critical_action.dart';

void main() {
  test('DashboardSummary.fromJson maps nested Day-2 structure', () {
    final json = {
      'headline': 'Focus',
      'tasks': {
        'total': 18,
        'pending': 10,
        'inProgress': 5,
        'completed': 5,
        'overdue': 3,
        'items': [
          {
            'id': 't1',
            'title': 'Check Chennai project material',
            'projectName': 'Chennai Villa',
            'assignedEmployee': 'Raj',
            'priority': 'High',
            'status': 'Pending',
            'dueLabel': 'Today',
          },
        ],
      },
      'meetings': {
        'today': 5,
        'upcoming': 3,
        'items': [
          {
            'id': 'm1',
            'title': 'Sales Review',
            'timeLabel': '12:00 PM',
            'participants': ['MD', 'Sales Head'],
          },
        ],
      },
      'sales': {
        'pipelineValue': 84000000,
        'newLeads': 6,
        'qualifiedLeads': 4,
        'converted': 2,
      },
      'collections': {
        'pending': 4200000,
        'overdue': 1500000,
        'expectedThisWeek': 3500000,
      },
      'finance': {
        'weeklyRequirement': 5000000,
        'availableBalance': 11000000,
        'plannedPayments': 3200000,
      },
      'projects': {
        'active': 5,
        'completed': 2,
        'atRisk': 1,
        'items': [
          {
            'id': 'p1',
            'name': 'OMR Commercial',
            'progress': 0.35,
            'risk': 'High',
          },
        ],
      },
      'criticalActions': [
        {
          'id': 'c1',
          'title': 'ABC Builders payment overdue',
          'priority': 'critical',
        },
      ],
    };

    final summary = DashboardSummary.fromJson(json);

    expect(summary.tasks.total, 18);
    expect(summary.tasks.overdue, 3);
    expect(summary.sales.pipelineValue, 84000000);
    expect(summary.collections.pending, 4200000);
    expect(summary.projects.atRisk, 1);
    expect(summary.criticalActions.single.priority, CriticalPriority.critical);
    expect(summary.overviewCards, isNotEmpty);
  });

  test(
    'DashboardSummary.fromJson maps live GET /api/v1/dashboard envelope',
    () {
      final summary = DashboardSummary.fromJson({
        'success': true,
        'message': 'Dashboard fetched',
        'data': {
          'overview': {'activeProjects': 1, 'pendingTasks': 4},
          'attention': [
            {
              'type': 'TASK',
              'priority': 'CRITICAL',
              'title': 'Close overdue waterproofing punch list',
              'sourceId': 'abc',
              'actionUrl': '/tasks/abc',
            },
          ],
          'tasks': {
            'today': {
              'total': 1,
              'pending': 1,
              'inProgress': 0,
              'completed': 0,
              'overdue': 1,
            },
            'overdue': [
              {
                'taskId': 'TASK-SEED-003',
                'title': 'Close overdue waterproofing punch list',
                'priority': 'CRITICAL',
                'assignedTo': {'id': 'e1', 'name': 'Raj Iyer'},
                'project': {'id': 'p1', 'name': 'Chennai Residences'},
                'dueDate': '2026-08-16T10:00:00.000Z',
              },
            ],
          },
          'meetings': {'today': <Map<String, dynamic>>[], 'todayCount': 0},
          'projects': {
            'total': 3,
            'healthy': 1,
            'atRisk': 1,
            'critical': 1,
            'items': [
              {
                'id': '6a873d0aae502ed8e76cc1a2',
                'projectId': 'PROJ-SEED-003',
                'name': 'Coimbatore Internal Fit-out',
                'progress': 10,
                'status': 'PLANNING',
                'health': 'GREEN',
                'healthCode': 'HEALTHY',
              },
            ],
          },
          'sales': {
            'pipelineValue': 67800000,
            'newLeads': 1,
            'qualifiedLeads': 1,
            'wonOpportunities': 0,
          },
          'finance': {'accountBalance': 11000000},
        },
      });

      expect(summary.isEmpty, isFalse);
      expect(summary.projects.active, 3);
      expect(summary.projects.items.single.name, 'Coimbatore Internal Fit-out');
      expect(
        summary.projects.items.single.progressFraction,
        closeTo(0.10, 0.001),
      );
      expect(summary.projects.items.single.risk, 'low');
      expect(summary.tasks.items.single.projectName, 'Chennai Residences');
      expect(summary.criticalActions, isNotEmpty);
      expect(summary.finance.availableBalance, 11000000);
    },
  );
}
