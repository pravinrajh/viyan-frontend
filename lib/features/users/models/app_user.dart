class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
    this.status = 'ACTIVE',
    this.isActive = true,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String status;
  final bool isActive;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'EMPLOYEE',
      phone: json['phone'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class CreateUserInput {
  const CreateUserInput({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.phone = '',
  });

  final String name;
  final String email;
  final String password;
  final String role;
  final String phone;
}
