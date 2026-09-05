
import '../models/sales_activity.dart';

abstract class SalesActivityRepository {
  Future<List<SalesActivity>> fetchActivities();
  Future<SalesActivity> fetchActivity(String id);
  Future<SalesActivity> createActivity(CreateSalesActivityInput input);
  Future<SalesActivity> updateActivity(String id, UpdateSalesActivityInput input);
  Future<SalesActivity> updateStatus(String id, SalesActivityStatus status);
  Future<void> deleteActivity(String id);
}
