import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/app_user.dart';
import 'user_repository.dart';

class ApiUserRepository implements UserRepository {
  ApiUserRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<AppUser>> fetchUsers({String? search, String? role}) async {
    final users = <AppUser>[];
    var page = 1;
    var totalPages = 1;
    while (page <= totalPages && page <= 20) {
      final query = <String, dynamic>{'page': '$page', 'limit': '100'};
      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }
      if (role != null && role.isNotEmpty) query['role'] = role;
      final response = await _client.get<dynamic>(
        ApiEndpoints.users,
        queryParameters: query,
      );
      final items = ApiEnvelope.dataList(response.data);
      for (final item in items) {
        try {
          users.add(AppUser.fromJson(item));
        } catch (_) {}
      }
      final meta = ApiEnvelope.meta(response.data);
      final reported = meta?['totalPages'];
      totalPages = reported is num && reported > 0 ? reported.toInt() : 1;
      if (items.isEmpty) break;
      page += 1;
    }
    return users;
  }

  @override
  Future<AppUser> createUser(CreateUserInput input) async {
    final response = await _client.post<dynamic>(
      ApiEndpoints.users,
      data: {
        'name': input.name.trim(),
        'email': input.email.trim(),
        'password': input.password,
        'role': input.role,
        if (input.phone.trim().isNotEmpty) 'phone': input.phone.trim(),
      },
    );
    return AppUser.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<AppUser> updateUser(
    String id, {
    String? name,
    String? phone,
    String? role,
    String? status,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name.trim();
    if (phone != null) body['phone'] = phone.trim();
    if (role != null) body['role'] = role;
    if (status != null) body['status'] = status;
    if (isActive != null) body['isActive'] = isActive;
    final response = await _client.patch<dynamic>(
      ApiEndpoints.user(id),
      data: body,
    );
    return AppUser.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<AppUser> updateStatus(String id, String status) async {
    final response = await _client.patch<dynamic>(
      ApiEndpoints.userStatus(id),
      data: {'status': status},
    );
    return AppUser.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<void> deactivate(String id) async {
    await _client.delete<dynamic>(ApiEndpoints.user(id));
  }
}
