import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/api_client.dart';
import '../datasources/push_device_datasource.dart';

/// Repository for device push token registration.
///
/// Resolves platform, injects JWT from active Supabase session,
/// and delegates HTTP call to [PushDeviceDatasource].
class PushDeviceRepository {
  final PushDeviceDatasource _datasource;
  final SupabaseClient _supabaseClient;

  PushDeviceRepository({
    required PushDeviceDatasource datasource,
    required SupabaseClient supabaseClient,
  })  : _datasource = datasource,
        _supabaseClient = supabaseClient;

  factory PushDeviceRepository.create({required String apiBaseUrl}) {
    return PushDeviceRepository(
      datasource: PushDeviceDatasource(ApiClient(baseUrl: apiBaseUrl)),
      supabaseClient: Supabase.instance.client,
    );
  }

  String get _platform => Platform.isIOS ? 'ios' : 'android';

  /// Registers the FCM token for this device against the backend.
  ///
  /// No-ops silently if there is no active session.
  Future<void> registerDevice({required String fcmToken}) async {
    final session = _supabaseClient.auth.currentSession;
    if (session == null) return;
    await _datasource.registerDevice(
      jwtToken: session.accessToken,
      deviceToken: fcmToken,
      platform: _platform,
    );
  }
}
