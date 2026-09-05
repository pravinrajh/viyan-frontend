/// Compact task row for the executive dashboard (not the full Task module).
class TaskSummary {
  const TaskSummary({
    required this.id,
    required this.title,
    required this.projectName,
    required this.assignedEmployee,
    required this.priority,
    required this.status,
    required this.dueLabel,
  });

  final String id;
  final String title;
  final String projectName;
  final String assignedEmployee;
  final String priority;
  final String status;
  final String dueLabel;

  factory TaskSummary.fromJson(Map<String, dynamic> json) {
    return TaskSummary(
      id: json['id'] as String? ?? json['taskId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      assignedEmployee:
          json['assignedEmployee'] as String? ?? json['owner'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Medium',
      status: json['status'] as String? ?? 'Pending',
      dueLabel: json['dueLabel'] as String? ?? json['dueDate'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'projectName': projectName,
    'assignedEmployee': assignedEmployee,
    'priority': priority,
    'status': status,
    'dueLabel': dueLabel,
  };
}

class TaskOverview {
  const TaskOverview({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.overdue,
    this.items = const [],
  });

  final int total;
  final int pending;
  final int inProgress;
  final int completed;
  final int overdue;
  final List<TaskSummary> items;

  factory TaskOverview.fromJson(Map<String, dynamic> json) {
    return TaskOverview(
      total: json['total'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      inProgress: json['inProgress'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      overdue: json['overdue'] as int? ?? 0,
      items: ((json['items'] as List<dynamic>?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(TaskSummary.fromJson)
          .toList(),
    );
  }
}
