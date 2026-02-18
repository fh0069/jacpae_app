import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../api/notifications_api.dart';
import '../models/notification_item.dart';

/// Repository for managing notification data.
///
/// Handles:
/// - Getting access token from Supabase session
/// - Calling NotificationsApi with proper authorization
/// - Pagination via limit/offset
class NotificationsRepository {
  final NotificationsApi _notificationsApi;
  final SupabaseClient _supabaseClient;

  NotificationsRepository({
    required NotificationsApi notificationsApi,
    required SupabaseClient supabaseClient,
  })  : _notificationsApi = notificationsApi,
        _supabaseClient = supabaseClient;

  /// Factory constructor that creates repository with default dependencies.
  factory NotificationsRepository.create({required String apiBaseUrl}) {
    final apiClient = ApiClient(baseUrl: apiBaseUrl);
    final notificationsApi = NotificationsApi(apiClient);
    final supabaseClient = Supabase.instance.client;

    return NotificationsRepository(
      notificationsApi: notificationsApi,
      supabaseClient: supabaseClient,
    );
  }

  /// Gets the current access token from Supabase session.
  ///
  /// Throws [UnauthorizedException] if no session exists.
  String _getAccessToken() {
    final session = _supabaseClient.auth.currentSession;
    if (session == null) {
      throw const UnauthorizedException(
        message: 'No hay sesión activa. Vuelve a iniciar sesión.',
      );
    }
    return session.accessToken;
  }

  /// Fetches notifications with pagination.
  ///
  /// Returns a [NotificationsResult] with items and pagination info.
  Future<NotificationsResult> fetchNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    final token = _getAccessToken();

    final notifications = await _notificationsApi.getNotifications(
      token: token,
      limit: limit,
      offset: offset,
    );

    final hasMore = notifications.length >= limit;

    return NotificationsResult(
      items: notifications,
      hasMore: hasMore,
      nextOffset: offset + notifications.length,
    );
  }

  /// Marks a notification as read.
  ///
  /// Throws [ApiException] on error.
  Future<void> markAsRead(String notificationId) async {
    final token = _getAccessToken();

    await _notificationsApi.markAsRead(
      token: token,
      notificationId: notificationId,
    );
  }
}

/// Result class for paginated notification fetching.
class NotificationsResult {
  final List<NotificationItem> items;
  final bool hasMore;
  final int nextOffset;

  const NotificationsResult({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
  });
}
