import '../models/meeting.dart';

class CreateMeetingInput {
  const CreateMeetingInput({
    required this.title,
    required this.startAt,
    required this.endAt,
    this.description = '',
    this.location = '',
    this.projectId,
    this.participantIds = const [],
    this.meetingType = 'INTERNAL',
  });

  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final String description;
  final String location;
  final String? projectId;
  final List<String> participantIds;
  final String meetingType;
}

abstract class MeetingRepository {
  Future<List<Meeting>> fetchMeetings();
  Future<Meeting> createMeeting(CreateMeetingInput input);
  Future<Meeting> updateStatus(String id, String status);
}
