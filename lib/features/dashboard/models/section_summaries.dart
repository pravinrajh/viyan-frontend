/// Dashboard-scoped sales snapshot (separate from Sales feature model).
class DashboardSalesSummary {
  const DashboardSalesSummary({
    required this.pipelineValue,
    required this.newLeads,
    required this.qualifiedLeads,
    required this.converted,
  });

  final double pipelineValue;
  final int newLeads;
  final int qualifiedLeads;
  final int converted;

  factory DashboardSalesSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSalesSummary(
      pipelineValue: (json['pipelineValue'] as num?)?.toDouble() ?? 0,
      newLeads: json['newLeads'] as int? ?? 0,
      qualifiedLeads: json['qualifiedLeads'] as int? ?? 0,
      converted: json['converted'] as int? ?? json['conversions'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'pipelineValue': pipelineValue,
    'newLeads': newLeads,
    'qualifiedLeads': qualifiedLeads,
    'converted': converted,
  };
}

class DashboardCollectionSummary {
  const DashboardCollectionSummary({
    required this.pending,
    required this.overdue,
    required this.expectedThisWeek,
  });

  final double pending;
  final double overdue;
  final double expectedThisWeek;

  factory DashboardCollectionSummary.fromJson(Map<String, dynamic> json) {
    return DashboardCollectionSummary(
      pending: (json['pending'] as num?)?.toDouble() ?? 0,
      overdue: (json['overdue'] as num?)?.toDouble() ?? 0,
      expectedThisWeek: (json['expectedThisWeek'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'pending': pending,
    'overdue': overdue,
    'expectedThisWeek': expectedThisWeek,
  };
}

class DashboardFinanceSummary {
  const DashboardFinanceSummary({
    required this.weeklyRequirement,
    required this.availableBalance,
    required this.plannedPayments,
  });

  final double weeklyRequirement;
  final double availableBalance;
  final double plannedPayments;

  factory DashboardFinanceSummary.fromJson(Map<String, dynamic> json) {
    return DashboardFinanceSummary(
      weeklyRequirement: (json['weeklyRequirement'] as num?)?.toDouble() ?? 0,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0,
      plannedPayments: (json['plannedPayments'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'weeklyRequirement': weeklyRequirement,
    'availableBalance': availableBalance,
    'plannedPayments': plannedPayments,
  };
}

class DashboardProjectSummary {
  const DashboardProjectSummary({
    required this.id,
    required this.name,
    required this.progress,
    required this.risk,
  });

  final String id;
  final String name;
  final double progress;
  final String risk;

  /// Linear progress 0–1. API health rows send 0–100; mocks used 0–1.
  double get progressFraction {
    if (progress <= 1) return progress.clamp(0, 1);
    return (progress / 100).clamp(0, 1);
  }

  factory DashboardProjectSummary.fromJson(Map<String, dynamic> json) {
    return DashboardProjectSummary(
      id: json['id'] as String? ?? json['projectId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      risk: _riskFrom(json),
    );
  }

  static String _riskFrom(Map<String, dynamic> json) {
    final risk = json['risk'];
    if (risk is String && risk.isNotEmpty) return risk.toLowerCase();
    final health = '${json['health'] ?? ''} ${json['healthCode'] ?? ''}'
        .toUpperCase();
    if (health.contains('RED') || health.contains('CRITICAL')) return 'high';
    if (health.contains('YELLOW') ||
        health.contains('AT_RISK') ||
        health.contains('WATCH')) {
      return 'medium';
    }
    return 'low';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'progress': progress,
    'risk': risk,
  };
}

class ProjectOverview {
  const ProjectOverview({
    required this.active,
    required this.completed,
    required this.atRisk,
    this.items = const [],
  });

  final int active;
  final int completed;
  final int atRisk;
  final List<DashboardProjectSummary> items;

  factory ProjectOverview.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] is List ? json['items'] as List : const [])
        .whereType<Map>()
        .map(
          (item) =>
              DashboardProjectSummary.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
    final total = json['total'];
    return ProjectOverview(
      active:
          json['active'] as int? ??
          (total is num ? total.toInt() : items.length),
      completed: json['completed'] as int? ?? 0,
      atRisk: json['atRisk'] as int? ?? 0,
      items: items,
    );
  }
}
