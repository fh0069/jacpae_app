import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'biometric_service.dart';

/// Timeout duration before requiring biometric unlock.
const _lockTimeout = Duration(minutes: 10);

/// State for the app lock feature.
class AppLockState {
  final bool requiresUnlock;

  const AppLockState({required this.requiresUnlock});

  factory AppLockState.initial() =>
      const AppLockState(requiresUnlock: false);
}

/// Controls app lock lifecycle: tracks background time and sets
/// [requiresUnlock] when the app returns after >= 10 minutes.
///
/// If biometrics are not available, [requiresUnlock] stays false (no lock).
class AppLockController extends StateNotifier<AppLockState>
    with WidgetsBindingObserver {
  final BiometricService _biometricService;
  DateTime? _lastBackgroundAt;

  AppLockController(this._biometricService) : super(AppLockState.initial()) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      _onAppResumed();
    }
  }

  void _onAppPaused() {
    _lastBackgroundAt = DateTime.now();
  }

  Future<void> _onAppResumed() async {
    if (_lastBackgroundAt == null) return;

    final elapsed = DateTime.now().difference(_lastBackgroundAt!);
    if (elapsed < _lockTimeout) return;

    // Only lock if biometrics are available
    final available = await _biometricService.isBiometricsAvailable();
    if (!available) return;

    state = const AppLockState(requiresUnlock: true);
  }

  /// Called after successful biometric authentication to dismiss the lock.
  void unlock() {
    _lastBackgroundAt = null;
    state = const AppLockState(requiresUnlock: false);
  }
}

// --------------- Riverpod providers ---------------

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final appLockControllerProvider =
    StateNotifierProvider<AppLockController, AppLockState>((ref) {
  final biometricService = ref.watch(biometricServiceProvider);
  return AppLockController(biometricService);
});
