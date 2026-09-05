
enum ReminderStatus {
  scheduled,
  processing,
  triggered,
  completed,
  cancelled,
  failed,
}

extension ReminderStatusX on ReminderStatus {
  String get label => switch (this) {
    ReminderStatus.scheduled => 'Scheduled',
    ReminderStatus.processing => 'Processing',
    ReminderStatus.triggered => 'Triggered',
    ReminderStatus.completed => 'Completed',
    ReminderStatus.cancelled => 'Cancelled',
    ReminderStatus.failed => 'Failed',
  };

  static ReminderStatus fromApi(String value) {
    return switch (value.toUpperCase()) {
      'PROCESSING' => ReminderStatus.processing,
      'TRIGGERED' => ReminderStatus.triggered,
      'COMPLETED' => ReminderStatus.completed,
      'CANCELLED' || 'CANCELED' => ReminderStatus.cancelled,
      'FAILED' => ReminderStatus.failed,
      _ => ReminderStatus.scheduled,
    };
  }
}

enum ReminderPriority { low, normal, high, urgent }

extension ReminderPriorityX on ReminderPriority {
  String get label => switch (this) {
    ReminderPriority.low => 'Low',
    ReminderPriority.normal => 'Normal',
    ReminderPriority.high => 'High',
    ReminderPriority.urgent => 'Urgent',
  };

  String get apiValue => name.toUpperCase();

  static ReminderPriority fromApi(String value) {
    return switch (value.toUpperCase()) {
      'LOW' => ReminderPriority.low,
      'HIGH' => ReminderPriority.high,
      'URGENT' => ReminderPriority.urgent,
      _ => ReminderPriority.normal,
    };
  }
}

class Reminder {
  const Reminder({
    required this.id,
    required this.reminderId,
    required this.title,
    required this.scheduledAt,
    required this.status,
    this.description = '',
    this.reminderType = '',
    this.sourceType = '',
    this.sourceId,
    this.timezone = 'Asia/Kolkata',
    this.priority = ReminderPriority.normal,
    this.actionUrl = '',
    this.nextRunAt,
    this.completedAt,
  });

  final String id;
  final String reminderId;
  final String title;
  final String description;
  final String reminderType;
  final String sourceType;
  final String? sourceId;
  final DateTime scheduledAt;
  final String timezone;
  final ReminderPriority priority;
  final ReminderStatus status;
  final String actionUrl;
  final DateTime? nextRunAt;
  final DateTime? completedAt;

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: _s(json['id'], json['_id']),
      reminderId: _s(json['reminderId']),
      title: _s(json['title']),
      description: _s(json['description']),
      reminderType: _s(json['reminderType']),
      sourceType: _s(json['sourceType']),
      sourceId: _sOrNull(json['sourceId']),
      scheduledAt: _date(json['scheduledAt']) ?? DateTime.now(),
      timezone: _s(json['timezone'], 'Asia/Kolkata'),
      priority: ReminderPriorityX.fromApi(_s(json['priority'], 'NORMAL')),
      status: ReminderStatusX.fromApi(_s(json['status'])),
      actionUrl: _s(json['actionUrl']),
      nextRunAt: _date(json['nextRunAt']),
      completedAt: _date(json['completedAt']),
    );
  }
}

class CreateReminderInput {
  const CreateReminderInput({
    required this.title,
    required this.scheduledAt,
    this.description = '',
    this.reminderType,
    this.sourceType,
    this.sourceId,
    this.timezone,
    this.priority,
    this.actionUrl,
  });

  final String title;
  final String description;
  final String? reminderType;
  final String? sourceType;
  final String? sourceId;
  final DateTime scheduledAt;
  final String? timezone;
  final ReminderPriority? priority;
  final String? actionUrl;
}

class UpdateReminderInput {
  const UpdateReminderInput({
    this.title,
    this.description,
    this.scheduledAt,
    this.timezone,
    this.priority,
    this.actionUrl,
  });

  final String? title;
  final String? description;
  final DateTime? scheduledAt;
  final String? timezone;
  final ReminderPriority? priority;
  final String? actionUrl;
}

String _s(Object? v, [Object? f]) {
  if (v is String && v.isNotEmpty) return v;
  if (f is String && f.isNotEmpty) return f;
  return '';
}

String? _sOrNull(Object? v) {
  final t = _s(v);
  return t.isEmpty ? null : t;
}

DateTime? _date(Object? v) {
  if (v is DateTime) return v;
  if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
  return null;
}
