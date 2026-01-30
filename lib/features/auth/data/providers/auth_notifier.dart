import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Notifier for router refresh on auth state changes
class AuthRouterNotifier extends ChangeNotifier {
  final SupabaseClient _supabase;

  AuthRouterNotifier(this._supabase) {
    _supabase.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }

  bool get isAuthenticated => _supabase.auth.currentSession != null;

  bool get isAAL2 {
    try {
      final level = _supabase.auth.mfa.getAuthenticatorAssuranceLevel();
      return level.currentLevel == AuthenticatorAssuranceLevels.aal2;
    } catch (e) {
      return false;
    }
  }
}
