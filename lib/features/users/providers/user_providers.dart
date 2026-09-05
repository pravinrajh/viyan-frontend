import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/app_user.dart';
import '../repositories/api_user_repository.dart';
import '../repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return ApiUserRepository(ref.watch(apiClientProvider));
});

final userSearchProvider = NotifierProvider<UserSearchNotifier, String>(
  UserSearchNotifier.new,
);

class UserSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

final usersProvider = AsyncNotifierProvider<UsersNotifier, List<AppUser>>(
  UsersNotifier.new,
);

class UsersNotifier extends AsyncNotifier<List<AppUser>> {
  @override
  Future<List<AppUser>> build() async {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) return const [];
    final search = ref.watch(userSearchProvider);
    return ref.read(userRepositoryProvider).fetchUsers(search: search);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final search = ref.read(userSearchProvider);
      return ref.read(userRepositoryProvider).fetchUsers(search: search);
    });
  }

  Future<AppUser> createUser(CreateUserInput input) async {
    final created = await ref.read(userRepositoryProvider).createUser(input);
    await refresh();
    return created;
  }

  Future<void> setStatus(String id, String status) async {
    await ref.read(userRepositoryProvider).updateStatus(id, status);
    await refresh();
  }

  Future<void> deactivate(String id) async {
    await ref.read(userRepositoryProvider).deactivate(id);
    await refresh();
  }
}
