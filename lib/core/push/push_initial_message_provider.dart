import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notificaciones/presentation/providers/notifications_provider.dart';

/// One-shot provider for cold-start push handling.
///
/// Checks [FirebaseMessaging.instance.getInitialMessage] exactly once at
/// app startup. If the app was launched by tapping a push notification from
/// a terminated state, triggers a silent notifications refresh so the UI
/// reflects the latest data without using the payload as a data source.
///
/// Eagerly initialised in [App.build] via ref.watch.
final pushInitialMessageProvider = Provider<void>((ref) {
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      ref.read(notificationsControllerProvider.notifier).silentRefresh();
    }
  });
});
