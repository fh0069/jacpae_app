import 'dart:typed_data';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';

/// API layer for the offers endpoint.
///
/// Handles HTTP calls to GET /offers/current.
class OffersApi {
  final ApiClient _apiClient;

  OffersApi(this._apiClient);

  /// Downloads the current offer PDF bytes from the API.
  ///
  /// [token] - Bearer token for authorization.
  ///
  /// Returns raw PDF bytes.
  /// Throws [UnauthorizedException] (401), [OfferNotAvailableException] (404),
  /// or [GenericApiException] for other errors.
  Future<Uint8List> downloadCurrentOfferPdf(String token) async {
    try {
      return await _apiClient.getBytes(
        '/offers/current',
        token: token,
      );
    } on GenericApiException catch (e) {
      if (e.statusCode == 404) {
        throw const OfferNotAvailableException();
      }
      rethrow;
    }
  }
}
