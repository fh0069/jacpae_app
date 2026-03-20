import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/ledger_models.dart';
import '../../data/repositories/ledger_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable state for the ledger feature.
class LedgerState {
  final LedgerResponse? result;
  final bool isLoading;
  final String? errorMessage;
  final DateTime fromDate;
  final DateTime toDate;

  const LedgerState({
    this.result,
    this.isLoading = false,
    this.errorMessage,
    required this.fromDate,
    required this.toDate,
  });

  /// Default date range: January 1st of the previous year → today.
  /// Consistent with the date range used in InvoicesScreen._initializeDates().
  factory LedgerState.initial() {
    final now = DateTime.now();
    return LedgerState(
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
  LedgerState withClearedError() => LedgerState(
        result: result,
        isLoading: isLoading,
        fromDate: fromDate,
        toDate: toDate,
      );

  /// Returns a copy with [result] cleared to null.
  /// Cannot be done via [copyWith] since passing null would be ambiguous.
  LedgerState withClearedResult() => LedgerState(
        isLoading: isLoading,
        errorMessage: errorMessage,
        fromDate: fromDate,
        toDate: toDate,
      );

  LedgerState copyWith({
    LedgerResponse? result,
    bool? isLoading,
    String? errorMessage,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return LedgerState(
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

class LedgerController extends StateNotifier<LedgerState> {
  final LedgerRepository _repository;

  static const String _networkError =
      'No se pudo cargar el extracto. '
      'Revisa tu conexión e inténtalo de nuevo.';

  LedgerController(this._repository) : super(LedgerState.initial());

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Loads the ledger for the current [state.fromDate]–[state.toDate] range.
  /// Sets [isLoading], clears previous result and error.
  Future<void> load() async {
    // Capture dates before the first await to avoid reading mutated state
    // if the user calls updateFromDate/updateToDate during the request.
    final from = state.fromDate;
    final to = state.toDate;

    state = LedgerState(
      isLoading: true,
      fromDate: from,
      toDate: to,
    );
    try {
      final result = await _repository.getLedger(
        startDate: from,
        endDate: to,
      );
      if (!mounted) return;
      state = LedgerState(
        result: result,
        fromDate: from,
        toDate: to,
      );
    } on UnauthorizedException {
      if (!mounted) return;
      state = LedgerState(
        errorMessage: 'Sesión caducada. Vuelve a iniciar sesión.',
        fromDate: from,
        toDate: to,
      );
    } on ForbiddenException {
      if (!mounted) return;
      state = LedgerState(
        errorMessage: 'No tienes permisos para consultar el extracto.',
        fromDate: from,
        toDate: to,
      );
    } on ServiceUnavailableException {
      if (!mounted) return;
      state = LedgerState(
        errorMessage: 'Servicio temporalmente no disponible.',
        fromDate: from,
        toDate: to,
      );
    } on SocketException {
      if (!mounted) return;
      state = LedgerState(
        errorMessage: _networkError,
        fromDate: from,
        toDate: to,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      state = LedgerState(
        errorMessage: e.message,
        fromDate: from,
        toDate: to,
      );
    } catch (_) {
      if (!mounted) return;
      state = LedgerState(
        errorMessage: _networkError,
        fromDate: from,
        toDate: to,
      );
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

/// Global controller for ledger state.
final ledgerControllerProvider =
    StateNotifierProvider<LedgerController, LedgerState>((ref) {
  final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';
  return LedgerController(
    LedgerRepository.create(apiBaseUrl: apiBaseUrl),
  );
});
