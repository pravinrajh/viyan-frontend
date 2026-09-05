import '../../../core/utils/mock_delay.dart';
import '../models/assistant_message.dart';
import 'assistant_repository.dart';

class MockAssistantRepository implements AssistantRepository {
  MockAssistantRepository({this.delay});

  final Duration? delay;
  String? _conversationId;

  @override
  Future<AssistantChatResult> chat({
    required String message,
    String? conversationId,
  }) async {
    await mockDelay(delay: delay);
    _conversationId =
        conversationId?.trim().isNotEmpty == true
            ? conversationId!.trim()
            : (_conversationId ?? 'mock-conv-1');
    final structured = _structuredReply(message);
    return AssistantChatResult(
      conversationId: _conversationId,
      mode: 'CHAT',
      reply: structured.toDisplayText(),
      intent: structured.intent,
      status: 'COMPLETED',
      requiresConfirmation: false,
      data: {
        if (structured.items.isNotEmpty) 'items': structured.items,
      },
      geminiConnected: false,
    );
  }

  @override
  Future<List<AssistantHistoryItem>> fetchHistory({
    String? conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    await mockDelay(delay: delay);
    final conv = conversationId ?? _conversationId ?? 'mock-conv-1';
    return [
      AssistantHistoryItem(
        queryId: 'hist-1',
        conversationId: conv,
        message: 'Show my pending tasks.',
        intent: 'PENDING_TASKS',
        answer: 'You have 5 pending tasks requiring attention.',
        status: 'COMPLETED',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  @override
  Future<AssistantChatResult> confirmAction({
    required String actionId,
    required bool confirmed,
  }) async {
    await mockDelay(delay: delay);
    return AssistantChatResult(
      conversationId: _conversationId ?? 'mock-conv-1',
      mode: 'ACTION',
      reply: confirmed
          ? 'Confirmed action $actionId.'
          : 'Cancelled action $actionId.',
      intent: 'CONFIRM_ACTION',
      status: confirmed ? 'COMPLETED' : 'CANCELLED',
      requiresConfirmation: false,
      actionId: actionId,
      geminiConnected: false,
    );
  }

  @override
  Future<MomImportResult> importMeetingMinutes({
    required String text,
    String? conversationId,
  }) async {
    await mockDelay(delay: delay);
    return const MomImportResult(
      itemsFound: 1,
      created: [
        MomImportItem(
          title: 'Mock task from meeting minutes',
          status: 'CREATED',
          taskId: 'TASK-MOCK-1',
        ),
      ],
      skipped: [],
      usedAi: false,
    );
  }

  AssistantQueryResponse _structuredReply(String prompt) {
    final text = prompt.toLowerCase();

    if (text.contains('pending task') ||
        (text.contains('task') && text.contains('pending')) ||
        text.contains('overdue tasks')) {
      return const AssistantQueryResponse(
        intent: 'PENDING_TASKS',
        summary: 'You have 5 pending tasks requiring attention.',
        items: [
          'Follow up ABC Builders collection — due today (Critical)',
          'Site visit — Chennai Villa finishing — due tomorrow (High)',
          'Call Kumar Residence on proposal — due in 2 days',
          'Weekly cash forecast — due in 2 days',
          'Green Homes site visit scheduling — due in 4 days',
        ],
        actions: ['Open Tasks', 'Assign owner', 'Set reminder'],
      );
    }

    if (text.contains('complete today') ||
        text.contains('need to complete') ||
        text.contains('needs my attention') ||
        text.contains('business status')) {
      return const AssistantQueryResponse(
        intent: 'BUSINESS_STATUS',
        summary:
            'Overall status: operations stable with 4 critical actions and 1 high-risk project.',
        items: [
          'Tasks: 10 total · overdue present on OMR foundation variation',
          'Sales pipeline: ₹92.00 L · 4 new leads',
          'Collections pending: ₹78.00 L',
          'Finance weekly need: ₹24.50 L',
          'Projects: 4 active · 1 at risk (OMR Commercial)',
        ],
        actions: ['Open Dashboard', 'Ask about Chennai project'],
      );
    }

    if (text.contains('sathish')) {
      return const AssistantQueryResponse(
        intent: 'TEAM_STATUS',
        summary: "Sathish's status today: on track with assigned follow-ups.",
        items: [
          '2 open tasks',
          '1 meeting scheduled this afternoon',
          'No blockers reported',
        ],
      );
    }

    if (text.contains('omr')) {
      return const AssistantQueryResponse(
        intent: 'PROJECT_STATUS',
        summary:
            'OMR Commercial is at 35% progress with elevated risk on foundation variation.',
        items: [
          'Pending legal verification on related land parcel',
          'Schedule slip vs baseline: 12 days',
        ],
        actions: ['Escalate to Raj', 'Open OMR Commercial'],
      );
    }

    if (text.contains('meeting')) {
      return const AssistantQueryResponse(
        intent: 'TODAYS_MEETINGS',
        summary: 'You have 4 meetings today.',
        items: [
          '9:00 AM — Leadership standup (MD cabin)',
          '11:00 AM — Chennai Villa progress review',
          '2:00 PM — Banker call — working capital',
          '4:30 PM — OMR Commercial risk huddle',
        ],
      );
    }

    if (text.contains('chennai')) {
      return const AssistantQueryResponse(
        intent: 'PROJECT_STATUS',
        summary:
            'Chennai Villa is at 68% progress with medium risk. Contract value ₹2.50 Cr.',
        items: [
          'Customer: ABC Builders',
          'PM: Raj · Pending tasks: 3',
          'Outstanding collection: ₹48 L on milestone 3',
          'Next action: finishing quality site visit',
        ],
        actions: ['Assign Raj to site check', 'Open project'],
      );
    }

    return const AssistantQueryResponse(
      intent: 'GENERAL',
      summary:
          'I understood your question. This is a structured mock reply for tests.',
      items: [
        "Try: Today's business status",
        'Try: What needs my attention?',
        'Try: Show overdue tasks',
      ],
    );
  }
}
