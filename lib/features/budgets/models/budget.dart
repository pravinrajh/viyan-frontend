
enum BudgetStatus { active, closed, cancelled }

extension BudgetStatusX on BudgetStatus {
  String get label => switch (this) {
    BudgetStatus.active => 'Active',
    BudgetStatus.closed => 'Closed',
    BudgetStatus.cancelled => 'Cancelled',
  };

  String get apiValue => switch (this) {
    BudgetStatus.active => 'ACTIVE',
    BudgetStatus.closed => 'CLOSED',
    BudgetStatus.cancelled => 'CANCELLED',
  };

  static BudgetStatus fromApi(String value) {
    return switch (value.toUpperCase()) {
      'CLOSED' => BudgetStatus.closed,
      'CANCELLED' || 'CANCELED' => BudgetStatus.cancelled,
      _ => BudgetStatus.active,
    };
  }
}

class Budget {
  const Budget({
    required this.id,
    required this.budgetId,
    required this.name,
    required this.amount,
    required this.periodStart,
    required this.periodEnd,
    required this.status,
    this.projectId,
    this.categoryId,
    this.currency = 'INR',
  });

  final String id;
  final String budgetId;
  final String name;
  final String? projectId;
  final String? categoryId;
  final int amount;
  final String currency;
  final DateTime periodStart;
  final DateTime periodEnd;
  final BudgetStatus status;

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: _s(json['id'], json['_id']),
      budgetId: _s(json['budgetId']),
      name: _s(json['name']),
      projectId: _sOrNull(json['projectId']),
      categoryId: _sOrNull(json['categoryId']),
      amount: _int(json['amount']),
      currency: _s(json['currency'], 'INR'),
      periodStart: _date(json['periodStart']) ?? DateTime.now(),
      periodEnd: _date(json['periodEnd']) ?? DateTime.now(),
      status: BudgetStatusX.fromApi(_s(json['status'])),
    );
  }
}

class BudgetSummary {
  const BudgetSummary({
    required this.raw,
    this.budgetId,
    this.name,
    this.amount,
    this.actual,
    this.variance,
    this.currency,
  });

  /// Preserve unknown API fields without inventing structure.
  final Map<String, dynamic> raw;
  final String? budgetId;
  final String? name;
  final int? amount;
  final int? actual;
  final int? variance;
  final String? currency;

  factory BudgetSummary.fromJson(Map<String, dynamic> json) {
    int? asInt(Object? v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    String? asString(Object? v) =>
        v is String && v.isNotEmpty ? v : null;

    return BudgetSummary(
      raw: Map<String, dynamic>.from(json),
      budgetId: asString(json['budgetId'] ?? json['id']),
      name: asString(json['name']),
      amount: asInt(json['amount'] ?? json['budgetAmount']),
      actual: asInt(json['actual'] ?? json['spent'] ?? json['actualAmount']),
      variance: asInt(json['variance']),
      currency: asString(json['currency']),
    );
  }
}

class CreateBudgetInput {
  const CreateBudgetInput({
    required this.name,
    required this.amount,
    required this.periodStart,
    required this.periodEnd,
    this.projectId,
    this.categoryId,
    this.currency,
    this.status,
  });

  final String name;
  final int amount;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String? projectId;
  final String? categoryId;
  final String? currency;
  final BudgetStatus? status;
}

class UpdateBudgetInput {
  const UpdateBudgetInput({
    this.name,
    this.projectId,
    this.categoryId,
    this.amount,
    this.periodStart,
    this.periodEnd,
    this.status,
  });

  final String? name;
  final String? projectId;
  final String? categoryId;
  final int? amount;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final BudgetStatus? status;
}

String _s(Object? v, [Object? f]) {
  if (v is String && v.isNotEmpty) return v;
  if (f is String && f.isNotEmpty) return f;
  return '';
}

String? _sOrNull(Object? v) {
  final t = _s(v);
  return t.isEmpty ? null : t;
}

int _int(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

DateTime? _date(Object? v) {
  if (v is DateTime) return v;
  if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
  return null;
}
