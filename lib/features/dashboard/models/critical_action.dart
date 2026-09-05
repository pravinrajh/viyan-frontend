enum CriticalPriority { critical, high, medium, low }

extension CriticalPriorityX on CriticalPriority {
  String get label => switch (this) {
    CriticalPriority.critical => 'Critical',
    CriticalPriority.high => 'High',
    CriticalPriority.medium => 'Medium',
    CriticalPriority.low => 'Low',
  };

  String get apiValue => name;

  static CriticalPriority fromApi(String value) {
    return CriticalPriority.values.firstWhere(
      (item) => item.name == value.toLowerCase(),
      orElse: () => CriticalPriority.medium,
    );
  }
}

/// MD attention item for the executive dashboard.
class CriticalAction {
  const CriticalAction({
    required this.id,
    required this.title,
    required this.priority,
    this.subtitle,
  });

  final String id;
  final String title;
  final CriticalPriority priority;
  final String? subtitle;

  factory CriticalAction.fromJson(Map<String, dynamic> json) {
    return CriticalAction(
      id:
          json['id'] as String? ??
          json['sourceId'] as String? ??
          json['title'] as String? ??
          '',
      title: json['title'] as String? ?? '',
      priority: CriticalPriorityX.fromApi(
        json['priority'] as String? ?? 'medium',
      ),
      subtitle: json['subtitle'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'priority': priority.apiValue,
    'subtitle': subtitle,
  };
}
