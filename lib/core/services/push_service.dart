import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class PushService {
  /// Initialises FCM: requests permission and sets up the foreground listener.
  ///
  /// Device token registration is NOT done here — it is triggered by the
  /// auth-aware bootstrap provider once a valid session exists.
  static Future<void> init() async {
    await requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('[Push] Foreground message received');
      }
    });
  }

  /// Requests OS notification permissions.
  static Future<NotificationSettings> requestPermission() {
    return FirebaseMessaging.instance.requestPermission();
  }

  /// Returns the current FCM registration token, or null if unavailable.
  static Future<String?> getToken() {
    return FirebaseMessaging.instance.getToken();
  }

  /// Stream that emits a new token whenever FCM rotates the registration token.
  static Stream<String> get onTokenRefresh =>
      FirebaseMessaging.instance.onTokenRefresh;

  static String get platform => Platform.isIOS ? 'ios' : 'android';
}
