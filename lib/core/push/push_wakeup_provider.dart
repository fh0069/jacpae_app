import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notificaciones/presentation/providers/notifications_provider.dart';

/// Wires recurring FCM push events to a silent notifications refresh.
///
/// The push payload is intentionally ignored — it acts only as a wake-up
/// signal. [NotificationsController.silentRefresh] fetches the authoritative
/// list from the backend so the UI updates without any state duplication.
///
/// Handles:
/// - Foreground messages  → [FirebaseMessaging.onMessage]
/// - App opened from push → [FirebaseMessaging.onMessageOpenedApp]
///
/// The one-shot launch check ([FirebaseMessaging.instance.getInitialMessage])
/// is handled separately in [pushInitialMessageProvider] to guarantee it runs
/// exactly once at app startup.
///
/// Eagerly initialised in [App.build] via ref.watch.
/// Subscriptions are cancelled on provider dispose via ref.onDispose.
final pushWakeUpProvider = Provider<void>((ref) {
  void triggerRefresh() {
    ref.read(notificationsControllerProvider.notifier).silentRefresh();
  }

  // App is in foreground and a push arrives.
  final foregroundSub = FirebaseMessaging.onMessage.listen((_) {
    triggerRefresh();
  });
  ref.onDispose(foregroundSub.cancel);

  // App was in background; user taps the notification to bring it to front.
  final openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((_) {
    triggerRefresh();
  });
  ref.onDispose(openedAppSub.cancel);
});
