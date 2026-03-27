import '../../../../core/network/api_client.dart';

/// Remote datasource for device token registration.
///
/// Calls [POST /devices/register] on the backend.
/// JWT is injected by the repository — this class is auth-agnostic.
class PushDeviceDatasource {
  final ApiClient _apiClient;

  PushDeviceDatasource(this._apiClient);

  Future<void> registerDevice({
    required String jwtToken,
    required String deviceToken,
    required String platform,
  }) async {
    await _apiClient.post(
      '/devices/register',
      token: jwtToken,
      body: {
        'device_token': deviceToken,
        'platform': platform,
      },
    );
  }
}
