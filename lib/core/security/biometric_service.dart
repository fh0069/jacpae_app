import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Encapsulates biometric authentication via [LocalAuthentication].
/// Every public method catches exceptions and returns false — never crashes the app.
class BiometricService {
  final LocalAuthentication _auth;

  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  /// Returns true only when the device supports biometrics,
  /// the plugin can query them, AND at least one biometric is enrolled.
  Future<bool> isBiometricsAvailable() async {
    try {
      final deviceSupported = await _auth.isDeviceSupported();
      if (!deviceSupported) return false;

      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;

      // Verify at least one biometric is actually enrolled
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  /// Prompts the user for biometric authentication.
  /// Returns true on success, false on failure or cancellation.
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
