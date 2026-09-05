class ProjectSummary {
  const ProjectSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.risk,
    required this.progress,
    required this.owner,
    required this.location,
    required this.customerName,
    required this.contractValue,
    required this.budget,
    required this.actualExpense,
    required this.dueDate,
    this.projectId = '',
    this.code = '',
    this.description = '',
    this.pendingTasks = 0,
    this.pendingPayments = 0,
  });

  final String id;
  final String projectId;
  final String name;
  final String code;
  final String description;
  final String type;
  final String status;
  final String risk;
  final double progress;
  final String owner;
  final String location;
  final String customerName;
  final double contractValue;
  final double budget;
  final double actualExpense;
  final DateTime dueDate;
  final int pendingTasks;
  final int pendingPayments;

  /// Linear progress 0–1. API sends 0–100; older mock data used 0–1.
  double get progressFraction {
    if (progress <= 1) return progress.clamp(0, 1);
    return (progress / 100).clamp(0, 1);
  }

  int get progressPercent => (progressFraction * 100).round();

  factory ProjectSummary.fromJson(Map<String, dynamic> json) {
    final budget = _number(json['budget']);
    final actualExpense = _number(json['actualExpense']);
    final status = _string(json['status']);
    final projectType = _string(json['projectType'], json['type']);
    final manager = json['manager'];
    var owner = _string(json['owner'], json['projectManager']);
    if (owner.isEmpty && manager is Map) {
      owner = _string(manager['name']);
    }
    final customer = json['customer'];
    var customerName = _string(json['customerName']);
    if (customerName.isEmpty && customer is Map) {
      customerName = _string(customer['name'], customer['companyName']);
    }

    return ProjectSummary(
      id: _id(json),
      projectId: _string(json['projectId']),
      name: _string(json['name']),
      code: _string(json['code']),
      description: _string(json['description']),
      type: projectType,
      status: status,
      risk: _string(json['risk']).isNotEmpty
          ? _string(json['risk'])
          : _riskFrom(status, budget, actualExpense),
      progress: _number(json['progress']),
      owner: owner,
      location: _string(json['location']),
      customerName: customerName,
      contractValue: json['contractValue'] == null
          ? budget
          : _number(json['contractValue']),
      budget: budget,
      actualExpense: actualExpense,
      dueDate: _date(json['expectedEndDate'] ?? json['dueDate']),
      pendingTasks: _number(json['pendingTasks']).round(),
      pendingPayments: _number(json['pendingPayments']).round(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'name': name,
    'code': code,
    'description': description,
    'projectType': type,
    'type': type,
    'status': status,
    'risk': risk,
    'progress': progress,
    'owner': owner,
    'location': location,
    'customerName': customerName,
    'contractValue': contractValue,
    'budget': budget,
    'actualExpense': actualExpense,
    'expectedEndDate': dueDate.toIso8601String(),
    'pendingTasks': pendingTasks,
    'pendingPayments': pendingPayments,
  };

  static String _riskFrom(String status, double budget, double actualExpense) {
    if (status == 'AT_RISK' || (budget > 0 && actualExpense > budget)) {
      return 'high';
    }
    if (budget > 0 && (actualExpense * 100 / budget) >= 80) {
      return 'medium';
    }
    return 'low';
  }

  static String _id(Map<String, dynamic> json) {
    final raw = json['id'] ?? json['_id'];
    if (raw is String && raw.isNotEmpty) return raw;
    if (raw is Map) {
      final oid = raw[r'$oid'] ?? raw['oid'] ?? raw['id'];
      if (oid != null) return oid.toString();
    }
    return raw?.toString() ?? '';
  }

  static String _string(Object? value, [Object? fallback]) {
    if (value is String && value.isNotEmpty) return value;
    if (fallback is String && fallback.isNotEmpty) return fallback;
    return '';
  }

  static double _number(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _date(Object? value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
