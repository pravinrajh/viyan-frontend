import '../models/app_user.dart';

abstract class UserRepository {
  Future<List<AppUser>> fetchUsers({String? search, String? role});
  Future<AppUser> createUser(CreateUserInput input);
  Future<AppUser> updateUser(
    String id, {
    String? name,
    String? phone,
    String? role,
    String? status,
    bool? isActive,
  });
  Future<AppUser> updateStatus(String id, String status);
  Future<void> deactivate(String id);
}
