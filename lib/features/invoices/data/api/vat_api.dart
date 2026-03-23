import '../../../../core/network/api_client.dart';
import '../models/vat_models.dart';

// API layer for /invoices/vat-list endpoint
class VatApi {
  final ApiClient _apiClient;

  VatApi(this._apiClient);

  /// Fetches the VAT list for the given date range.
  ///
  /// [token] - Bearer token for authorization
  /// [startDate] - Start of the requested period (inclusive)
  /// [endDate] - End of the requested period (inclusive)
  ///
  /// Returns a [VatResponse] with all items and aggregated totals.
  /// Throws [ApiException] subclasses on error.
  Future<VatResponse> getVatList({
    required String token,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _apiClient.get(
      '/invoices/vat-list',
      token: token,
      queryParams: {
        'start_date': _formatDate(startDate),
        'end_date': _formatDate(endDate),
      },
    );

    return VatResponse.fromJson(response as Map<String, dynamic>);
  }

  // Formats a DateTime as YYYY-MM-DD, matching the backend contract
  static String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
