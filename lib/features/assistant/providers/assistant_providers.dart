import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../meetings/providers/meeting_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../models/assistant_message.dart';
import '../repositories/api_assistant_repository.dart';
import '../repositories/assistant_repository.dart';

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  return ApiAssistantRepository(ref.watch(apiClientProvider));
});

class AssistantChatState {
  const AssistantChatState({
    this.conversationId,
    this.messages = const [],
    this.isSending = false,
    this.error,
    this.recentConversations = const [],
    this.searchQuery = '',
    this.isLoadingHistory = false,
    this.lastFailedPrompt,
  });

  final String? conversationId;
  final List<AssistantMessage> messages;
  final bool isSending;
  final String? error;
  final List<AssistantConversationSummary> recentConversations;
  final String searchQuery;
  final bool isLoadingHistory;
  final String? lastFailedPrompt;

  bool get isEmpty => messages.isEmpty && !isSending;

  List<AssistantConversationSummary> get filteredConversations {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return recentConversations;
    return recentConversations
        .where((c) => c.title.toLowerCase().contains(q))
        .toList(growable: false);
  }

  AssistantChatState copyWith({
    String? conversationId,
    bool clearConversationId = false,
    List<AssistantMessage>? messages,
    bool? isSending,
    String? error,
    bool clearError = false,
    List<AssistantConversationSummary>? recentConversations,
    String? searchQuery,
    bool? isLoadingHistory,
    String? lastFailedPrompt,
    bool clearLastFailedPrompt = false,
  }) {
    return AssistantChatState(
      conversationId:
          clearConversationId ? null : conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : error ?? this.error,
      recentConversations:
          recentConversations ?? this.recentConversations,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      lastFailedPrompt: clearLastFailedPrompt
          ? null
          : lastFailedPrompt ?? this.lastFailedPrompt,
    );
  }
}

final assistantProvider =
    NotifierProvider<AssistantNotifier, AssistantChatState>(
      AssistantNotifier.new,
    );

class AssistantNotifier extends Notifier<AssistantChatState> {
  @override
  AssistantChatState build() {
    Future.microtask(refreshHistory);
    return const AssistantChatState();
  }

