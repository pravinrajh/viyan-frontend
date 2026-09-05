
enum SalesActivityType {
  call,
  email,
  meeting,
  followUp,
  siteVisit,
  note,
  other,
}

extension SalesActivityTypeX on SalesActivityType {
  String get label => switch (this) {
    SalesActivityType.call => 'Call',
    SalesActivityType.email => 'Email',
    SalesActivityType.meeting => 'Meeting',
    SalesActivityType.followUp => 'Follow-up',
    SalesActivityType.siteVisit => 'Site visit',
    SalesActivityType.note => 'Note',
    SalesActivityType.other => 'Other',
  };

  String get apiValue => switch (this) {
    SalesActivityType.call => 'CALL',
    SalesActivityType.email => 'EMAIL',
    SalesActivityType.meeting => 'MEETING',
    SalesActivityType.followUp => 'FOLLOW_UP',
    SalesActivityType.siteVisit => 'SITE_VISIT',
    SalesActivityType.note => 'NOTE',
    SalesActivityType.other => 'OTHER',
  };

  static SalesActivityType fromApi(String value) {
    return switch (value.toUpperCase().replaceAll('-', '_')) {
      'EMAIL' => SalesActivityType.email,
      'MEETING' => SalesActivityType.meeting,
      'FOLLOW_UP' || 'FOLLOWUP' => SalesActivityType.followUp,
      'SITE_VISIT' || 'SITEVISIT' => SalesActivityType.siteVisit,
      'NOTE' => SalesActivityType.note,
      'OTHER' => SalesActivityType.other,
      _ => SalesActivityType.call,
    };
  }
}

enum SalesActivityStatus { pending, completed, cancelled }

extension SalesActivityStatusX on SalesActivityStatus {
  String get label => switch (this) {
    SalesActivityStatus.pending => 'Pending',
    SalesActivityStatus.completed => 'Completed',
    SalesActivityStatus.cancelled => 'Cancelled',
  };

  String get apiValue => switch (this) {
    SalesActivityStatus.pending => 'PENDING',
    SalesActivityStatus.completed => 'COMPLETED',
    SalesActivityStatus.cancelled => 'CANCELLED',
  };

  static SalesActivityStatus fromApi(String value) {
    return switch (value.toUpperCase()) {
      'COMPLETED' => SalesActivityStatus.completed,
      'CANCELLED' || 'CANCELED' => SalesActivityStatus.cancelled,
      _ => SalesActivityStatus.pending,
    };
  }
}

class SalesActivity {
  const SalesActivity({
    required this.id,
    required this.activityId,
    required this.type,
    required this.title,
    required this.status,
    this.description = '',
    this.leadId,
    this.customerId,
    this.opportunityId,
    this.employeeId,
    this.scheduledAt,
    this.completedAt,
  });

  final String id;
  final String activityId;
  final SalesActivityType type;
  final String title;
  final String description;
  final String? leadId;
  final String? customerId;
  final String? opportunityId;
  final String? employeeId;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final SalesActivityStatus status;

  factory SalesActivity.fromJson(Map<String, dynamic> json) {
    return SalesActivity(
      id: _s(json['id'], json['_id']),
      activityId: _s(json['activityId']),
      type: SalesActivityTypeX.fromApi(_s(json['type'])),
      title: _s(json['title']),
      description: _s(json['description']),
      leadId: _sOrNull(json['leadId']),
      customerId: _sOrNull(json['customerId']),
      opportunityId: _sOrNull(json['opportunityId']),
      employeeId: _sOrNull(json['employeeId']),
      scheduledAt: _date(json['scheduledAt']),
      completedAt: _date(json['completedAt']),
      status: SalesActivityStatusX.fromApi(_s(json['status'])),
    );
  }
}

class CreateSalesActivityInput {
  const CreateSalesActivityInput({
    required this.type,
    required this.title,
    this.description = '',
    this.leadId,
    this.customerId,
    this.opportunityId,
    this.employeeId,
    this.scheduledAt,
    this.status,
  });

  final SalesActivityType type;
  final String title;
  final String description;
  final String? leadId;
  final String? customerId;
  final String? opportunityId;
  final String? employeeId;
  final DateTime? scheduledAt;
  final SalesActivityStatus? status;
}

class UpdateSalesActivityInput {
  const UpdateSalesActivityInput({
    this.type,
    this.title,
    this.description,
    this.leadId,
    this.customerId,
    this.opportunityId,
    this.employeeId,
    this.scheduledAt,
  });

  final SalesActivityType? type;
  final String? title;
  final String? description;
  final String? leadId;
  final String? customerId;
  final String? opportunityId;
  final String? employeeId;
  final DateTime? scheduledAt;
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
