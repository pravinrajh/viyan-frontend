
enum LandParcelStatus {
  available,
  negotiation,
  legalVerification,
  acquired,
  dropped,
}

extension LandParcelStatusX on LandParcelStatus {
  String get label => switch (this) {
    LandParcelStatus.available => 'Available',
    LandParcelStatus.negotiation => 'Negotiation',
    LandParcelStatus.legalVerification => 'Legal verification',
    LandParcelStatus.acquired => 'Acquired',
    LandParcelStatus.dropped => 'Dropped',
  };

  String get apiValue => switch (this) {
    LandParcelStatus.available => 'AVAILABLE',
    LandParcelStatus.negotiation => 'NEGOTIATION',
    LandParcelStatus.legalVerification => 'LEGAL_VERIFICATION',
    LandParcelStatus.acquired => 'ACQUIRED',
    LandParcelStatus.dropped => 'DROPPED',
  };

  static LandParcelStatus fromApi(String value) {
    return switch (value.toUpperCase().replaceAll('-', '_')) {
      'NEGOTIATION' => LandParcelStatus.negotiation,
      'LEGAL_VERIFICATION' || 'LEGALVERIFICATION' =>
        LandParcelStatus.legalVerification,
      'ACQUIRED' => LandParcelStatus.acquired,
      'DROPPED' => LandParcelStatus.dropped,
      _ => LandParcelStatus.available,
    };
  }
}

class LandParcel {
  const LandParcel({
    required this.id,
    required this.parcelId,
    required this.name,
    required this.status,
    this.location = '',
    this.areaNote = '',
    this.ownerName = '',
    this.askingPrice,
    this.projectId,
    this.notes = '',
  });

  final String id;
  final String parcelId;
  final String name;
  final String location;
  final String areaNote;
  final String ownerName;
  final int? askingPrice;
  final LandParcelStatus status;
  final String? projectId;
  final String notes;

  factory LandParcel.fromJson(Map<String, dynamic> json) {
    return LandParcel(
      id: _s(json['id'], json['_id']),
      parcelId: _s(json['parcelId']),
      name: _s(json['name']),
      location: _s(json['location']),
      areaNote: _s(json['areaNote']),
      ownerName: _s(json['ownerName']),
      askingPrice: _intOrNull(json['askingPrice']),
      status: LandParcelStatusX.fromApi(_s(json['status'])),
      projectId: _sOrNull(json['projectId']),
      notes: _s(json['notes']),
    );
  }
}

class CreateLandParcelInput {
  const CreateLandParcelInput({
    required this.name,
    this.location = '',
    this.areaNote = '',
    this.ownerName = '',
    this.askingPrice,
    this.status,
    this.projectId,
    this.notes = '',
  });

  final String name;
  final String location;
  final String areaNote;
  final String ownerName;
  final int? askingPrice;
  final LandParcelStatus? status;
  final String? projectId;
  final String notes;
}

class UpdateLandParcelInput {
  const UpdateLandParcelInput({
    this.name,
    this.location,
    this.areaNote,
    this.ownerName,
    this.askingPrice,
    this.status,
    this.projectId,
    this.notes,
  });

  final String? name;
  final String? location;
  final String? areaNote;
  final String? ownerName;
  final int? askingPrice;
  final LandParcelStatus? status;
  final String? projectId;
  final String? notes;
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

int? _intOrNull(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}
