import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/profile_model.dart';
import '../../data/profile_datasource.dart';
import '../../data/profile_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class ProfileState {
  final ProfileModel? profile;
  final bool isLoading;
  final bool isSaving;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const ProfileState());

  /// Loads the authenticated user's profile from Supabase.
  Future<void> load() async {
    state = ProfileState(profile: state.profile, isLoading: true);
    try {
      final profile = await _repository.getProfile();
      if (!mounted) return;
      state = ProfileState(profile: profile);
    } catch (e) {
      if (!mounted) return;
      state = ProfileState(profile: state.profile);
    }
  }

  /// Updates the `avisar_reparto` preference.
  Future<void> updateAvisarReparto(bool value) async {
    if (state.profile == null) return;
    state = ProfileState(profile: state.profile, isSaving: true);
    try {
      await _repository.updateField('avisar_reparto', value);
      if (!mounted) return;
      state = ProfileState(
        profile: state.profile!.copyWith(avisarReparto: value),
      );
    } catch (e) {
      if (!mounted) return;
      state = ProfileState(profile: state.profile);
    }
  }

  /// Updates the `recibir_ofertas` preference.
  Future<void> updateRecibirOfertas(bool value) async {
    if (state.profile == null) return;
    state = ProfileState(profile: state.profile, isSaving: true);
    try {
      await _repository.updateField('recibir_ofertas', value);
      if (!mounted) return;
      state = ProfileState(
        profile: state.profile!.copyWith(recibirOfertas: value),
      );
    } catch (e) {
      if (!mounted) return;
      state = ProfileState(profile: state.profile);
    }
  }

  /// Updates the `dias_aviso_giro` preference.
  Future<void> updateDiasAvisoGiro(int value) async {
    if (state.profile == null) return;
    state = ProfileState(profile: state.profile, isSaving: true);
    try {
      await _repository.updateField('dias_aviso_giro', value);
      if (!mounted) return;
      state = ProfileState(
        profile: state.profile!.copyWith(diasAvisoGiro: value),
      );
    } catch (e) {
      if (!mounted) return;
      state = ProfileState(profile: state.profile);
    }
  }

  /// Updates the `avisar_giro` preference.
  Future<void> updateAvisarGiro(bool value) async {
    if (state.profile == null) return;
    state = ProfileState(profile: state.profile, isSaving: true);
    try {
      await _repository.updateField('avisar_giro', value);
      if (!mounted) return;
      state = ProfileState(
        profile: state.profile!.copyWith(avisarGiro: value),
      );
    } catch (e) {
      if (!mounted) return;
      state = ProfileState(profile: state.profile);
    }
  }

  /// Updates the `avisar_factura_emitida` preference.
  Future<void> updateAvisarFacturaEmitida(bool value) async {
    if (state.profile == null) return;
    state = ProfileState(profile: state.profile, isSaving: true);
    try {
      await _repository.updateField('avisar_factura_emitida', value);
      if (!mounted) return;
      state = ProfileState(
        profile: state.profile!.copyWith(avisarFacturaEmitida: value),
      );
    } catch (e) {
      if (!mounted) return;
      state = ProfileState(profile: state.profile);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final datasource = ProfileDatasource(
    client: Supabase.instance.client,
  );
  final repository = ProfileRepository(datasource: datasource);
  return ProfileNotifier(repository)..load();
});
