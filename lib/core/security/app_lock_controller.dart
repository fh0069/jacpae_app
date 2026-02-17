import 'package:flutter/foundation.dart';
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
    // Treat paused, inactive and detached as background states
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _markBackground(state);
    } else if (state == AppLifecycleState.resumed) {
      _onAppResumed();
    }
  }

  /// Debounce window to avoid overwriting [_lastBackgroundAt] when
  /// Android fires inactive → paused back-to-back.
  static const _debounce = Duration(seconds: 2);

  void _markBackground(AppLifecycleState state) {
    final now = DateTime.now();
    if (_lastBackgroundAt != null &&
        now.difference(_lastBackgroundAt!) < _debounce) {
      if (kDebugMode) {
        debugPrint('[LOCK] lifecycle=$state -> skipped (debounce)');
      }
      return;
    }
    _lastBackgroundAt = now;
    if (kDebugMode) {
      debugPrint('[LOCK] lifecycle=$state -> mark background');
    }
  }

  Future<void> _onAppResumed() async {
    if (_lastBackgroundAt == null) return;

    final elapsed = DateTime.now().difference(_lastBackgroundAt!);
    final requires = elapsed >= _lockTimeout;

    if (kDebugMode) {
      debugPrint('[LOCK] lifecycle=resumed delta=$elapsed requiresUnlock=$requires');
    }

    if (!requires) return;

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
