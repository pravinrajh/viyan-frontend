enum MessageRole { user, assistant }

/// Structured assistant payload kept for tests and display helpers.
class AssistantQueryResponse {
  const AssistantQueryResponse({
    required this.intent,
    required this.summary,
    this.items = const [],
    this.actions = const [],
  });

  final String intent;
  final String summary;
  final List<String> items;
  final List<String> actions;

  factory AssistantQueryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final items = <String>[];
    if (json['items'] is List) {
      items.addAll((json['items'] as List).map((e) => e.toString()));
    } else if (data is Map && data['tasks'] is List) {
      for (final task in data['tasks'] as List) {
        if (task is Map && task['title'] != null) {
          items.add(task['title'].toString());
        } else {
          items.add(task.toString());
        }
      }
    }
    return AssistantQueryResponse(
      intent: json['intent'] as String? ?? 'GENERAL',
      summary:
          json['answer'] as String? ??
          json['summary'] as String? ??
          json['reply'] as String? ??
          json['message'] as String? ??
          '',
      items: items,
      actions:
          (json['actions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'intent': intent,
    'summary': summary,
    'items': items,
    'actions': actions,
  };

  String toDisplayText() {
    final buffer = StringBuffer(summary);
    if (items.isNotEmpty) {
      buffer.writeln();
      for (final item in items) {
        buffer.writeln('• $item');
      }
    }
    if (actions.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Suggested actions:');
      for (final action in actions) {
        buffer.writeln('→ $action');
      }
    }
    return buffer.toString().trim();
  }
}

/// Live chat response from POST `/api/v1/assistant/chat` (and confirm).
class AssistantChatResult {
  const AssistantChatResult({
    required this.reply,
    this.conversationId,
    this.mode,
    this.intent,
    this.status,
    this.requiresConfirmation = false,
    this.data,
    this.actionId,
    this.geminiConnected,
  });

  final String reply;
  final String? conversationId;
  final String? mode;
  final String? intent;
  final String? status;
  final bool requiresConfirmation;
  final Map<String, dynamic>? data;
  final String? actionId;
  final bool? geminiConnected;

  factory AssistantChatResult.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? data;
    final raw = json['data'];
    if (raw is Map<String, dynamic>) {
      data = raw;
    } else if (raw is Map) {
      data = Map<String, dynamic>.from(raw);
    }

    return AssistantChatResult(
      conversationId: json['conversationId']?.toString(),
      mode: json['mode']?.toString(),
      reply:
          json['reply'] as String? ??
          json['answer'] as String? ??
          json['summary'] as String? ??
          json['message'] as String? ??
          '',
      intent: json['intent']?.toString(),
      status: json['status']?.toString(),
      requiresConfirmation: json['requiresConfirmation'] == true,
      data: data,
      actionId: json['actionId']?.toString(),
      geminiConnected: json['geminiConnected'] is bool
          ? json['geminiConnected'] as bool
          : null,
    );
  }

  /// Task / meeting ids when an ACTION result embeds them in [data].
  String? get createdTaskId {
    final d = data;
    if (d == null) return null;
    final task = d['task'];
    if (task is Map && task['id'] != null) return task['id'].toString();
    if (d['taskId'] != null) return d['taskId'].toString();
    return null;
  }

  String? get createdMeetingId {
    final d = data;
    if (d == null) return null;
    final meeting = d['meeting'];
    if (meeting is Map && meeting['id'] != null) {
      return meeting['id'].toString();
    }
    if (d['meetingId'] != null) return d['meetingId'].toString();
    return null;
  }

  bool get hasTaskOrMeetingResult =>
      createdTaskId != null || createdMeetingId != null;
}

/// One row from GET `/api/v1/assistant/history`.
class AssistantHistoryItem {
  const AssistantHistoryItem({
    required this.queryId,
    required this.message,
    required this.createdAt,
    this.conversationId,
    this.intent,
    this.answer,
    this.status,
  });

  final String queryId;
  final String? conversationId;
  final String message;
  final String? intent;
  final String? answer;
  final String? status;
  final DateTime createdAt;

  factory AssistantHistoryItem.fromJson(Map<String, dynamic> json) {
    return AssistantHistoryItem(
      queryId:
          json['queryId']?.toString() ??
          json['id']?.toString() ??
          'history-${DateTime.now().microsecondsSinceEpoch}',
      conversationId: json['conversationId']?.toString(),
      message: json['message'] as String? ?? '',
      intent: json['intent']?.toString(),
      answer: json['answer'] as String? ?? json['reply'] as String?,
      status: json['status']?.toString(),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }
}

/// Sidebar summary of a conversation (grouped history).
class AssistantConversationSummary {
  const AssistantConversationSummary({
    required this.conversationId,
    required this.title,
    required this.updatedAt,
  });

