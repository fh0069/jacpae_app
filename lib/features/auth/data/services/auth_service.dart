import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication service with Supabase
/// Handles email/password authentication and MFA TOTP
class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  /// Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Check if user is authenticated
  bool get isAuthenticated => currentSession != null;

  /// Check if session is at AAL2 (MFA verified)
  bool get isAAL2 {
    try {
      final level = _supabase.auth.mfa.getAuthenticatorAssuranceLevel();
      return level.currentLevel == AuthenticatorAssuranceLevels.aal2;
    } catch (e) {
      return false;
    }
  }

  /// Sign in with email and password
  /// Returns session if successful
  /// Throws AuthException on failure
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Error al iniciar sesión: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Error al cerrar sesión: $e');
    }
  }

  /// Get list of MFA factors for current user
  Future<AuthMFAListFactorsResponse> getMFAFactors() async {
    try {
      final factors = await _supabase.auth.mfa.listFactors();
      return factors;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Error al obtener factores MFA: $e');
    }
  }

  /// Check if user has TOTP factor enrolled
  Future<bool> hasTOTPFactor() async {
    final response = await getMFAFactors();
    return response.totp.isNotEmpty;
  }

  /// Enroll TOTP factor
  /// Returns AuthMFAEnrollResponse with QR code URI and secret
  Future<AuthMFAEnrollResponse> enrollTOTP({String? issuer}) async {
    try {
      final response = await _supabase.auth.mfa.enroll(
        factorType: FactorType.totp,
        issuer: issuer,
      );
      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Error al configurar TOTP: $e');
    }
  }

  /// Create MFA challenge for verification
  /// Returns challenge ID
  Future<String> createMFAChallenge({required String factorId}) async {
    try {
      final challenge = await _supabase.auth.mfa.challenge(
        factorId: factorId,
      );
      return challenge.id;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Error al crear desafío MFA: $e');
    }
  }

  /// Verify MFA challenge with TOTP code
  /// Returns updated session with AAL2
  Future<AuthMFAVerifyResponse> verifyMFA({
    required String factorId,
    required String challengeId,
    required String code,
  }) async {
    try {
      final response = await _supabase.auth.mfa.verify(
        factorId: factorId,
        challengeId: challengeId,
        code: code,
      );
      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Error al verificar código: $e');
    }
  }

  /// Challenge and verify MFA in one call (for already enrolled factors)
  Future<AuthMFAVerifyResponse> challengeAndVerifyMFA({
    required String factorId,
    required String code,
  }) async {
    try {
      // Create challenge first
      final challengeId = await createMFAChallenge(factorId: factorId);

      // Verify with code
      return await verifyMFA(
        factorId: factorId,
        challengeId: challengeId,
        code: code,
      );
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Error al verificar MFA: $e');
    }
  }

  /// Unenroll MFA factor (remove TOTP)
  Future<AuthMFAUnenrollResponse> unenrollMFA({required String factorId}) async {
    try {
      final response = await _supabase.auth.mfa.unenroll(factorId);
      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Error al remover factor MFA: $e');
    }
  }

  /// Get Assurance Level (AAL1 or AAL2)
  /// AAL1 = password only, AAL2 = password + MFA
  String? getAssuranceLevel() {
    try {
      final level = _supabase.auth.mfa.getAuthenticatorAssuranceLevel();
      return level.currentLevel?.name;
    } catch (e) {
      return null;
    }
  }
}
