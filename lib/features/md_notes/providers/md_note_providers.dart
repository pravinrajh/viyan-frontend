
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/role_capabilities.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/md_note.dart';
import '../repositories/api_md_note_repository.dart';
import '../repositories/md_note_repository.dart';

final mdNoteRepositoryProvider = Provider<MdNoteRepository>((ref) {
  return ApiMdNoteRepository(ref.watch(apiClientProvider));
});

final mdNoteSearchProvider =
    NotifierProvider<MdNoteSearchNotifier, String>(MdNoteSearchNotifier.new);

class MdNoteSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

final mdNotesProvider =
    AsyncNotifierProvider<MdNotesNotifier, List<MdNote>>(MdNotesNotifier.new);

class MdNotesNotifier extends AsyncNotifier<List<MdNote>> {
  @override
  Future<List<MdNote>> build() async {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) return const [];
    final _ = auth.session?.user.id;
    return ref.read(mdNoteRepositoryProvider).fetchNotes();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(mdNoteRepositoryProvider).fetchNotes(),
    );
  }

  Future<MdNote> createNote(CreateMdNoteInput input) async {
    final created = await ref.read(mdNoteRepositoryProvider).createNote(input);
    await refresh();
    return created;
  }

  Future<MdNote> updateNote(String id, UpdateMdNoteInput input) async {
    final updated =
        await ref.read(mdNoteRepositoryProvider).updateNote(id, input);
    await refresh();
    return updated;
  }

  Future<void> deleteNote(String id) async {
    await ref.read(mdNoteRepositoryProvider).deleteNote(id);
    await refresh();
  }
}

final visibleMdNotesProvider = Provider<AsyncValue<List<MdNote>>>((ref) {
  final query = ref.watch(mdNoteSearchProvider).trim().toLowerCase();
  final notes = ref.watch(mdNotesProvider);
  return notes.whenData((items) {
    if (query.isEmpty) return items;
    return items
        .where(
          (n) =>
              n.body.toLowerCase().contains(query) ||
              n.noteId.toLowerCase().contains(query) ||
              n.relatedType.label.toLowerCase().contains(query),
        )
        .toList();
  });
});

final canManageMdNotesProvider = Provider<bool>((ref) {
  final role = ref.watch(sessionProvider)?.user.role;
  return RoleCapabilities.can(role, AppCapability.viewDashboard) &&
      RoleCapabilities.isManagerOrAbove(role);
});
