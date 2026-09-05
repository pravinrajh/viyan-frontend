class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  final String name;
  final String email;
  final String phone;
  final String password;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'password': password,
  };
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.status,
    this.isActive,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? status;
  final bool? isActive;
  final String? lastLoginAt;
  final String? createdAt;
  final String? updatedAt;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      phone: json['phone'] as String?,
      status: json['status'] as String?,
      isActive: json['isActive'] as bool?,
      lastLoginAt: json['lastLoginAt'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    if (phone != null) 'phone': phone,
    if (status != null) 'status': status,
    if (isActive != null) 'isActive': isActive,
    if (lastLoginAt != null) 'lastLoginAt': lastLoginAt,
    if (createdAt != null) 'createdAt': createdAt,
    if (updatedAt != null) 'updatedAt': updatedAt,
  };
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AuthUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    if (userJson is! Map) {
      throw const FormatException('Authentication response was incomplete.');
    }
    final accessToken = json['accessToken'] as String? ?? '';
    final refreshToken = json['refreshToken'] as String? ?? '';
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw const FormatException('Authentication response was incomplete.');
    }
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: AuthUser.fromJson(Map<String, dynamic>.from(userJson)),
    );
  }
}

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  const AuthState({required this.status, this.session, this.message});

  const AuthState.initial() : this(status: AuthStatus.initial);

  const AuthState.loading({AuthSession? session})
    : this(status: AuthStatus.loading, session: session);

  const AuthState.authenticated(AuthSession session)
    : this(status: AuthStatus.authenticated, session: session);

  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  const AuthState.error(String message, {AuthSession? session})
    : this(status: AuthStatus.error, session: session, message: message);

  final AuthStatus status;
  final AuthSession? session;
  final String? message;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && session != null;

  bool get isBusy => status == AuthStatus.loading;
}
