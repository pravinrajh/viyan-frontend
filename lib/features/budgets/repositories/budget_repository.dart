
import '../models/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> fetchBudgets();
  Future<Budget> fetchBudget(String id);
  Future<BudgetSummary> fetchSummary(String id);
  Future<Budget> createBudget(CreateBudgetInput input);
  Future<Budget> updateBudget(String id, UpdateBudgetInput input);
  Future<void> deleteBudget(String id);
}
