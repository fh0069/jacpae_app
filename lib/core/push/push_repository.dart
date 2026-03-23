import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/api_client.dart';
import '../network/api_exception.dart';
import 'push_api.dart';

/// Repository for device push token registration.
///
/// Handles:
/// - Getting the access token from the active Supabase session
/// - Resolving the platform string ('android' | 'ios')
/// - Calling [PushApi] with proper authorization
class PushRepository {
  final PushApi _pushApi;
  final SupabaseClient _supabaseClient;

  PushRepository({
    required PushApi pushApi,
    required SupabaseClient supabaseClient,
  })  : _pushApi = pushApi,
        _supabaseClient = supabaseClient;

  /// Factory constructor that wires default dependencies.
  factory PushRepository.create({required String apiBaseUrl}) {
    final apiClient = ApiClient(baseUrl: apiBaseUrl);
    final pushApi = PushApi(apiClient);
    final supabaseClient = Supabase.instance.client;
    return PushRepository(pushApi: pushApi, supabaseClient: supabaseClient);
  }

  /// Returns the JWT from the active Supabase session.
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

  String get _platform => Platform.isIOS ? 'ios' : 'android';

  /// Registers the FCM token for this device against the backend.
  ///
  /// Idempotent: backend upserts on UNIQUE(device_token).
  Future<void> registerDevice({required String fcmToken}) async {
    final token = _getAccessToken();
    await _pushApi.registerDevice(
      token: token,
      fcmToken: fcmToken,
      platform: _platform,
    );
  }
}
