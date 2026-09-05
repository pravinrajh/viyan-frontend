import '../../../core/utils/currency_formatters.dart';
import '../../../core/utils/date_formatters.dart';
import 'critical_action.dart';
import 'meeting_summary.dart';
import 'section_summaries.dart';
import 'task_summary.dart';

/// Executive dashboard aggregate returned by GET /api/v1/dashboard.
class DashboardSummary {
  const DashboardSummary({
    required this.headline,
    required this.tasks,
    required this.meetings,
    required this.sales,
    required this.collections,
    required this.finance,
    required this.projects,
    required this.criticalActions,
  });

  final String headline;
  final TaskOverview tasks;
  final MeetingOverview meetings;
  final DashboardSalesSummary sales;
  final DashboardCollectionSummary collections;
  final DashboardFinanceSummary finance;
  final ProjectOverview projects;
  final List<CriticalAction> criticalActions;

  static const empty = DashboardSummary(
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

  bool get isEmpty =>
      tasks.total == 0 &&
      meetings.today == 0 &&
      projects.active == 0 &&
      projects.items.isEmpty &&
      criticalActions.isEmpty;

  /// Overview cards for the business summary strip.
  List<OverviewCardData> get overviewCards => [
    OverviewCardData(
      label: 'Tasks',
      primary: '${tasks.total} Total',
      secondary: '${tasks.overdue} Overdue',
      tone: tasks.overdue > 0 ? 'danger' : 'neutral',
    ),
    OverviewCardData(
      label: 'Meetings',
      primary: '${meetings.today} Today',
      secondary: '${meetings.upcoming} Upcoming',
    ),
    OverviewCardData(
      label: 'Sales Pipeline',
      primary: CurrencyFormatters.inr(sales.pipelineValue),
      secondary: '${sales.newLeads} New · ${sales.converted} Converted',
    ),
    OverviewCardData(
      label: 'Collections',
      primary: CurrencyFormatters.inr(collections.pending),
      secondary: '${CurrencyFormatters.inr(collections.overdue)} Overdue',
      tone: 'warning',
    ),
    OverviewCardData(
      label: 'Weekly Requirement',
      primary: CurrencyFormatters.inr(finance.weeklyRequirement),
      secondary: 'Planned ${CurrencyFormatters.inr(finance.plannedPayments)}',
      tone: 'warning',
    ),
    OverviewCardData(
      label: 'Available Balance',
      primary: CurrencyFormatters.inr(finance.availableBalance),
      secondary: 'Cash on hand',
      tone: 'success',
    ),
  ];

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final root = _unwrap(json);
    final tasks = root['tasks'];
    if (tasks is Map && tasks['today'] is Map) {
      return DashboardSummary._fromLiveApi(root);
    }
    if (tasks is Map) {
      final taskMap = Map<String, dynamic>.from(tasks);
      return DashboardSummary(
        headline: _asString(root['headline']),
        tasks: TaskOverview.fromJson(taskMap),
        meetings: MeetingOverview.fromJson(_asMap(root['meetings'])),
        sales: DashboardSalesSummary.fromJson(_asMap(root['sales'])),
        collections: DashboardCollectionSummary.fromJson(
          _asMap(root['collections']),
        ),
        finance: DashboardFinanceSummary.fromJson(_asMap(root['finance'])),
        projects: ProjectOverview.fromJson(_asMap(root['projects'])),
        criticalActions: _parseCriticalActions(root['criticalActions']),
      );
    }

    // Legacy flat payload compatibility (Day 1 mock / older API).
    return DashboardSummary(
      headline: json['headline'] as String? ?? '',
      tasks: TaskOverview(
        total: json['taskTotal'] as int? ?? json['openTasks'] as int? ?? 0,
        pending: json['taskPending'] as int? ?? 0,
        inProgress: json['taskInProgress'] as int? ?? 0,
        completed: json['taskCompleted'] as int? ?? 0,
        overdue:
            json['taskOverdue'] as int? ?? json['overdueTasks'] as int? ?? 0,
        items: ((json['priorityTasks'] as List<dynamic>?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map(TaskSummary.fromJson)
            .toList(),
      ),
      meetings: MeetingOverview(
        today: json['meetingsToday'] as int? ?? 0,
        upcoming: json['meetingsUpcoming'] as int? ?? 0,
        items: ((json['upcomingMeetings'] as List<dynamic>?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map(MeetingSummary.fromJson)
            .toList(),
      ),
      sales: DashboardSalesSummary(
        pipelineValue: (json['salesPipelineValue'] as num?)?.toDouble() ?? 0,
        newLeads: json['salesNewLeads'] as int? ?? 0,
        qualifiedLeads: json['salesQualifiedLeads'] as int? ?? 0,
        converted: json['salesConversions'] as int? ?? 0,
      ),
      collections: DashboardCollectionSummary(
        pending: (json['collectionsPending'] as num?)?.toDouble() ?? 0,
        overdue: (json['collectionsOverdue'] as num?)?.toDouble() ?? 0,
        expectedThisWeek:
            (json['expectedCollections'] as num?)?.toDouble() ?? 0,
      ),
      finance: DashboardFinanceSummary(
        weeklyRequirement:
            (json['weeklyCashRequirement'] as num?)?.toDouble() ?? 0,
        availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0,
        plannedPayments: (json['plannedPayments'] as num?)?.toDouble() ?? 0,
      ),
      projects: ProjectOverview(
        active: json['activeProjects'] as int? ?? 0,
        completed: json['completedProjects'] as int? ?? 0,
        atRisk: json['atRiskProjects'] as int? ?? 0,
      ),
      criticalActions: _parseCriticalActions(
        json['criticalActions'] ?? json['alerts'],
      ),
    );
  }

  factory DashboardSummary._fromLiveApi(Map<String, dynamic> json) {
    final overview = _asMap(json['overview']);
    final tasks = _asMap(json['tasks']);
    final today = _asMap(tasks['today']);
    final overdueTasks = _asList(tasks['overdue']);
    final meetings = _asMap(json['meetings']);
    final meetingItems = meetings['today'] is List
        ? _asList(meetings['today'])
        : _asList(meetings['items']);
    final projects = _asMap(json['projects']);
    final sales = _asMap(json['sales']);
    final finance = _asMap(json['finance']);
    final attention = json['attention'] ?? json['criticalActions'];
    final actions = _parseCriticalActions(attention);
    final projectItems = _asList(projects['items'])
        .map(DashboardProjectSummary.fromJson)
        .toList();

    final taskTotal = _asInt(today['total']);
    final meetingToday = _asInt(
      meetings['todayCount'],
      fallback: meetingItems.length,
    );

    return DashboardSummary(
      headline: _asString(json['headline']).isNotEmpty
          ? _asString(json['headline'])
          : (actions.isEmpty
                ? 'No items require your attention today'
                : '${actions.length} item${actions.length == 1 ? '' : 's'} need your attention'),
      tasks: TaskOverview(
        total: taskTotal,
        pending: _asInt(today['pending']),
        inProgress: _asInt(today['inProgress']),
        completed: _asInt(today['completed']),
        overdue: _asInt(today['overdue'], fallback: overdueTasks.length),
        items: overdueTasks.map(_taskFromLive).toList(),
      ),
      meetings: MeetingOverview(
        today: meetingToday,
        upcoming: _asInt(meetings['upcoming']),
        items: meetingItems.map(_meetingFromLive).toList(),
      ),
      sales: DashboardSalesSummary(
        pipelineValue: _asDouble(sales['pipelineValue']),
        newLeads: _asInt(sales['newLeads']),
        qualifiedLeads: _asInt(sales['qualifiedLeads']),
        converted: _asInt(
          sales['converted'],
          fallback: _asInt(sales['wonOpportunities']),
        ),
      ),
      collections: DashboardCollectionSummary.fromJson(
        _asMap(json['collections']),
      ),
      finance: DashboardFinanceSummary(
        weeklyRequirement: _asDouble(finance['weeklyRequirement']),
        availableBalance: _asDouble(
          finance['availableBalance'],
          fallback: _asDouble(finance['accountBalance']),
        ),
        plannedPayments: _asDouble(finance['plannedPayments']),
      ),
      projects: ProjectOverview(
        active: _asInt(
          projects['active'],
          fallback: _asInt(
            projects['total'],
            fallback: _asInt(
              overview['activeProjects'],
              fallback: projectItems.length,
            ),
          ),
        ),
        completed: _asInt(projects['completed']),
        atRisk: _asInt(projects['atRisk']) + _asInt(projects['critical']),
        items: projectItems,
      ),
      criticalActions: actions,
    );
  }

  static TaskSummary _taskFromLive(Map<String, dynamic> json) {
    final project = json['project'];
    final assigned = json['assignedTo'];
    return TaskSummary(
      id: _asString(json['id'], fallback: _asString(json['taskId'])),
      title: _asString(json['title']),
      projectName: project is Map ? _asString(project['name']) : '',
      assignedEmployee: assigned is Map ? _asString(assigned['name']) : '',
      priority: _asString(json['priority'], fallback: 'Medium'),
      status: _asString(json['status'], fallback: 'Overdue'),
      dueLabel: _dueLabel(json['dueDate'] ?? json['dueLabel']),
    );
  }

  static MeetingSummary _meetingFromLive(Map<String, dynamic> json) {
    return MeetingSummary(
      id: _asString(json['id'], fallback: _asString(json['meetingId'])),
      title: _asString(json['title']),
      timeLabel: _timeLabel(json['startTime'] ?? json['timeLabel']),
      participants: const [],
      location: _asString(json['location']).isEmpty
          ? null
          : _asString(json['location']),
    );
  }

  static String _dueLabel(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return DateFormatters.date(parsed.toLocal());
      return raw;
    }
    return '';
  }

  static String _timeLabel(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return DateFormatters.time(parsed.toLocal());
      return raw;
    }
    return '';
  }

  static List<CriticalAction> _parseCriticalActions(Object? raw) {
    if (raw is! List) return const [];
    return raw.map((item) {
      if (item is String) {
        return CriticalAction(
          id: item,
          title: item,
          priority: CriticalPriority.high,
        );
      }
      if (item is Map) {
        return CriticalAction.fromJson(Map<String, dynamic>.from(item));
      }
      return CriticalAction(
        id: item.toString(),
        title: item.toString(),
        priority: CriticalPriority.medium,
      );
    }).toList();
  }
}

Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
  final data = json['data'];
  if (data is Map &&
      (json.containsKey('success') || json.containsKey('message'))) {
    return Map<String, dynamic>.from(data);
  }
  return json;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<Map<String, dynamic>> _asList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
}

String _asString(Object? value, {String fallback = ''}) {
  if (value is String && value.isNotEmpty) return value;
  return fallback;
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double _asDouble(Object? value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

class OverviewCardData {
  const OverviewCardData({
    required this.label,
    required this.primary,
    required this.secondary,
    this.tone = 'neutral',
  });

  final String label;
  final String primary;
  final String secondary;
  final String tone;
}
