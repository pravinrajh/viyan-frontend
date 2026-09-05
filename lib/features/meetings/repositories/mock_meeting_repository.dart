import '../../../core/mock/sat_demo_seed.dart';
import '../../../core/utils/mock_delay.dart';
import '../models/meeting.dart';
import 'meeting_repository.dart';

class MockMeetingRepository implements MeetingRepository {
  MockMeetingRepository({this.delay});

  final Duration? delay;

  @override
  Future<List<Meeting>> fetchMeetings() {
    return withMockDelay(SatDemoSeed.meetings(), delay: delay);
  }

  @override
  Future<Meeting> createMeeting(CreateMeetingInput input) async {
    await mockDelay(delay: delay);
    return Meeting(
      id: 'mtg-new',
      title: input.title,
      startAt: input.startAt,
      endAt: input.endAt,
      location: input.location,
      attendees: const [],
      status: 'SCHEDULED',
    );
  }

  @override
  Future<Meeting> updateStatus(String id, String status) async {
    final items = await fetchMeetings();
    final existing = items.firstWhere(
      (m) => m.id == id,
      orElse: () => items.first,
    );
    return Meeting(
      id: existing.id,
      title: existing.title,
      startAt: existing.startAt,
      endAt: existing.endAt,
      location: existing.location,
      attendees: existing.attendees,
      status: status,
      projectName: existing.projectName,
      customerName: existing.customerName,
    );
  }
}
