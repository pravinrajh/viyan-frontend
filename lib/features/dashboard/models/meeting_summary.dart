/// Compact meeting row for the executive dashboard.
class MeetingSummary {
  const MeetingSummary({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.participants,
    this.location,
  });

  final String id;
  final String title;
  final String timeLabel;
  final List<String> participants;
  final String? location;

  factory MeetingSummary.fromJson(Map<String, dynamic> json) {
    return MeetingSummary(
      id: json['id'] as String? ?? json['meetingId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      timeLabel: json['timeLabel'] as String? ?? '',
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['attendees'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'timeLabel': timeLabel,
    'participants': participants,
    'location': location,
  };
}

class MeetingOverview {
  const MeetingOverview({
    required this.today,
    required this.upcoming,
    this.items = const [],
  });

  final int today;
  final int upcoming;
  final List<MeetingSummary> items;

  factory MeetingOverview.fromJson(Map<String, dynamic> json) {
    return MeetingOverview(
      today: json['today'] as int? ?? 0,
      upcoming: json['upcoming'] as int? ?? 0,
      items: ((json['items'] as List<dynamic>?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(MeetingSummary.fromJson)
          .toList(),
    );
  }
}
