import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'biometric_service.dart';

/// Timeout duration before requiring biometric unlock.
const _lockTimeout = Duration(minutes: 10);

/// State for the app lock feature.
class AppLockState {
  final bool requiresUnlock;

  const AppLockState({required this.requiresUnlock});

  factory AppLockState.initial() => const AppLockState(requiresUnlock: false);
}

/// Controls app lock lifecycle: tracks background time and sets
/// [requiresUnlock] when the app returns after >= 10 minutes.
///
/// If biometrics are not available, [requiresUnlock] stays false (no lock).
class AppLockController extends StateNotifier<AppLockState>
    with WidgetsBindingObserver {
  final BiometricService _biometricService;
  DateTime? _lastBackgroundAt;

  /// Last lifecycle state received — used to distinguish "leaving" from
  /// "returning" when [AppLifecycleState.inactive] arrives.
  AppLifecycleState? _lastLifecycle;

  /// True while the app is considered to be in the background.
  /// Prevents re-marking [_lastBackgroundAt] if multiple background events
  /// arrive in a row (paused → hidden, etc.).
  bool _inBackground = false;

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
    if (kDebugMode) {
      debugPrint(
          '[LOCK] lifecycle=$state inBackground=$_inBackground last=$_lastLifecycle');
    }

    switch (state) {
      case AppLifecycleState.resumed:
        _inBackground = false;
        _onAppResumed();
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        // Only mark the first background event; ignore subsequent ones
        // (e.g. paused → hidden on some Android versions).
        if (!_inBackground) {
          _markBackground(state);
          _inBackground = true;
        }
        break;

      case AppLifecycleState.inactive:
        // inactive fires in BOTH directions:
        //   leaving:   resumed → inactive → paused → hidden
        //   returning: hidden  → inactive → resumed
        //
        // Treat as background only when clearly leaving the app
        // (previous state was resumed or this is the very first event).
        final leavingApp = !_inBackground &&
            (_lastLifecycle == null ||
                _lastLifecycle == AppLifecycleState.resumed);
        if (leavingApp) {
          _markBackground(state);
          _inBackground = true;
          if (kDebugMode) {
            debugPrint('[LOCK] inactive treated as BACKGROUND (leaving)');
          }
        } else {
          if (kDebugMode) {
            debugPrint('[LOCK] inactive ignored (resuming sequence)');
          }
        }
        break;
    }

    _lastLifecycle = state;
  }

  /// Debounce window to avoid overwriting [_lastBackgroundAt] when
  /// Android fires inactive → paused back-to-back.
  static const _debounce = Duration(seconds: 2);

  static const _kLastBgKey = 'app_lock_last_background_epoch_ms';

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
    _persistBackgroundTime(now);
    if (kDebugMode) {
      debugPrint('[LOCK] lifecycle=$state -> mark background');
    }
  }

  Future<void> _persistBackgroundTime(DateTime at) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastBgKey, at.millisecondsSinceEpoch);
  }

  Future<void> _onAppResumed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEpoch = prefs.getInt(_kLastBgKey);

      final DateTime? referenceTime;
      final String source;
      if (savedEpoch != null) {
        referenceTime = DateTime.fromMillisecondsSinceEpoch(savedEpoch);
        source = 'persisted';
      } else {
        referenceTime = _lastBackgroundAt;
        source = 'memory';
      }

      if (referenceTime == null) return;

      final elapsed = DateTime.now().difference(referenceTime);
      final requires = elapsed >= _lockTimeout;

      if (kDebugMode) {
        debugPrint(
            '[LOCK] lifecycle=resumed source=$source delta=$elapsed requiresUnlock=$requires');
      }

      // ✅ If we do NOT require unlock, clear persisted epoch to avoid stale values.
      if (!requires) {
        await _clearPersistedBackgroundTime();
        return;
      }

      // Only lock if biometrics are available
      final available = await _biometricService.isBiometricsAvailable();
      if (!available) return;

      state = const AppLockState(requiresUnlock: true);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[LOCK] resumed: error=$e\n$st');
      }
    }
  }

  /// Called after successful biometric authentication to dismiss the lock.
  void unlock() {
    _lastBackgroundAt = null;
    _clearPersistedBackgroundTime();
    state = const AppLockState(requiresUnlock: false);
  }

  Future<void> _clearPersistedBackgroundTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastBgKey);
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
