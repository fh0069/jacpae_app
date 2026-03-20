import '../../../../core/network/api_client.dart';
import '../models/ledger_models.dart';

// API layer for /finance/ledger endpoint
class LedgerApi {
  final ApiClient _apiClient;

  LedgerApi(this._apiClient);

  /// Fetches the ledger for the given date range.
  ///
  /// [token] - Bearer token for authorization
  /// [startDate] - Start of the requested period (inclusive)
  /// [endDate] - End of the requested period (inclusive)
  ///
  /// Returns a [LedgerResponse] with all items in the range.
  /// Throws [ApiException] subclasses on error.
  Future<LedgerResponse> getLedger({
    required String token,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _apiClient.get(
      '/finance/ledger',
      token: token,
      queryParams: {
        'start_date': _formatDate(startDate),
        'end_date': _formatDate(endDate),
      },
    );

    return LedgerResponse.fromJson(response as Map<String, dynamic>);
  }

  // Formats a DateTime as YYYY-MM-DD, matching the backend contract
  static String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
