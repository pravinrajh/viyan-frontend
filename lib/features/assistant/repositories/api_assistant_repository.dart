import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/assistant_message.dart';
import 'assistant_repository.dart';

class ApiAssistantRepository implements AssistantRepository {
  ApiAssistantRepository(this._client);

  final ApiClient _client;

  @override
  Future<AssistantChatResult> chat({
    required String message,
    String? conversationId,
  }) async {
    final body = <String, dynamic>{'message': message};
    final conv = conversationId?.trim();
    if (conv != null && conv.isNotEmpty) {
      body['conversationId'] = conv;
    }
    final response = await _client.post<dynamic>(
      ApiEndpoints.assistantChat,
      data: body,
    );
    return AssistantChatResult.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<List<AssistantHistoryItem>> fetchHistory({
    String? conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    final conv = conversationId?.trim();
    if (conv != null && conv.isNotEmpty) {
      query['conversationId'] = conv;
    }
    final response = await _client.get<dynamic>(
      ApiEndpoints.assistantHistory,
      queryParameters: query,
    );
    return ApiEnvelope.dataList(response.data)
        .map(AssistantHistoryItem.fromJson)
        .toList();
  }

  @override
  Future<AssistantChatResult> confirmAction({
    required String actionId,
    required bool confirmed,
  }) async {
    final response = await _client.post<dynamic>(
      ApiEndpoints.assistantActionConfirm(actionId),
      data: {'confirmed': confirmed},
    );
    return AssistantChatResult.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<MomImportResult> importMeetingMinutes({
    required String text,
    String? conversationId,
  }) async {
    final body = <String, dynamic>{'text': text};
    final conv = conversationId?.trim();
    if (conv != null && conv.isNotEmpty) {
      body['conversationId'] = conv;
    }
    final response = await _client.post<dynamic>(
      ApiEndpoints.assistantImportMinutes,
      data: body,
    );
    return MomImportResult.fromJson(ApiEnvelope.dataMap(response.data));
  }
}
