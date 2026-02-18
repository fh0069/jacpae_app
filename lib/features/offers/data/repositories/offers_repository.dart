import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../api/offers_api.dart';

/// Repository for downloading the current offer PDF.
///
/// Follows the same pattern as [InvoicesRepository]:
/// - Gets access token from Supabase session.
/// - Calls [OffersApi] with proper authorization.
/// - Saves the file to the app's Documents directory (visible in Descargas).
class OffersRepository {
  final OffersApi _offersApi;
  final SupabaseClient _supabaseClient;

  OffersRepository({
    required OffersApi offersApi,
    required SupabaseClient supabaseClient,
  })  : _offersApi = offersApi,
        _supabaseClient = supabaseClient;

  /// Factory constructor that creates the repository with default dependencies.
  factory OffersRepository.create({required String apiBaseUrl}) {
    final apiClient = ApiClient(baseUrl: apiBaseUrl);
    final offersApi = OffersApi(apiClient);
    final supabaseClient = Supabase.instance.client;

    return OffersRepository(
      offersApi: offersApi,
      supabaseClient: supabaseClient,
    );
  }

  /// Gets the current access token from Supabase session.
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

  /// Downloads the current offer PDF and saves it to the Documents directory.
  ///
  /// The saved file will appear automatically in the Descargas screen
  /// (which lists all .pdf files from Documents).
  ///
  /// Returns the saved [File] ready to be opened.
  /// Throws [UnauthorizedException] (401), [OfferNotAvailableException] (404),
  /// or [GenericApiException] for other errors.
  Future<File> downloadCurrentOfferPdf() async {
    final token = _getAccessToken();

    final bytes = await _offersApi.downloadCurrentOfferPdf(token);

    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final fileName = 'Oferta_$timestamp';
    final sanitized = _sanitizeFilename(fileName);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$sanitized.pdf');
    await file.writeAsBytes(bytes);

    return file;
  }

  /// Removes filesystem-unsafe characters from a filename.
  static String _sanitizeFilename(String name) {
    return name
        .replaceAll(RegExp(r'[/\\:*?"<>|\s]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