  final String conversationId;
  final String title;
  final DateTime updatedAt;
}

class AssistantMessage {
  const AssistantMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.intent,
    this.items = const [],
    this.status,
    this.requiresConfirmation = false,
    this.actionId,
    this.data,
    this.taskId,
    this.meetingId,
  });

  final String id;
  final MessageRole role;
  final String content;
  final DateTime createdAt;
  final String? intent;
  final List<String> items;
  final String? status;
  final bool requiresConfirmation;
  final String? actionId;
  final Map<String, dynamic>? data;
  final String? taskId;
  final String? meetingId;

  bool get isUser => role == MessageRole.user;

  bool get hasActionResult => taskId != null || meetingId != null;

  factory AssistantMessage.fromQueryResponse({
    required String id,
    required AssistantQueryResponse response,
    DateTime? createdAt,
  }) {
    return AssistantMessage(
      id: id,
      role: MessageRole.assistant,
      content: response.toDisplayText(),
      createdAt: createdAt ?? DateTime.now(),
      intent: response.intent,
      items: response.items,
    );
  }

  factory AssistantMessage.fromChatResult({
    required String id,
    required AssistantChatResult result,
    DateTime? createdAt,
  }) {
    return AssistantMessage(
      id: id,
      role: MessageRole.assistant,
      content: result.reply,
      createdAt: createdAt ?? DateTime.now(),
      intent: result.intent,
      status: result.status,
      requiresConfirmation: result.requiresConfirmation,
      actionId: result.actionId,
      data: result.data,
      taskId: result.createdTaskId,
      meetingId: result.createdMeetingId,
    );
  }

  factory AssistantMessage.fromJson(Map<String, dynamic> json) {
    return AssistantMessage(
      id: json['id'] as String,
      role: json['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
      content: json['content'] as String? ?? json['summary'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      intent: json['intent'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      status: json['status'] as String?,
      requiresConfirmation: json['requiresConfirmation'] == true,
      actionId: json['actionId']?.toString(),
      taskId: json['taskId']?.toString(),
      meetingId: json['meetingId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role.name,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'intent': intent,
    'items': items,
    'status': status,
    'requiresConfirmation': requiresConfirmation,
    'actionId': actionId,
    'taskId': taskId,
    'meetingId': meetingId,
  };
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

/// One task that was created (or skipped) while importing meeting minutes.
class MomImportItem {
  const MomImportItem({
    required this.title,
    required this.status,
    this.employeeName,
    this.taskId,
    this.reason,
  });

  final String title;
  final String status;
  final String? employeeName;
  final String? taskId;
  final String? reason;

  factory MomImportItem.fromJson(Map<String, dynamic> json) {
    return MomImportItem(
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'SKIPPED',
      employeeName: json['employeeName']?.toString(),
      taskId: json['taskId']?.toString(),
      reason: json['reason']?.toString(),
    );
  }
}

/// Result of POST `/api/v1/assistant/import-minutes`.
class MomImportResult {
  const MomImportResult({
    required this.itemsFound,
    required this.created,
    required this.skipped,
    required this.usedAi,
  });

  final int itemsFound;
  final List<MomImportItem> created;
  final List<MomImportItem> skipped;
  final bool usedAi;

  factory MomImportResult.fromJson(Map<String, dynamic> json) {
    List<MomImportItem> parseList(Object? raw) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) => MomImportItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return MomImportResult(
      itemsFound: (json['itemsFound'] as num?)?.toInt() ?? 0,
      created: parseList(json['created']),
      skipped: parseList(json['skipped']),
      usedAi: json['usedAi'] == true,
    );
  }

  /// Chat-style summary shown as an assistant message after import.
  String toDisplayText() {
    if (itemsFound == 0) {
      return "I couldn't find any action items in that text. Try pasting the "
          'meeting minutes with clear action points (e.g. "Sathish to send '
          'the report by Friday").';
    }
    final buffer = StringBuffer();
    if (created.isEmpty) {
      buffer.writeln(
        'I found $itemsFound action item${itemsFound == 1 ? '' : 's'} but '
        "couldn't create any tasks:",
      );
    } else {
      buffer.writeln(
        'Created ${created.length} task${created.length == 1 ? '' : 's'} '
        'from the meeting minutes:',
      );
      for (final item in created) {
        final who = item.employeeName != null ? ' → ${item.employeeName}' : '';
        buffer.writeln('• ${item.title}$who');
      }
    }
    if (skipped.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Skipped ${skipped.length}:');
      for (final item in skipped) {
        buffer.writeln('• ${item.title} — ${item.reason ?? 'needs review'}');
      }
    }
    return buffer.toString().trim();
  }
}
