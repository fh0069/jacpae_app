import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'api_exception.dart';

/// Generic HTTP client for API calls with error handling
///
/// Handles:
/// - GET requests with authorization headers
/// - Specific error mapping for 401, 403, 503
/// - JSON parsing
class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;

  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Performs a GET request with Bearer token authorization
  ///
  /// [endpoint] - API endpoint (e.g., '/invoices')
  /// [token] - Bearer token for authorization
  /// [queryParams] - Optional query parameters
  ///
  /// Returns decoded JSON response
  /// Throws [ApiException] subclasses for specific errors
  Future<dynamic> get(
    String endpoint, {
    required String token,
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(endpoint, queryParams);

    final response = await _httpClient.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  /// Performs a GET request that returns raw bytes (for file downloads)
  ///
  /// [endpoint] - API endpoint (e.g., '/invoices/{id}/pdf')
  /// [token] - Bearer token for authorization
  /// [queryParams] - Optional query parameters
  ///
  /// Returns raw response bytes as [Uint8List]
  /// Throws [ApiException] subclasses for specific errors
  Future<Uint8List> getBytes(
    String endpoint, {
    required String token,
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(endpoint, queryParams);

    final response = await _httpClient.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _checkResponseStatus(response);
    return response.bodyBytes;
  }

  /// Checks HTTP status code and throws typed exceptions on error
  void _checkResponseStatus(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return;

      case 401:
        throw const UnauthorizedException();

      case 403:
        final body = _tryParseBody(response.body);
        final detail = body?['detail'] as String?;
        throw ForbiddenException(message: detail);

      case 409:
        final body = _tryParseBody(response.body);
        final detail = body?['detail'] as String?;
        throw PdfNotReadyException(message: detail);

      case 503:
        final body = _tryParseBody(response.body);
        final detail = body?['detail'] as String?;
        throw ServiceUnavailableException(message: detail);

      default:
        final body = _tryParseBody(response.body);
        final detail = body?['detail'] as String?;
        throw GenericApiException(
          statusCode: response.statusCode,
          message: detail,
        );
    }
  }

  Uri _buildUri(String endpoint, Map<String, String>? queryParams) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  dynamic _handleResponse(http.Response response) {
    _checkResponseStatus(response);
    if (response.body.isEmpty) {
      return null;
    }
    return jsonDecode(response.body);
  }

  Map<String, dynamic>? _tryParseBody(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
