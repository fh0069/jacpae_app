import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../api/invoices_api.dart';
import '../models/invoice.dart';

/// Repository for managing invoice data
///
/// Handles:
/// - Getting access token from Supabase session
/// - Calling InvoicesApi with proper authorization
/// - Client-side date filtering (temporary until backend supports it)
class InvoicesRepository {
  final InvoicesApi _invoicesApi;
  final SupabaseClient _supabaseClient;

  InvoicesRepository({
    required InvoicesApi invoicesApi,
    required SupabaseClient supabaseClient,
  })  : _invoicesApi = invoicesApi,
        _supabaseClient = supabaseClient;

  /// Factory constructor that creates repository with default dependencies
  ///
  /// [apiBaseUrl] - Base URL for the FastAPI backend
  factory InvoicesRepository.create({required String apiBaseUrl}) {
    final apiClient = ApiClient(baseUrl: apiBaseUrl);
    final invoicesApi = InvoicesApi(apiClient);
    final supabaseClient = Supabase.instance.client;

    return InvoicesRepository(
      invoicesApi: invoicesApi,
      supabaseClient: supabaseClient,
    );
  }

  /// Gets the current access token from Supabase session
  ///
  /// Throws [UnauthorizedException] if no session exists
  String _getAccessToken() {
    final session = _supabaseClient.auth.currentSession;
    if (session == null) {
      throw const UnauthorizedException(
        message: 'No hay sesión activa. Vuelve a iniciar sesión.',
      );
    }
    return session.accessToken;
  }

  /// Fetches invoices from the API
  ///
  /// [limit] - Maximum number of invoices to return
  /// [offset] - Number of invoices to skip for pagination
  /// [fromDate] - Optional: filter invoices from this date (client-side)
  /// [toDate] - Optional: filter invoices until this date (client-side)
  ///
  /// Note: Date filtering is done client-side as the backend
  /// only returns current and previous year invoices.
  /// This is a temporary solution until backend supports date filtering.
  Future<List<Invoice>> getInvoices({
    int limit = 50,
    int offset = 0,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final token = _getAccessToken();

    final invoices = await _invoicesApi.getInvoices(
      token: token,
      limit: limit,
      offset: offset,
    );

    // Apply client-side date filtering if dates are provided
    if (fromDate == null && toDate == null) {
      return invoices;
    }

    return invoices.where((invoice) {
      if (fromDate != null && invoice.fecha.isBefore(fromDate)) {
        return false;
      }
      if (toDate != null && invoice.fecha.isAfter(toDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Downloads an invoice PDF and saves it to a temporary file
  ///
  /// [invoiceId] - Base64url-encoded invoice identifier
  /// [fileDisplayName] - Human-readable name for the file (e.g., "FV-2024-0001")
  ///
  /// Returns the saved [File] ready to be opened
  /// Throws [PdfNotReadyException], [UnauthorizedException],
  /// [ForbiddenException], or [GenericApiException] on error
  Future<File> downloadInvoicePdf({
    required String invoiceId,
    required String fileDisplayName,
  }) async {
    final token = _getAccessToken();

    final bytes = await _invoicesApi.downloadInvoicePdf(
      token: token,
      invoiceId: invoiceId,
    );

    final sanitized = _sanitizeFilename(fileDisplayName);
    final fileName = sanitized.isNotEmpty ? 'Factura_$sanitized' : 'Factura';
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName.pdf');
    await file.writeAsBytes(bytes);

    return file;
  }

  /// Removes filesystem-unsafe characters from a filename
  static String _sanitizeFilename(String name) {
    return name
        .replaceAll(RegExp(r'[/\\:*?"<>|\s]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  /// Fetches all invoices with pagination, applying client-side filtering
  ///
  /// This method handles loading more invoices for infinite scroll/pagination.
  /// It fetches from API and then filters by date range.
  Future<InvoicesResult> fetchInvoices({
    int limit = 50,
    int offset = 0,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final allInvoices = await getInvoices(
      limit: limit,
      offset: offset,
      fromDate: fromDate,
      toDate: toDate,
    );

    // Check if there might be more invoices (for pagination)
    // If we got fewer than the limit, we've reached the end
    final hasMore = allInvoices.length >= limit;

    return InvoicesResult(
      invoices: allInvoices,
      hasMore: hasMore,
      nextOffset: offset + allInvoices.length,
    );
  }
}

/// Result class for paginated invoice fetching
class InvoicesResult {
  final List<Invoice> invoices;
  final bool hasMore;
  final int nextOffset;

  const InvoicesResult({
    required this.invoices,
    required this.hasMore,
    required this.nextOffset,
  });
}
