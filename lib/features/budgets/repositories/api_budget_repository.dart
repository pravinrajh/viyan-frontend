
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_envelope.dart';
import '../models/budget.dart';
import 'budget_repository.dart';

class ApiBudgetRepository implements BudgetRepository {
  ApiBudgetRepository(this._client);

  final ApiClient _client;
  static const _pageSize = 100;

  @override
  Future<List<Budget>> fetchBudgets() async {
    final items = <Budget>[];
    var page = 1;
    var totalPages = 1;
    while (page <= totalPages && page <= 20) {
      final response = await _client.get<dynamic>(
        ApiEndpoints.financeBudgets,
        queryParameters: {'page': '$page', 'limit': '$_pageSize'},
      );
      final rows = ApiEnvelope.dataList(response.data);
      for (final row in rows) {
        try {
          items.add(Budget.fromJson(row));
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
  Future<Budget> fetchBudget(String id) async {
    final response = await _client.get<dynamic>(ApiEndpoints.financeBudget(id));
    return Budget.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<BudgetSummary> fetchSummary(String id) async {
    final response =
        await _client.get<dynamic>(ApiEndpoints.financeBudgetSummary(id));
    return BudgetSummary.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<Budget> createBudget(CreateBudgetInput input) async {
    final body = <String, dynamic>{
      'name': input.name.trim(),
      'amount': input.amount,
      'periodStart': input.periodStart.toUtc().toIso8601String(),
      'periodEnd': input.periodEnd.toUtc().toIso8601String(),
    };
    final projectId = input.projectId?.trim();
    if (projectId != null && projectId.isNotEmpty) {
      body['projectId'] = projectId;
    }
    final categoryId = input.categoryId?.trim();
    if (categoryId != null && categoryId.isNotEmpty) {
      body['categoryId'] = categoryId;
    }
    if (input.currency != null && input.currency!.trim().isNotEmpty) {
      body['currency'] = input.currency!.trim();
    }
    if (input.status != null) body['status'] = input.status!.apiValue;
    final response = await _client.post<dynamic>(
      ApiEndpoints.financeBudgets,
      data: body,
    );
    return Budget.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<Budget> updateBudget(String id, UpdateBudgetInput input) async {
    final body = <String, dynamic>{};
    if (input.name != null) body['name'] = input.name!.trim();
    if (input.projectId != null) body['projectId'] = input.projectId;
    if (input.categoryId != null) body['categoryId'] = input.categoryId;
    if (input.amount != null) body['amount'] = input.amount;
    if (input.periodStart != null) {
      body['periodStart'] = input.periodStart!.toUtc().toIso8601String();
    }
    if (input.periodEnd != null) {
      body['periodEnd'] = input.periodEnd!.toUtc().toIso8601String();
    }
    if (input.status != null) body['status'] = input.status!.apiValue;
    final response = await _client.patch<dynamic>(
      ApiEndpoints.financeBudget(id),
      data: body,
    );
    return Budget.fromJson(ApiEnvelope.dataMap(response.data));
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _client.delete<dynamic>(ApiEndpoints.financeBudget(id));
  }
}
