import '../models/assistant_message.dart';

abstract class AssistantRepository {
  Future<AssistantChatResult> chat({
    required String message,
    String? conversationId,
  });

  Future<List<AssistantHistoryItem>> fetchHistory({
    String? conversationId,
    int page = 1,
    int limit = 50,
  });

  Future<AssistantChatResult> confirmAction({
    required String actionId,
    required bool confirmed,
  });

  Future<MomImportResult> importMeetingMinutes({
    required String text,
    String? conversationId,
  });
}
