import '../../../../core/network/api_client.dart';
import '../models/notification_item.dart';

/// API layer for notifications endpoints
///
/// Handles HTTP calls to:
/// - GET  /notifications?limit=&offset=
/// - PATCH /notifications/{id}/read
class NotificationsApi {
  final ApiClient _apiClient;

  NotificationsApi(this._apiClient);

  /// Fetches notifications from the API (newest first).
  ///
  /// Returns a list of [NotificationItem].
  /// Throws [ApiException] on error.
  Future<List<NotificationItem>> getNotifications({
    required String token,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _apiClient.get(
      '/notifications',
      token: token,
      queryParams: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
    );

    final List<dynamic> jsonList = response as List<dynamic>;
    return jsonList
        .map((json) => NotificationItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Marks a notification as read.
  ///
  /// Backend returns 204 No Content on success.
  /// Throws [ApiException] on error.
  Future<void> markAsRead({
    required String token,
    required String notificationId,
  }) async {
    await _apiClient.patch(
      '/notifications/$notificationId/read',
      token: token,
    );
  }
}
