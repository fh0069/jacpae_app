/// Authentication service placeholder
/// TODO PHASE 2: Implement real authentication with Supabase
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  /// Simulate login - NO REAL AUTHENTICATION
  /// TODO PHASE 2: Implement real login with Supabase
  Future<bool> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Always return success in Phase 1 (UI only)
    return true;
  }

  /// Simulate logout - NO REAL LOGIC
  /// TODO PHASE 2: Implement real logout with Supabase
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // No actual logout logic in Phase 1
  }

  /// Check if user is authenticated - ALWAYS FALSE IN PHASE 1
  /// TODO PHASE 2: Implement real session check with Supabase
  Future<bool> isAuthenticated() async {
    // Always false in Phase 1 - user must login each time
    return false;
  }

  /// Get current user - NOT IMPLEMENTED
  /// TODO PHASE 2: Implement real user retrieval from Supabase
  Future<Map<String, dynamic>?> getCurrentUser() async {
    throw UnimplementedError('TODO PHASE 2: Implement Supabase user retrieval');
  }

  /// Register user - NOT IMPLEMENTED
  /// TODO PHASE 2: Implement real registration with Supabase
  Future<bool> register(String email, String password, String name) async {
    throw UnimplementedError('TODO PHASE 2: Implement Supabase registration');
  }

  /// Reset password - NOT IMPLEMENTED
  /// TODO PHASE 2: Implement real password reset with Supabase
  Future<void> resetPassword(String email) async {
    throw UnimplementedError('TODO PHASE 2: Implement Supabase password reset');
  }
}
