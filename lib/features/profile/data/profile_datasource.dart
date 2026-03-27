import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/profile_model.dart';

/// Direct Supabase datasource for `public.customer_profiles`.
///
/// Reads and updates the authenticated user's notification preferences.
/// RLS enforces row-level access — no user_id is ever trusted from client input.
class ProfileDatasource {
  final SupabaseClient _client;

  ProfileDatasource({required SupabaseClient client}) : _client = client;

  /// Returns the current authenticated user's id.
  ///
  /// Throws [StateError] if no session is active.
  String _currentUserId() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user. Cannot access customer_profiles.');
    }
    return user.id;
  }

  /// Fetches the profile row for the authenticated user.
  ///
  /// Throws [StateError] if no session is active.
  /// Throws [PostgrestException] on Supabase error or missing row.
  Future<ProfileModel> fetchProfile() async {
    final userId = _currentUserId();
    // DIAGNÓSTICO TEMPORAL — eliminar tras validación
    debugPrint('[ProfileDatasource] fetchProfile() userId=$userId');
    final data = await _client
        .from('customer_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    debugPrint('[ProfileDatasource] fetchProfile() raw=$data');
    if (data == null) {
      throw StateError('No profile row found for user_id=$userId');
    }
    return ProfileModel.fromJson(data);
  }

  /// Updates the profile row for the authenticated user.
  ///
  /// [data] must only contain valid `customer_profiles` column names.
  /// Throws [StateError] if no session is active.
  /// Throws [PostgrestException] on Supabase error.
  Future<void> updateProfile(Map<String, dynamic> data) async {
    final userId = _currentUserId();
    await _client
        .from('customer_profiles')
        .update(data)
        .eq('user_id', userId);
  }
}
