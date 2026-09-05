import '../../../core/utils/mock_delay.dart';
import '../models/critical_action.dart';
import '../models/dashboard_summary.dart';
import '../models/meeting_summary.dart';
import '../models/section_summaries.dart';
import '../models/task_summary.dart';
import 'dashboard_repository.dart';

/// Day 2 SAT mock data for the executive dashboard.
/// Widgets must not hardcode this data.
class MockDashboardRepository implements DashboardRepository {
  MockDashboardRepository({
    this.delay,
    this.forceEmpty = false,
    this.forceError = false,
  });

  final Duration? delay;
  final bool forceEmpty;
  final bool forceError;

  @override
  Future<DashboardSummary> fetchSummary() async {
    await mockDelay(delay: delay);
    if (forceError) {
      throw StateError('Unable to load business data.');
    }
    if (forceEmpty) {
      return const DashboardSummary(
        headline: '',
        tasks: TaskOverview(
          total: 0,
          pending: 0,
          inProgress: 0,
          completed: 0,
          overdue: 0,
        ),
        meetings: MeetingOverview(today: 0, upcoming: 0),
        sales: DashboardSalesSummary(
          pipelineValue: 0,
          newLeads: 0,
          qualifiedLeads: 0,
          converted: 0,
        ),
        collections: DashboardCollectionSummary(
          pending: 0,
          overdue: 0,
          expectedThisWeek: 0,
        ),
        finance: DashboardFinanceSummary(
          weeklyRequirement: 0,
          availableBalance: 0,
          plannedPayments: 0,
        ),
        projects: ProjectOverview(active: 0, completed: 0, atRisk: 0),
        criticalActions: [],
      );
    }

    return const DashboardSummary(
      headline: '5 critical actions need your attention this morning',
      tasks: TaskOverview(
        total: 18,
        pending: 10,
        inProgress: 5,
        completed: 5,
        overdue: 3,
        items: [
          TaskSummary(
            id: 'dash-task-1',
            title: 'Check Chennai project material',
            projectName: 'Chennai Villa',
            assignedEmployee: 'Raj',
            priority: 'High',
            status: 'Pending',
            dueLabel: 'Today',
          ),
          TaskSummary(
            id: 'dash-task-2',
            title: 'Follow up ABC payment',
            projectName: 'Chennai Villa',
            assignedEmployee: 'Divya',
            priority: 'High',
            status: 'Pending',
            dueLabel: 'Today',
          ),
          TaskSummary(
            id: 'dash-task-3',
            title: 'Approve OMR foundation variation',
            projectName: 'OMR Commercial',
            assignedEmployee: 'Raj',
            priority: 'Critical',
            status: 'Overdue',
            dueLabel: 'Yesterday',
          ),
          TaskSummary(
            id: 'dash-task-4',
            title: 'Vendor payment — Sri Materials',
            projectName: 'Coimbatore Interior',
            assignedEmployee: 'Procurement',
            priority: 'Medium',
            status: 'Pending',
            dueLabel: 'Tomorrow',
          ),
        ],
      ),
      meetings: MeetingOverview(
        today: 5,
        upcoming: 3,
        items: [
          MeetingSummary(
            id: 'dash-mtg-1',
            title: 'Chennai Project Review',
            timeLabel: '10:00 AM',
            participants: ['MD', 'Raj', 'Suresh'],
            location: 'War room',
          ),
          MeetingSummary(
            id: 'dash-mtg-2',
            title: 'Sales Review',
            timeLabel: '12:00 PM',
            participants: ['MD', 'Sales Head'],
            location: 'MD cabin',
          ),
          MeetingSummary(
            id: 'dash-mtg-3',
            title: 'Finance Review',
            timeLabel: '3:00 PM',
            participants: ['MD', 'CFO', 'Treasury'],
            location: 'Conference line',
          ),
        ],
      ),
      sales: DashboardSalesSummary(
        pipelineValue: 84000000,
        newLeads: 6,
        qualifiedLeads: 4,
        converted: 2,
      ),
      collections: DashboardCollectionSummary(
        pending: 4200000,
        overdue: 1500000,
        expectedThisWeek: 3500000,
      ),
      finance: DashboardFinanceSummary(
        weeklyRequirement: 5000000,
        availableBalance: 11000000,
        plannedPayments: 3200000,
      ),
      projects: ProjectOverview(
        active: 5,
        completed: 2,
        atRisk: 1,
        items: [
          DashboardProjectSummary(
            id: 'prj-1',
            name: 'Chennai Villa',
            progress: 0.68,
            risk: 'Medium',
          ),
          DashboardProjectSummary(
            id: 'prj-2',
            name: 'Coimbatore Interior',
            progress: 0.75,
            risk: 'Low',
          ),
          DashboardProjectSummary(
            id: 'prj-3',
            name: 'OMR Commercial',
            progress: 0.35,
            risk: 'High',
          ),
        ],
      ),
      criticalActions: [
        CriticalAction(
          id: 'ca-1',
          title: 'ABC Builders payment overdue',
          priority: CriticalPriority.critical,
          subtitle: '₹15 L collection overdue on Chennai Villa milestone',
        ),
        CriticalAction(
          id: 'ca-2',
          title: 'OMR project is at risk',
          priority: CriticalPriority.high,
          subtitle: 'Foundation variation pending MD approval',
        ),
        CriticalAction(
          id: 'ca-3',
          title: 'Chennai material approval pending',
          priority: CriticalPriority.high,
          subtitle: 'Site work waiting on material clearance',
        ),
        CriticalAction(
          id: 'ca-4',
          title: 'Vendor payment due tomorrow',
          priority: CriticalPriority.medium,
          subtitle: 'Sri Materials — Coimbatore Interior',
        ),
        CriticalAction(
          id: 'ca-5',
          title: 'Customer follow-up pending',
          priority: CriticalPriority.medium,
          subtitle: 'Kumar Residence proposal negotiation',
        ),
      ],
    );
  }
}
