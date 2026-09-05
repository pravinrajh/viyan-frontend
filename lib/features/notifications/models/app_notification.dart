class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.actionUrl,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    title: title,
    body: body,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
    actionUrl: actionUrl,
  );

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'] as String?;
    return AppNotification(
      id: (json['id'] ?? json['_id'] ?? json['notificationId'] ?? '')
          .toString(),
      title: json['title'] as String? ?? '',
      body: json['message'] as String? ?? json['body'] as String? ?? '',
      createdAt: createdAt != null
          ? DateTime.tryParse(createdAt) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] == true,
      actionUrl: json['actionUrl'] as String?,
    );
  }
}
