import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/meeting.dart';
import 'meeting_repository.dart';

/// Live meetings from MD_EAO_BACKEND.
class ApiMeetingRepository implements MeetingRepository {
  ApiMeetingRepository(this._client);

  final ApiClient _client;

  static const _pageSize = 100;

  @override
  Future<List<Meeting>> fetchMeetings() async {
    final meetings = <Meeting>[];
    var page = 1;
    var totalPages = 1;

    while (page <= totalPages && page <= 20) {
      final response = await _client.get<dynamic>(
        ApiEndpoints.meetings,
        queryParameters: {'page': '$page', 'limit': '$_pageSize'},
      );
      final items = ApiEnvelope.dataList(response.data);
      for (final item in items) {
        try {
          meetings.add(Meeting.fromJson(item));
        } catch (_) {}
      }
      final meta = ApiEnvelope.meta(response.data);
      final reported = meta?['totalPages'];
      totalPages = reported is num && reported > 0 ? reported.toInt() : 1;
      if (items.isEmpty) break;
      page += 1;
    }

    return meetings;
  }

  @override
  Future<Meeting> createMeeting(CreateMeetingInput input) async {
    final body = <String, dynamic>{
      'title': input.title.trim(),
      'startTime': input.startAt.toUtc().toIso8601String(),
      'endTime': input.endAt.toUtc().toIso8601String(),
      'meetingType': input.meetingType,
    };
    if (input.description.trim().isNotEmpty) {
      body['description'] = input.description.trim();
    }
    if (input.location.trim().isNotEmpty) {
      body['location'] = input.location.trim();
    }
    if (input.projectId != null && input.projectId!.isNotEmpty) {
      body['projectId'] = input.projectId;
    }
    if (input.participantIds.isNotEmpty) {
      body['participants'] = input.participantIds;
    }
    final response = await _client.post<dynamic>(
      ApiEndpoints.meetings,
      data: body,
    );
    return Meeting.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<Meeting> updateStatus(String id, String status) async {
    final response = await _client.patch<dynamic>(
      ApiEndpoints.meetingStatus(id),
      data: {'status': status},
    );
    return Meeting.fromJson(ApiEnvelope.dataMap(response.data));
  }
}
