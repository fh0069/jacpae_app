import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import 'auth_notifier.dart';

/// Auth state model
class AuthStateModel {
  final bool isAuthenticated;
  final bool isAAL2;
  final User? user;
  final Session? session;

  const AuthStateModel({
    required this.isAuthenticated,
    required this.isAAL2,
    this.user,
    this.session,
  });

  factory AuthStateModel.initial() {
    return const AuthStateModel(
      isAuthenticated: false,
      isAAL2: false,
      user: null,
      session: null,
    );
  }

  AuthStateModel copyWith({
    bool? isAuthenticated,
    bool? isAAL2,
    User? user,
    Session? session,
  }) {
    return AuthStateModel(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isAAL2: isAAL2 ?? this.isAAL2,
      user: user ?? this.user,
      session: session ?? this.session,
    );
  }
}

/// Auth state notifier
class AuthStateNotifier extends StateNotifier<AuthStateModel> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(AuthStateModel.initial()) {
    _init();
  }

  void _init() {
    // Initialize with current session
    _updateState();

    // Listen to auth state changes
    _authService.authStateChanges.listen((authState) {
      _updateState();
    });
  }

  void _updateState() {
    final session = _authService.currentSession;
    final user = _authService.currentUser;
    final isAuthenticated = _authService.isAuthenticated;
    final isAAL2 = _authService.isAAL2;

    state = AuthStateModel(
      isAuthenticated: isAuthenticated,
      isAAL2: isAAL2,
      user: user,
      session: session,
    );
  }

  /// Refresh state manually
  void refresh() {
    _updateState();
  }
}

/// Provider for SupabaseClient
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthService(supabase);
});

/// Provider for AuthStateNotifier
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthStateModel>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService);
});

/// Helper provider to get just the auth state stream
final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for router refresh notifier (ChangeNotifier-based)
/// This is used by GoRouter's refreshListenable to rebuild routes without rebuilding the entire router
final routerRefreshNotifierProvider = Provider<AuthRouterNotifier>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthRouterNotifier(supabase);
});
