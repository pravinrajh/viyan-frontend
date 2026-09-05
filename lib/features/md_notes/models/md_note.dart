
enum MdNoteRelatedType {
  project,
  customer,
  employee,
  task,
  meeting,
  none,
}

extension MdNoteRelatedTypeX on MdNoteRelatedType {
  String get label => switch (this) {
    MdNoteRelatedType.project => 'Project',
    MdNoteRelatedType.customer => 'Customer',
    MdNoteRelatedType.employee => 'Employee',
    MdNoteRelatedType.task => 'Task',
    MdNoteRelatedType.meeting => 'Meeting',
    MdNoteRelatedType.none => 'None',
  };

  String get apiValue => switch (this) {
    MdNoteRelatedType.project => 'PROJECT',
    MdNoteRelatedType.customer => 'CUSTOMER',
    MdNoteRelatedType.employee => 'EMPLOYEE',
    MdNoteRelatedType.task => 'TASK',
    MdNoteRelatedType.meeting => 'MEETING',
    MdNoteRelatedType.none => 'NONE',
  };

  static MdNoteRelatedType fromApi(String value) {
    return switch (value.toUpperCase()) {
      'PROJECT' => MdNoteRelatedType.project,
      'CUSTOMER' => MdNoteRelatedType.customer,
      'EMPLOYEE' => MdNoteRelatedType.employee,
      'TASK' => MdNoteRelatedType.task,
      'MEETING' => MdNoteRelatedType.meeting,
      _ => MdNoteRelatedType.none,
    };
  }
}

class MdNote {
  const MdNote({
    required this.id,
    required this.noteId,
    required this.body,
    required this.relatedType,
    this.relatedId,
    this.createdAt,
  });

  final String id;
  final String noteId;
  final String body;
  final MdNoteRelatedType relatedType;
  final String? relatedId;
  final DateTime? createdAt;

  factory MdNote.fromJson(Map<String, dynamic> json) {
    return MdNote(
      id: _s(json['id'], json['_id']),
      noteId: _s(json['noteId']),
      body: _s(json['body']),
      relatedType: MdNoteRelatedTypeX.fromApi(_s(json['relatedType'])),
      relatedId: _sOrNull(json['relatedId']),
      createdAt: _date(json['createdAt']),
    );
  }
}

class CreateMdNoteInput {
  const CreateMdNoteInput({
    required this.body,
    this.relatedType = MdNoteRelatedType.none,
    this.relatedId,
  });

  final String body;
  final MdNoteRelatedType relatedType;
  final String? relatedId;
}

class UpdateMdNoteInput {
  const UpdateMdNoteInput({
    this.body,
    this.relatedType,
    this.relatedId,
  });

  final String? body;
  final MdNoteRelatedType? relatedType;
  final String? relatedId;
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
