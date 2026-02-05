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
