import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/project_summary.dart';
import '../repositories/api_project_repository.dart';
import '../repositories/project_repository.dart';

/// Projects always use the live Node.js API (Bearer token from auth).
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ApiProjectRepository(ref.watch(apiClientProvider));
});

final projectsProvider =
    AsyncNotifierProvider<ProjectsNotifier, List<ProjectSummary>>(
      ProjectsNotifier.new,
    );

class ProjectsNotifier extends AsyncNotifier<List<ProjectSummary>> {
  @override
  Future<List<ProjectSummary>> build() async {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) return const [];
    // Re-fetch when the signed-in user changes.
    final _ = auth.session?.user.id;
    return ref.read(projectRepositoryProvider).fetchProjects();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(projectRepositoryProvider).fetchProjects(),
    );
  }

  Future<ProjectSummary> createProject(CreateProjectInput input) async {
    final created = await ref
        .read(projectRepositoryProvider)
        .createProject(input);
    await refresh();
    return created;
  }

  Future<void> updateStatus(String id, String status) async {
    await ref.read(projectRepositoryProvider).updateStatus(id, status);
    await refresh();
  }
}
