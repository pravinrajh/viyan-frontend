
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/reminder.dart';
import 'reminder_repository.dart';

class ApiReminderRepository implements ReminderRepository {
  ApiReminderRepository(this._client);

  final ApiClient _client;
  static const _pageSize = 100;

  Future<List<Reminder>> _paginate(String path) async {
    final items = <Reminder>[];
    var page = 1;
    var totalPages = 1;
    while (page <= totalPages && page <= 20) {
      final response = await _client.get<dynamic>(
        path,
        queryParameters: {'page': '$page', 'limit': '$_pageSize'},
      );
      final rows = ApiEnvelope.dataList(response.data);
      for (final row in rows) {
        try {
          items.add(Reminder.fromJson(row));
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

  List<Reminder> _parseFlexibleList(Object? body) {
    try {
      final rows = ApiEnvelope.dataList(body);
      final items = <Reminder>[];
      for (final row in rows) {
        try {
          items.add(Reminder.fromJson(row));
        } catch (_) {}
      }
      return items;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<Reminder>> fetchReminders() => _paginate(ApiEndpoints.reminders);

  @override
  Future<List<Reminder>> fetchToday() async {
    final response = await _client.get<dynamic>(ApiEndpoints.remindersToday);
    return _parseFlexibleList(response.data);
  }

  @override
  Future<List<Reminder>> fetchUpcoming() async {
    final response =
        await _client.get<dynamic>(ApiEndpoints.remindersUpcoming);
    return _parseFlexibleList(response.data);
  }

  @override
  Future<Reminder> fetchReminder(String id) async {
    final response = await _client.get<dynamic>(ApiEndpoints.reminder(id));
    return Reminder.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<Reminder> createReminder(CreateReminderInput input) async {
    final body = <String, dynamic>{
      'title': input.title.trim(),
      'scheduledAt': input.scheduledAt.toUtc().toIso8601String(),
    };
    if (input.description.trim().isNotEmpty) {
      body['description'] = input.description.trim();
    }
    if (input.reminderType != null && input.reminderType!.isNotEmpty) {
      body['reminderType'] = input.reminderType;
    }
    if (input.sourceType != null && input.sourceType!.isNotEmpty) {
      body['sourceType'] = input.sourceType;
    }
    final sourceId = input.sourceId?.trim();
    if (sourceId != null && sourceId.isNotEmpty) body['sourceId'] = sourceId;
    if (input.timezone != null && input.timezone!.isNotEmpty) {
      body['timezone'] = input.timezone;
    }
    if (input.priority != null) body['priority'] = input.priority!.apiValue;
    if (input.actionUrl != null && input.actionUrl!.trim().isNotEmpty) {
      body['actionUrl'] = input.actionUrl!.trim();
    }
    final response = await _client.post<dynamic>(
      ApiEndpoints.reminders,
      data: body,
    );
    return Reminder.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<Reminder> updateReminder(String id, UpdateReminderInput input) async {
    final body = <String, dynamic>{};
    if (input.title != null) body['title'] = input.title!.trim();
    if (input.description != null) {
      body['description'] = input.description!.trim();
    }
    if (input.scheduledAt != null) {
      body['scheduledAt'] = input.scheduledAt!.toUtc().toIso8601String();
    }
    if (input.timezone != null) body['timezone'] = input.timezone;
    if (input.priority != null) body['priority'] = input.priority!.apiValue;
    if (input.actionUrl != null) body['actionUrl'] = input.actionUrl;
    final response = await _client.patch<dynamic>(
      ApiEndpoints.reminder(id),
      data: body,
    );
    return Reminder.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<Reminder> complete(String id) async {
    final response =
        await _client.patch<dynamic>(ApiEndpoints.reminderComplete(id));
    return Reminder.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<Reminder> cancel(String id) async {
    final response =
        await _client.patch<dynamic>(ApiEndpoints.reminderCancel(id));
    return Reminder.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<Reminder> snooze(String id, DateTime scheduledAt) async {
    final response = await _client.patch<dynamic>(
      ApiEndpoints.reminderSnooze(id),
      data: {'scheduledAt': scheduledAt.toUtc().toIso8601String()},
    );
    return Reminder.fromJson(ApiEnvelope.dataMap(response.data));
  }
}
