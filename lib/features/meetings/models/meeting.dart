class Meeting {
  const Meeting({
    required this.id,
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.location,
    required this.attendees,
    required this.status,
    this.projectName,
    this.customerName,
  });

  final String id;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final String location;
  final List<String> attendees;
  final String status;
  final String? projectName;
  final String? customerName;

  factory Meeting.fromJson(Map<String, dynamic> json) {
    final participants = json['participants'];
    final attendees = <String>[];
    if (participants is List) {
      for (final item in participants) {
        if (item is Map) {
          final name = item['name']?.toString().trim() ?? '';
          if (name.isNotEmpty) attendees.add(name);
        } else if (item != null) {
          attendees.add(item.toString());
        }
      }
    } else if (json['attendees'] is List) {
      attendees.addAll((json['attendees'] as List).map((e) => e.toString()));
    }

    final project = json['project'];
    final customer = json['customer'];
    return Meeting(
      id: (json['id'] ?? json['_id'] ?? json['meetingId'] ?? '').toString(),
      title: json['title'] as String? ?? '',
      startAt: _date(json['startTime'] ?? json['startAt']),
      endAt: _date(json['endTime'] ?? json['endAt']),
      location: json['location'] as String? ?? '',
      attendees: attendees,
      status: json['status'] as String? ?? '',
      projectName: project is Map
          ? project['name']?.toString()
          : json['projectName'] as String?,
      customerName: customer is Map
          ? customer['name']?.toString()
          : json['customerName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startTime': startAt.toIso8601String(),
    'endTime': endAt.toIso8601String(),
    'location': location,
    'attendees': attendees,
    'status': status,
    if (projectName != null) 'projectName': projectName,
    if (customerName != null) 'customerName': customerName,
  };

  static DateTime _date(Object? value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
