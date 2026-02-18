/// Notification model matching the backend contract.
///
/// Fields: id, type, title, body, created_at, is_read, data.
/// [fromJson] is null-safe and tolerant with missing/malformed values.
class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic> data;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    required this.data,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'giro',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: _parseDateTime(json['created_at']),
      isRead: json['is_read'] as bool? ?? false,
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : <String, dynamic>{},
    );
  }

  /// Returns a copy with [isRead] toggled.
  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      data: data,
    );
  }

  /// Parses ISO datetime string; falls back to [DateTime.now] on failure.
  static DateTime _parseDateTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
