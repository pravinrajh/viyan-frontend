
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/md_note.dart';
import 'md_note_repository.dart';

class ApiMdNoteRepository implements MdNoteRepository {
  ApiMdNoteRepository(this._client);

  final ApiClient _client;
  static const _pageSize = 100;

  @override
  Future<List<MdNote>> fetchNotes() async {
    final items = <MdNote>[];
    var page = 1;
    var totalPages = 1;
    while (page <= totalPages && page <= 20) {
      final response = await _client.get<dynamic>(
        ApiEndpoints.mdNotes,
        queryParameters: {'page': '$page', 'limit': '$_pageSize'},
      );
      final rows = ApiEnvelope.dataList(response.data);
      for (final row in rows) {
        try {
          items.add(MdNote.fromJson(row));
        } catch (_) {}
      }
      final meta = ApiEnvelope.meta(response.data);
      final reported = meta?['totalPages'];
      totalPages = reported is num && reported > 0 ? reported.toInt() : 1;
      if (rows.isEmpty) break;
      page += 1;
    }
    return items;
  }

  @override
  Future<MdNote> fetchNote(String id) async {
    final response = await _client.get<dynamic>(ApiEndpoints.mdNote(id));
    return MdNote.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<MdNote> createNote(CreateMdNoteInput input) async {
    final body = <String, dynamic>{
      'body': input.body.trim(),
      'relatedType': input.relatedType.apiValue,
    };
    final relatedId = input.relatedId?.trim();
    if (relatedId != null &&
        relatedId.isNotEmpty &&
        input.relatedType != MdNoteRelatedType.none) {
      body['relatedId'] = relatedId;
    }
    final response = await _client.post<dynamic>(
      ApiEndpoints.mdNotes,
      data: body,
    );
    return MdNote.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<MdNote> updateNote(String id, UpdateMdNoteInput input) async {
    final body = <String, dynamic>{};
    if (input.body != null) body['body'] = input.body!.trim();
    if (input.relatedType != null) {
      body['relatedType'] = input.relatedType!.apiValue;
    }
    if (input.relatedId != null) body['relatedId'] = input.relatedId;
    final response = await _client.patch<dynamic>(
      ApiEndpoints.mdNote(id),
      data: body,
    );
    return MdNote.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<void> deleteNote(String id) async {
    await _client.delete<dynamic>(ApiEndpoints.mdNote(id));
  }
}
