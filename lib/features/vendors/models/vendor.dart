
enum VendorStatus { active, inactive }

extension VendorStatusX on VendorStatus {
  String get label => switch (this) {
    VendorStatus.active => 'Active',
    VendorStatus.inactive => 'Inactive',
  };

  String get apiValue => switch (this) {
    VendorStatus.active => 'ACTIVE',
    VendorStatus.inactive => 'INACTIVE',
  };

  static VendorStatus fromApi(String value) {
    return switch (value.toUpperCase()) {
      'INACTIVE' => VendorStatus.inactive,
      _ => VendorStatus.active,
    };
  }
}

class Vendor {
  const Vendor({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.status,
    this.phone = '',
    this.email = '',
    this.location = '',
    this.taxId = '',
    this.notes = '',
  });

  final String id;
  final String vendorId;
  final String name;
  final String phone;
  final String email;
  final String location;
  final String taxId;
  final VendorStatus status;
  final String notes;

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: _s(json['id'], json['_id']),
      vendorId: _s(json['vendorId']),
      name: _s(json['name']),
      phone: _s(json['phone']),
      email: _s(json['email']),
      location: _s(json['location']),
      taxId: _s(json['taxId']),
      status: VendorStatusX.fromApi(_s(json['status'])),
      notes: _s(json['notes']),
    );
  }
}

class CreateVendorInput {
  const CreateVendorInput({
    required this.name,
    this.phone = '',
    this.email = '',
    this.location = '',
    this.taxId = '',
    this.notes = '',
  });

  final String name;
  final String phone;
  final String email;
  final String location;
  final String taxId;
  final String notes;
}

class UpdateVendorInput {
  const UpdateVendorInput({
    this.name,
    this.phone,
    this.email,
    this.location,
    this.taxId,
    this.status,
    this.notes,
  });

  final String? name;
  final String? phone;
  final String? email;
  final String? location;
  final String? taxId;
  final VendorStatus? status;
  final String? notes;
}

String _s(Object? v, [Object? f]) {
  if (v is String && v.isNotEmpty) return v;
  if (f is String && f.isNotEmpty) return f;
  return '';
}
