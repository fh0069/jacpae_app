import 'package:firebase_messaging/firebase_messaging.dart';

/// Thin wrapper over [FirebaseMessaging].
///
/// Exposes token retrieval, permission request, and token refresh stream.
/// Does NOT call [requestPermission] automatically — caller decides timing.
class PushService {
  final FirebaseMessaging _messaging;

  PushService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  /// Returns the current FCM registration token, or null if unavailable.
  Future<String?> getToken() => _messaging.getToken();

  /// Requests notification permissions from the OS.
  ///
  /// On Android 12 and below this always resolves to [AuthorizationStatus.authorized].
  /// On Android 13+ and iOS it shows the system permission dialog.
  ///
  /// The caller decides when to invoke this — it is NOT called automatically
  /// from [PushBootstrapProvider].
  Future<NotificationSettings> requestPermission() =>
      _messaging.requestPermission();

  /// Stream that emits a new token whenever FCM rotates the registration token.
  ///
  /// Subscribers must cancel their subscription when no longer needed.
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
