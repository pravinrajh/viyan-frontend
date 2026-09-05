
import '../models/reminder.dart';

abstract class ReminderRepository {
  Future<List<Reminder>> fetchReminders();
  Future<List<Reminder>> fetchToday();
  Future<List<Reminder>> fetchUpcoming();
  Future<Reminder> fetchReminder(String id);
  Future<Reminder> createReminder(CreateReminderInput input);
  Future<Reminder> updateReminder(String id, UpdateReminderInput input);
  Future<Reminder> complete(String id);
  Future<Reminder> cancel(String id);
  Future<Reminder> snooze(String id, DateTime scheduledAt);
}
