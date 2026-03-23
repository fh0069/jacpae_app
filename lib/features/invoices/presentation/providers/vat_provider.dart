import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/vat_models.dart';
import '../../data/repositories/vat_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable state for the VAT list feature.
class VatState {
  final VatResponse? result;
  final bool isLoading;
  final String? errorMessage;
  final DateTime fromDate;
  final DateTime toDate;

  const VatState({
    this.result,
    this.isLoading = false,
    this.errorMessage,
    required this.fromDate,
    required this.toDate,
  });

  /// Default date range: January 1st of the previous year → today.
  /// Consistent with the date range used across other finance screens.
  factory VatState.initial() {
    final now = DateTime.now();
    return VatState(
      fromDate: DateTime(now.year - 1, 1, 1),
      toDate: DateTime(now.year, now.month, now.day),
    );
  }

  /// No load attempted yet.
  bool get isInitial => result == null && !isLoading && errorMessage == null;

  /// Response received and items list is non-empty.
  bool get hasData => result != null && result!.items.isNotEmpty;

  /// Response received but items list is empty.
  bool get isEmpty => result != null && result!.items.isEmpty;

  /// Returns a copy with [errorMessage] cleared to null.
  /// Cannot be done via [copyWith] since passing null would be ambiguous.
  VatState withClearedError() => VatState(
        result: result,
        isLoading: isLoading,
        fromDate: fromDate,
        toDate: toDate,
      );

  /// Returns a copy with [result] cleared to null.
  /// Cannot be done via [copyWith] since passing null would be ambiguous.
  VatState withClearedResult() => VatState(
        isLoading: isLoading,
        errorMessage: errorMessage,
        fromDate: fromDate,
        toDate: toDate,
      );

  VatState copyWith({
    VatResponse? result,
    bool? isLoading,
    String? errorMessage,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return VatState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────────────────────────────────────

class VatController extends StateNotifier<VatState> {
  final VatRepository _repository;

  static const String _networkError =
      'No se pudo cargar el IVA repercutido. '
      'Revisa tu conexión e inténtalo de nuevo.';

  VatController(this._repository) : super(VatState.initial());

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Loads the VAT list for the current [state.fromDate]–[state.toDate] range.
  /// Sets [isLoading], clears previous result and error.
  Future<void> load() async {
    // Capture dates before the first await to avoid reading mutated state
    // if the user calls updateFromDate/updateToDate during the request.
    final from = state.fromDate;
    final to = state.toDate;

    state = VatState(isLoading: true, fromDate: from, toDate: to);
    try {
      final result = await _repository.getVatList(startDate: from, endDate: to);
      if (!mounted) return;
      state = VatState(result: result, fromDate: from, toDate: to);
    } on UnauthorizedException {
      if (!mounted) return;
      state = VatState(
        errorMessage: 'Sesión caducada. Vuelve a iniciar sesión.',
        fromDate: from,
        toDate: to,
      );
    } on ForbiddenException {
      if (!mounted) return;
      state = VatState(
        errorMessage: 'No tienes permisos para consultar el IVA repercutido.',
        fromDate: from,
        toDate: to,
      );
    } on ServiceUnavailableException {
      if (!mounted) return;
      state = VatState(
        errorMessage: 'Servicio temporalmente no disponible.',
        fromDate: from,
        toDate: to,
      );
    } on SocketException {
      if (!mounted) return;
      state = VatState(errorMessage: _networkError, fromDate: from, toDate: to);
    } on ApiException catch (e) {
      if (!mounted) return;
      state = VatState(errorMessage: e.message, fromDate: from, toDate: to);
    } catch (_) {
      if (!mounted) return;
      state = VatState(errorMessage: _networkError, fromDate: from, toDate: to);
    }
  }

  /// Full reload. Alias of [load] — used by [RefreshIndicator].
  Future<void> refresh() => load();

  /// Updates [fromDate] without triggering a load.
  /// Call [applyFilter] to reload with the new range.
  void updateFromDate(DateTime date) {
    state = state.copyWith(fromDate: date);
  }

  /// Updates [toDate] without triggering a load.
  /// Call [applyFilter] to reload with the new range.
  void updateToDate(DateTime date) {
    state = state.copyWith(toDate: date);
  }

  /// Triggers a load with the current date range.
  /// Called when the user presses "Aplicar filtro".
  void applyFilter() => load();
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Global controller for VAT list state.
final vatControllerProvider =
    StateNotifierProvider<VatController, VatState>((ref) {
  final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';
  return VatController(VatRepository.create(apiBaseUrl: apiBaseUrl));
});
