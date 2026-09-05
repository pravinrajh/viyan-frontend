import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/meeting.dart';
import '../repositories/api_meeting_repository.dart';
import '../repositories/meeting_repository.dart';

final meetingRepositoryProvider = Provider<MeetingRepository>((ref) {
  return ApiMeetingRepository(ref.watch(apiClientProvider));
});

final meetingsProvider =
    AsyncNotifierProvider<MeetingsNotifier, List<Meeting>>(MeetingsNotifier.new);

class MeetingsNotifier extends AsyncNotifier<List<Meeting>> {
  @override
  Future<List<Meeting>> build() async {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) return const [];
    final _ = auth.session?.user.id;
    return ref.read(meetingRepositoryProvider).fetchMeetings();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(meetingRepositoryProvider).fetchMeetings(),
    );
  }

  Future<Meeting> createMeeting(CreateMeetingInput input) async {
    final created = await ref
        .read(meetingRepositoryProvider)
        .createMeeting(input);
    await refresh();
    return created;
  }

  Future<void> updateStatus(String id, String status) async {
    await ref.read(meetingRepositoryProvider).updateStatus(id, status);
    await refresh();
  }
}