  void setSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
  }

  Future<void> newChat() async {
    state = state.copyWith(
      clearConversationId: true,
      messages: const [],
      clearError: true,
      clearLastFailedPrompt: true,
      isSending: false,
    );
  }

  Future<void> refreshHistory() async {
    state = state.copyWith(isLoadingHistory: true, clearError: true);
    try {
      final items = await ref
          .read(assistantRepositoryProvider)
          .fetchHistory(page: 1, limit: 100);
      state = state.copyWith(
        recentConversations: _groupConversations(items),
        isLoadingHistory: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingHistory: false,
        error: error.toString(),
      );
    }
  }

  Future<void> loadConversation(String conversationId) async {
    final id = conversationId.trim();
    if (id.isEmpty) return;

    state = state.copyWith(
      conversationId: id,
      messages: const [],
      isLoadingHistory: true,
      clearError: true,
      clearLastFailedPrompt: true,
    );

    try {
      final items = await ref.read(assistantRepositoryProvider).fetchHistory(
            conversationId: id,
            page: 1,
            limit: 100,
          );
      final chronological = [...items]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final messages = <AssistantMessage>[];
      for (final item in chronological) {
        if (item.message.trim().isNotEmpty) {
          messages.add(
            AssistantMessage(
              id: 'user-${item.queryId}',
              role: MessageRole.user,
              content: item.message,
              createdAt: item.createdAt,
            ),
          );
        }
        final answer = item.answer?.trim();
        if (answer != null && answer.isNotEmpty) {
          messages.add(
            AssistantMessage(
              id: 'assistant-${item.queryId}',
              role: MessageRole.assistant,
              content: answer,
              createdAt: item.createdAt,
              intent: item.intent,
              status: item.status,
            ),
          );
        }
      }
      state = state.copyWith(
        conversationId: id,
        messages: messages,
        isLoadingHistory: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingHistory: false,
        error: error.toString(),
      );
    }
  }

  Future<void> send(String prompt) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty || state.isSending) return;

    final userMessage = AssistantMessage(
      id: 'user-${DateTime.now().microsecondsSinceEpoch}',
      role: MessageRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isSending: true,
      clearError: true,
      clearLastFailedPrompt: true,
    );

    try {
      final result = await ref.read(assistantRepositoryProvider).chat(
            message: trimmed,
            conversationId: state.conversationId,
          );
      final reply = AssistantMessage.fromChatResult(
        id: 'assistant-${DateTime.now().microsecondsSinceEpoch}',
        result: result,
      );
      state = state.copyWith(
        conversationId: result.conversationId ?? state.conversationId,
        messages: [...state.messages, reply],
        isSending: false,
      );
      _maybeInvalidateCreatedEntities(result);
      await refreshHistory();
    } catch (error) {
      state = state.copyWith(
        isSending: false,
        error: error.toString(),
        lastFailedPrompt: trimmed,
      );
    }
  }

  Future<void> retryLast() async {
    final prompt = state.lastFailedPrompt;
    if (prompt == null || prompt.isEmpty) return;
    // Drop the trailing user message that failed to get a reply if present.
    final messages = [...state.messages];
    if (messages.isNotEmpty &&
        messages.last.isUser &&
        messages.last.content == prompt) {
      messages.removeLast();
      state = state.copyWith(messages: messages);
    }
    await send(prompt);
  }

  Future<void> confirmAction({
    required String actionId,
    required bool confirmed,
  }) async {
    if (state.isSending) return;
    state = state.copyWith(isSending: true, clearError: true);
    try {
      final result = await ref.read(assistantRepositoryProvider).confirmAction(
            actionId: actionId,
            confirmed: confirmed,
          );
      final reply = AssistantMessage.fromChatResult(
        id: 'assistant-confirm-${DateTime.now().microsecondsSinceEpoch}',
        result: result,
      );
      state = state.copyWith(
        conversationId: result.conversationId ?? state.conversationId,
        messages: [...state.messages, reply],
        isSending: false,
      );
      _maybeInvalidateCreatedEntities(result);
      await refreshHistory();
    } catch (error) {
      state = state.copyWith(isSending: false, error: error.toString());
    }
  }

  /// Sends pasted meeting-minutes text to the backend, which extracts
  /// action items and creates a task for each one, then appends a summary
  /// of what was created to the current conversation.
  Future<void> importMeetingMinutes(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;

    final userMessage = AssistantMessage(
      id: 'user-mom-${DateTime.now().microsecondsSinceEpoch}',
      role: MessageRole.user,
      content: 'Imported meeting minutes (${trimmed.length} characters).',
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isSending: true,
      clearError: true,
    );

    try {
      final result = await ref
          .read(assistantRepositoryProvider)
          .importMeetingMinutes(
            text: trimmed,
            conversationId: state.conversationId,
          );
      final reply = AssistantMessage(
        id: 'assistant-mom-${DateTime.now().microsecondsSinceEpoch}',
        role: MessageRole.assistant,
        content: result.toDisplayText(),
        createdAt: DateTime.now(),
        intent: 'MOM_IMPORT',
      );
      state = state.copyWith(
        messages: [...state.messages, reply],
        isSending: false,
      );
      if (result.created.isNotEmpty) {
        ref.invalidate(tasksProvider);
      }
      await refreshHistory();
    } catch (error) {
      state = state.copyWith(isSending: false, error: error.toString());
    }
  }

  void _maybeInvalidateCreatedEntities(AssistantChatResult result) {
    if (result.createdTaskId != null) {
      ref.invalidate(tasksProvider);
    }
    if (result.createdMeetingId != null) {
      ref.invalidate(meetingsProvider);
    }
  }

  static List<AssistantConversationSummary> _groupConversations(
    List<AssistantHistoryItem> items,
  ) {
    final byId = <String, List<AssistantHistoryItem>>{};
    for (final item in items) {
      final id = item.conversationId?.trim();
      if (id == null || id.isEmpty) continue;
      byId.putIfAbsent(id, () => []).add(item);
    }

    final summaries = <AssistantConversationSummary>[];
    for (final entry in byId.entries) {
      final sorted = [...entry.value]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final title = sorted
              .map((e) => e.message.trim())
              .firstWhere((m) => m.isNotEmpty, orElse: () => 'Conversation')
          ;
      final updatedAt = sorted.last.createdAt;
      summaries.add(
        AssistantConversationSummary(
          conversationId: entry.key,
          title: title,
          updatedAt: updatedAt,
        ),
      );
    }
    summaries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return summaries;
  }
}
