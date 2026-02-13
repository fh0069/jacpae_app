import 'dart:typed_data';
import '../../../../core/network/api_client.dart';
import '../models/invoice.dart';

/// API layer for invoices endpoint
///
/// Handles HTTP calls to GET /invoices
class InvoicesApi {
  final ApiClient _apiClient;

  InvoicesApi(this._apiClient);

  /// Fetches invoices from the API
  ///
  /// [token] - Bearer token for authorization
  /// [limit] - Maximum number of invoices to return (default 50)
  /// [offset] - Number of invoices to skip for pagination (default 0)
  ///
  /// Returns a list of [Invoice] objects
  /// Throws [ApiException] on error
  Future<List<Invoice>> getInvoices({
    required String token,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _apiClient.get(
      '/invoices',
      token: token,
      queryParams: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
    );

    // Response is a JSON array
    final List<dynamic> jsonList = response as List<dynamic>;
    return jsonList
        .map((json) => Invoice.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Downloads invoice PDF bytes from the API
  ///
  /// [token] - Bearer token for authorization
  /// [invoiceId] - Base64url-encoded invoice identifier
  ///
  /// Returns raw PDF bytes
  /// Throws [PdfNotReadyException] (409), [UnauthorizedException] (401),
  /// [ForbiddenException] (403), or [GenericApiException] on error
  Future<Uint8List> downloadInvoicePdf({
    required String token,
    required String invoiceId,
  }) async {
    return _apiClient.getBytes(
      '/invoices/$invoiceId/pdf',
      token: token,
    );
  }
}
