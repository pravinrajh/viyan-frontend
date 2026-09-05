class FinanceSummary {
  const FinanceSummary({
    required this.cashOnHand,
    required this.receivables,
    required this.payables,
    required this.weeklyRequirement,
    required this.expectedCollections,
    required this.commentary,
    this.plannedPayments = const [],
  });

  final double cashOnHand;
  final double receivables;
  final double payables;
  final double weeklyRequirement;
  final double expectedCollections;
  final String commentary;
  final List<String> plannedPayments;

  double get availableBalance => cashOnHand;

  factory FinanceSummary.fromJson(Map<String, dynamic> json) {
    return FinanceSummary(
      cashOnHand:
          (json['cashOnHand'] as num? ?? json['availableBalance'] as num)
              .toDouble(),
      receivables: (json['receivables'] as num?)?.toDouble() ?? 0,
      payables: (json['payables'] as num?)?.toDouble() ?? 0,
      weeklyRequirement: (json['weeklyRequirement'] as num).toDouble(),
      expectedCollections:
          (json['expectedCollections'] as num?)?.toDouble() ?? 0,
      commentary: json['commentary'] as String? ?? '',
      plannedPayments:
          (json['plannedPayments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'cashOnHand': cashOnHand,
    'receivables': receivables,
    'payables': payables,
    'weeklyRequirement': weeklyRequirement,
    'expectedCollections': expectedCollections,
    'commentary': commentary,
    'plannedPayments': plannedPayments,
  };
}
