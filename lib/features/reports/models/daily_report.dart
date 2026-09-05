class DailyReport {
  const DailyReport({
    required this.id,
    required this.title,
    required this.summary,
    required this.generatedAt,
  });

  final String id;
  final String title;
  final String summary;
  final DateTime generatedAt;

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    final date = json['date']?.toString() ?? '';
    final attention = json['attention'];
    final buffer = StringBuffer(json['summary'] as String? ?? '');
    if (attention is List && attention.isNotEmpty) {
      buffer.writeln();
      for (final item in attention) {
        if (item is Map && item['title'] != null) {
          buffer.writeln('• ${item['title']}');
        }
      }
    }
    return DailyReport(
      id: date.isEmpty ? 'morning-report' : date,
      title: date.isEmpty ? 'Morning report' : 'Morning report · $date',
      summary: buffer.toString().trim(),
      generatedAt: DateTime.now(),
    );
  }
}
