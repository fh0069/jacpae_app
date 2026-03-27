import 'models/profile_model.dart';
import 'profile_datasource.dart';

/// Repository for customer profile preferences.
///
/// Delegates all Supabase access to [ProfileDatasource].
class ProfileRepository {
  final ProfileDatasource _datasource;

  ProfileRepository({required ProfileDatasource datasource})
      : _datasource = datasource;

  /// Fetches the authenticated user's profile.
  Future<ProfileModel> getProfile() => _datasource.fetchProfile();

  /// Updates all preference fields for the authenticated user.
  Future<void> updateProfile(ProfileModel profile) =>
      _datasource.updateProfile(profile.toUpdateMap());

  /// Updates a single preference field for the authenticated user.
  Future<void> updateField(String field, dynamic value) =>
      _datasource.updateProfile({field: value});
}
