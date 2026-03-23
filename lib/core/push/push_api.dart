import '../network/api_client.dart';

/// Data source for device push token registration.
///
/// Calls [POST /devices/register] on the backend.
/// JWT is injected by [PushRepository] — this class is auth-agnostic.
class PushApi {
  final ApiClient _apiClient;

  PushApi(this._apiClient);

  /// Registers or reactivates a device token on the backend.
  ///
  /// [token] - Bearer JWT from the active Supabase session
  /// [fcmToken] - FCM registration token for this device
  /// [platform] - 'android' or 'ios'
  Future<void> registerDevice({
    required String token,
    required String fcmToken,
    required String platform,
  }) async {
    await _apiClient.post(
      '/devices/register',
      token: token,
      body: {
        'device_token': fcmToken,
        'platform': platform,
      },
    );
  }
}
