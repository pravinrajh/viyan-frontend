enum TaskStatus { pending, inProgress, completed, cancelled, overdue }

enum TaskPriority { low, medium, high, critical }

extension TaskStatusX on TaskStatus {
  String get label => switch (this) {
    TaskStatus.pending => 'Pending',
    TaskStatus.inProgress => 'In progress',
    TaskStatus.completed => 'Completed',
    TaskStatus.cancelled => 'Cancelled',
    TaskStatus.overdue => 'Overdue',
  };

  /// MD_EAO_BACKEND task status enum. Overdue is a filter, not a stored status.
  String get apiValue => switch (this) {
    TaskStatus.pending => 'PENDING',
    TaskStatus.inProgress => 'IN_PROGRESS',
    TaskStatus.completed => 'COMPLETED',
    TaskStatus.cancelled => 'CANCELLED',
    TaskStatus.overdue => 'PENDING',
  };

  static const writable = <TaskStatus>[
    TaskStatus.pending,
    TaskStatus.inProgress,
    TaskStatus.completed,
    TaskStatus.cancelled,
  ];

  static TaskStatus fromApi(String value) {
    return switch (value.toUpperCase().replaceAll('-', '_')) {
      'PENDING' => TaskStatus.pending,
      'IN_PROGRESS' || 'INPROGRESS' => TaskStatus.inProgress,
      'COMPLETED' => TaskStatus.completed,
      'CANCELLED' || 'CANCELED' || 'BLOCKED' => TaskStatus.cancelled,
      'OVERDUE' => TaskStatus.overdue,
      _ => TaskStatus.pending,
    };
  }
}

extension TaskPriorityX on TaskPriority {
  String get label => switch (this) {
    TaskPriority.low => 'Low',
    TaskPriority.medium => 'Medium',
    TaskPriority.high => 'High',
    TaskPriority.critical => 'Critical',
  };

  String get apiValue => name.toUpperCase();

  static TaskPriority fromApi(String value) {
    return switch (value.toUpperCase()) {
      'LOW' => TaskPriority.low,
      'HIGH' => TaskPriority.high,
      'CRITICAL' => TaskPriority.critical,
      _ => TaskPriority.medium,
    };
  }
}

class TaskAssignee {
  const TaskAssignee({
    required this.id,
    required this.name,
    this.employeeCode = '',
  });

  final String id;
  final String name;
  final String employeeCode;

