import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../api/ledger_api.dart';
import '../models/ledger_models.dart';

/// Repository for ledger data.
///
/// Handles:
/// - Getting the access token from the active Supabase session
/// - Calling [LedgerApi] with proper authorization
/// - Returning a typed [LedgerResponse] to the presentation layer
class LedgerRepository {
  final LedgerApi _ledgerApi;
  final SupabaseClient _supabaseClient;

  LedgerRepository({
    required LedgerApi ledgerApi,
    required SupabaseClient supabaseClient,
  })  : _ledgerApi = ledgerApi,
        _supabaseClient = supabaseClient;

  /// Factory constructor that wires default dependencies.
  ///
  /// [apiBaseUrl] - Base URL for the FastAPI backend
  factory LedgerRepository.create({required String apiBaseUrl}) {
    final apiClient = ApiClient(baseUrl: apiBaseUrl);
    final ledgerApi = LedgerApi(apiClient);
    final supabaseClient = Supabase.instance.client;

    return LedgerRepository(
      ledgerApi: ledgerApi,
      supabaseClient: supabaseClient,
    );
  }

  /// Returns the JWT from the active Supabase session.
  ///
  /// Throws [UnauthorizedException] if no session exists.
  String _getAccessToken() {
    final session = _supabaseClient.auth.currentSession;
    if (session == null) {
      throw const UnauthorizedException(
        message: 'No hay sesión activa. Vuelve a iniciar sesión.',
      );
    }
    return session.accessToken;
  }

  /// Fetches the ledger for the given date range.
  ///
  /// [startDate] - Start of the requested period (inclusive)
  /// [endDate] - End of the requested period (inclusive)
  ///
  /// Returns a [LedgerResponse] with all entries in the range.
  /// Throws [ApiException] subclasses on error.
  Future<LedgerResponse> getLedger({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final token = _getAccessToken();
    return _ledgerApi.getLedger(
      token: token,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
