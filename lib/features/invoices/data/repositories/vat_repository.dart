import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../api/vat_api.dart';
import '../models/vat_models.dart';

/// Repository for VAT list data.
///
/// Handles:
/// - Getting the access token from the active Supabase session
/// - Calling [VatApi] with proper authorization
/// - Returning a typed [VatResponse] to the presentation layer
class VatRepository {
  final VatApi _vatApi;
  final SupabaseClient _supabaseClient;

  VatRepository({
    required VatApi vatApi,
    required SupabaseClient supabaseClient,
  })  : _vatApi = vatApi,
        _supabaseClient = supabaseClient;

  /// Factory constructor that wires default dependencies.
  ///
  /// [apiBaseUrl] - Base URL for the FastAPI backend
  factory VatRepository.create({required String apiBaseUrl}) {
    final apiClient = ApiClient(baseUrl: apiBaseUrl);
    final vatApi = VatApi(apiClient);
    final supabaseClient = Supabase.instance.client;

    return VatRepository(
      vatApi: vatApi,
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

  /// Fetches the VAT list for the given date range.
  ///
  /// [startDate] - Start of the requested period (inclusive)
  /// [endDate] - End of the requested period (inclusive)
  ///
  /// Returns a [VatResponse] with all items and aggregated totals.
  /// Throws [ApiException] subclasses on error.
  Future<VatResponse> getVatList({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final token = _getAccessToken();
    return _vatApi.getVatList(
      token: token,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