  factory TaskAssignee.fromJson(Map<String, dynamic> json) {
    final first = _string(json['firstName']);
    final last = _string(json['lastName']);
    final combined = '$first $last'.trim();
    return TaskAssignee(
      id: _string(json['id'], json['_id']),
      name: _string(json['name'], json['displayName']).isNotEmpty
          ? _string(json['name'], json['displayName'])
          : combined,
      employeeCode: _string(json['employeeCode']),
    );
  }
}

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.owner,
    required this.dueDate,
    required this.createdAt,
    this.taskId = '',
    this.createdBy = 'MD',
    this.assignedToId,
    this.projectId,
    this.projectName,
    this.customerName,
    this.vendorName,
    this.reminderAt,
    this.markedOverdue = false,
  });

  final String id;
  final String taskId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String owner;
  final DateTime dueDate;
  final DateTime createdAt;
  final String createdBy;
  final String? assignedToId;
  final String? projectId;
  final String? projectName;
  final String? customerName;
  final String? vendorName;
  final DateTime? reminderAt;
  final bool markedOverdue;

  bool get isOverdue =>
      status != TaskStatus.completed &&
      status != TaskStatus.cancelled &&
      (status == TaskStatus.overdue ||
          markedOverdue ||
          dueDate.isBefore(DateTime.now()));

  Task copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? owner,
    DateTime? dueDate,
    String? createdBy,
    String? assignedToId,
    String? projectId,
    String? projectName,
    String? customerName,
    String? vendorName,
    DateTime? reminderAt,
    bool? markedOverdue,
  }) {
    return Task(
      id: id,
      taskId: taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      owner: owner ?? this.owner,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      createdBy: createdBy ?? this.createdBy,
      assignedToId: assignedToId ?? this.assignedToId,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      customerName: customerName ?? this.customerName,
      vendorName: vendorName ?? this.vendorName,
      reminderAt: reminderAt ?? this.reminderAt,
      markedOverdue: markedOverdue ?? this.markedOverdue,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final assigned = json['assignedTo'];
    var owner = _string(json['owner'], json['assignedEmployee']);
    String? assignedToId = _stringOrNull(json['assignedToId']);
    if (assigned is Map) {
      final map = Map<String, dynamic>.from(assigned);
      if (owner.isEmpty) owner = _string(map['name'], map['displayName']);
      assignedToId ??= _stringOrNull(map['id'], map['_id']);
    } else if (assigned is String && assigned.isNotEmpty) {
      assignedToId ??= assigned;
    }

    final created = json['createdBy'];
    var createdBy = _string(json['createdByName']);
    if (created is Map) {
      createdBy = _string(created['name'], created['email']);
    } else if (createdBy.isEmpty && created is String) {
      createdBy = created;
    }
    if (createdBy.isEmpty) createdBy = 'MD';

    final project = json['project'];
    var projectId = _stringOrNull(json['projectId']);
    var projectName = _stringOrNull(json['projectName']);
    if (project is Map) {
      projectId ??= _stringOrNull(project['id'], project['_id']);
      projectName ??= _stringOrNull(project['name']);
    } else if (project is String && project.isNotEmpty) {
      projectId ??= project;
    }

    final customer = json['customer'];
    var customerName = _stringOrNull(json['customerName']);
    if (customerName == null && customer is Map) {
      customerName = _stringOrNull(customer['name'], customer['companyName']);
    }

    return Task(
      id: _string(json['id'], json['_id']),
      taskId: _string(json['taskId']),
      title: _string(json['title']),
      description: _string(json['description']),
      status: TaskStatusX.fromApi(_string(json['status'])),
      priority: TaskPriorityX.fromApi(_string(json['priority'], 'MEDIUM')),
      owner: owner,
      dueDate: _date(json['dueDate']) ?? DateTime.now(),
      createdAt: _date(json['createdAt']) ?? DateTime.now(),
      createdBy: createdBy,
      assignedToId: assignedToId,
      projectId: projectId,
      projectName: projectName,
      customerName: customerName,
      vendorName: _stringOrNull(json['vendorName']),
      reminderAt: _date(json['reminderAt']),
      markedOverdue: json['isOverdue'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'taskId': taskId,
    'title': title,
    'description': description,
    'status': status.apiValue,
    'priority': priority.apiValue,
    'owner': owner,
    'dueDate': dueDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'createdBy': createdBy,
    'assignedToId': assignedToId,
    'projectId': projectId,
    'projectName': projectName,
    'customerName': customerName,
    'vendorName': vendorName,
    'reminderAt': reminderAt?.toIso8601String(),
    'isOverdue': markedOverdue,
  };
}

class CreateTaskInput {
  const CreateTaskInput({
    required this.title,
    required this.description,
    required this.owner,
    required this.dueDate,
    required this.priority,
    this.assignedToId,
    this.projectId,
    this.projectName,
    this.customerName,
    this.vendorName,
    this.reminderAt,
  });

  final String title;
  final String description;
  final String owner;
  final DateTime dueDate;
  final TaskPriority priority;
  final String? assignedToId;
  final String? projectId;
  final String? projectName;
  final String? customerName;
  final String? vendorName;
  final DateTime? reminderAt;
}

String _string(Object? value, [Object? fallback]) {
  if (value is String && value.isNotEmpty) return value;
  if (fallback is String && fallback.isNotEmpty) return fallback;
  return '';
}

String? _stringOrNull(Object? value, [Object? fallback]) {
  final text = _string(value, fallback);
  return text.isEmpty ? null : text;
}

DateTime? _date(Object? value) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
