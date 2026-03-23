import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/providers/auth_provider.dart';
import 'push_repository.dart';
import 'push_service.dart';

/// Infrastructure provider that registers the FCM device token with the backend.
///
/// Lifecycle:
/// - Created once at app startup via eager watch in [App].
/// - Registers the token when [authStateProvider] transitions to AAL2.
/// - Handles cold-start: if the session is already AAL2 on first creation,
///   registration is triggered immediately.
/// - Reacts to FCM token rotation via [PushService.onTokenRefresh] —
///   one subscription, cancelled on provider dispose.
///
/// Errors are silent to the user; traceable in debug mode only.
/// Permission request is NOT called here — see [PushService.requestPermission].
final pushBootstrapProvider = Provider<void>((ref) {
  final repository = PushRepository.create(
    apiBaseUrl: dotenv.env['API_BASE_URL'] ?? '',
  );
  final service = PushService();

  // Subscribe to FCM token rotation.
  // Cancelled via ref.onDispose — no duplicate subscriptions on rebuild.
  final tokenRefreshSub = service.onTokenRefresh.listen((newToken) {
    if (ref.read(authStateProvider).isAAL2) {
      _register(service: service, repository: repository, forcedToken: newToken);
    }
  });
  ref.onDispose(tokenRefreshSub.cancel);

  // React to AAL2 transitions (login, MFA completion).
  ref.listen<AuthStateModel>(authStateProvider, (prev, next) {
    final wasAAL2 = prev?.isAAL2 ?? false;
    if (!wasAAL2 && next.isAAL2) {
      _register(service: service, repository: repository);
    }
  });

  // Handle cold-start: session already active when provider is first created.
  if (ref.read(authStateProvider).isAAL2) {
    _register(service: service, repository: repository);
  }
});

/// Fire-and-forget registration. Silent on error, traceable in debug.
///
/// [forcedToken] is used when FCM rotation provides the token directly,
/// skipping the [PushService.getToken] call.
Future<void> _register({
  required PushService service,
  required PushRepository repository,
  String? forcedToken,
}) async {
  try {
    final token = forcedToken ?? await service.getToken();
    if (token == null) {
      if (kDebugMode) debugPrint('[Push] No FCM token available, skipping registration');
      return;
    }
    await repository.registerDevice(fcmToken: token);
    if (kDebugMode) debugPrint('[Push] Device registered successfully');
  } catch (e) {
    // Silent — push registration failure must never interrupt app flow.
    if (kDebugMode) debugPrint('[Push] Registration failed: $e');
  }
}
