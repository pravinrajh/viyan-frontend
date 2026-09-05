import '../models/sales_summary.dart';

abstract class SalesRepository {
  Future<SalesSummary> fetchSummary();
  Future<SalesLead> createLead({
    required String name,
    required String source,
    String? companyName,
    String? phone,
    String? email,
    double? estimatedValue,
  });
}
