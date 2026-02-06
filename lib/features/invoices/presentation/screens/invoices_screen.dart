import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/models/invoice.dart';
import '../../data/repositories/invoices_repository.dart';
import '../widgets/date_filter_section.dart';
import '../widgets/invoice_list_tile.dart';

/// Screen state enum for managing UI states
enum InvoicesScreenState { initial, loading, success, error, empty }

/// Invoices screen with date filters and paginated list
///
/// Features:
/// - Date filters (desde/hasta) with validation
/// - Tab segments: "Todas" (enabled), "Pendientes de pago" (disabled)
/// - States: Loading, Error, Empty, Success
/// - Pagination with "Cargar más" button
/// - Client-side date filtering (temporary)
class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  // Colores del patrón visual corporativo
  static const _statusBarColor = Color(0xFFEB5C00); // Naranja corporativo
  static const _appBarColor = Color(0xFFCDD1D5); // Gris AppBar

  // Estilo para iconos blancos en status bar
  static const _lightStatusBarStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  // Estilo neutro para restaurar al salir
  static const _defaultStatusBarStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  // State management
  InvoicesScreenState _screenState = InvoicesScreenState.initial;
  String? _errorMessage;
  List<Invoice> _invoices = [];
  bool _hasMore = true;
  int _currentOffset = 0;
  bool _isLoadingMore = false;

  // Date filters
  late DateTime _fromDate;
  late DateTime _toDate;

  // Repository
  late final InvoicesRepository _repository;

  // Tab selection (0 = Todas, 1 = Pendientes)
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(_lightStatusBarStyle);
    _initializeDates();
    _initializeRepository();
    // No carga automáticamente - espera a que el usuario pulse "Aplicar filtro"
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(_defaultStatusBarStyle);
    super.dispose();
  }

  /// Header corporativo: [StatusBar naranja] + [AppBar gris con logo]
  Widget _buildCustomHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Franja naranja (status bar)
        Container(
          width: double.infinity,
          height: statusBarHeight,
          color: _statusBarColor,
        ),
        // AppBar gris
        Container(
          width: double.infinity,
          height: kToolbarHeight,
          color: _appBarColor,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              // Botón back
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => context.go(AppConstants.consultasRoute),
              ),
              // Título
              const Text(
                'Consulta de Facturas',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              // Logo centrado
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Espacio para equilibrar
              const SizedBox(width: 48),
            ],
          ),
        ),
      ],
    );
  }

  void _initializeDates() {
    final now = DateTime.now();
    // Default: from January 1st of previous year to today
    _fromDate = DateTime(now.year - 1, 1, 1);
    _toDate = DateTime(now.year, now.month, now.day);
  }

  void _initializeRepository() {
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (apiBaseUrl.isEmpty) {
      setState(() {
        _screenState = InvoicesScreenState.error;
        _errorMessage = 'API_BASE_URL no configurada. Contacta con soporte.';
      });
      return;
    }
    _repository = InvoicesRepository.create(apiBaseUrl: apiBaseUrl);
  }

  Future<void> _loadInvoices({bool refresh = true}) async {
    if (refresh) {
      setState(() {
        _screenState = InvoicesScreenState.loading;
        _invoices = [];
        _currentOffset = 0;
        _hasMore = true;
      });
    }

    try {
      final result = await _repository.fetchInvoices(
        limit: 50,
        offset: _currentOffset,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      setState(() {
        if (refresh) {
          _invoices = result.invoices;
        } else {
          _invoices = [..._invoices, ...result.invoices];
        }
        _hasMore = result.hasMore;
        _currentOffset = result.nextOffset;
        _screenState = _invoices.isEmpty
            ? InvoicesScreenState.empty
            : InvoicesScreenState.success;
        _isLoadingMore = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _screenState = InvoicesScreenState.error;
        _errorMessage = e.message;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _screenState = InvoicesScreenState.error;
        _errorMessage = 'Error inesperado: ${e.toString()}';
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _loadInvoices(refresh: false);
  }

  void _onFromDateChanged(DateTime date) {
    setState(() {
      _fromDate = date;
    });
  }

  void _onToDateChanged(DateTime date) {
    setState(() {
      _toDate = date;
    });
  }

  void _applyFilter() {
    _loadInvoices(refresh: true);
  }

  void _onTabChanged(int index) {
    if (index == 1) {
      // "Pendientes de pago" is disabled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Filtro de pendientes disponible próximamente'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _lightStatusBarStyle,
      child: AppScaffold(
        // bottomNavIndex: null → sin tab seleccionado (todos grises)
        showInfoBar: false,
        body: Column(
          children: [
            // Header corporativo
            _buildCustomHeader(context),

            // Date filters
            DateFilterSection(
              fromDate: _fromDate,
              toDate: _toDate,
              onFromDateChanged: _onFromDateChanged,
              onToDateChanged: _onToDateChanged,
              onApplyFilter: _applyFilter,
            ),

            // Tab segments
            _buildTabSegments(),

            // Content based on state
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSegments() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Todas',
              isSelected: _selectedTab == 0,
              onTap: () => _onTabChanged(0),
            ),
          ),
          const SizedBox(width: AppConstants.spacingS),
          Expanded(
            child: _TabButton(
              label: 'Pendientes de pago',
              isSelected: _selectedTab == 1,
              isDisabled: true,
              badge: 'Próximamente',
              onTap: () => _onTabChanged(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_screenState) {
      case InvoicesScreenState.initial:
        return _buildInitial();
      case InvoicesScreenState.loading:
        return _buildLoading();
      case InvoicesScreenState.error:
        return _buildError();
      case InvoicesScreenState.empty:
        return _buildEmpty();
      case InvoicesScreenState.success:
        return _buildInvoicesList();
    }
  }

  Widget _buildInitial() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_alt_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'Configura los filtros de fecha',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'Pulsa "Aplicar filtro" para cargar las facturas',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppConstants.spacingM),
          Text('Cargando facturas...'),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              _errorMessage ?? 'Error inesperado',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppConstants.spacingL),
            FilledButton.icon(
              onPressed: () => _loadInvoices(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'No hay facturas en el rango seleccionado',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'Prueba a ajustar las fechas del filtro',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesList() {
    return RefreshIndicator(
      onRefresh: () => _loadInvoices(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: AppConstants.spacingL),
        itemCount: _invoices.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Load more button at the end
          if (index == _invoices.length) {
            return _buildLoadMoreButton();
          }

          return InvoiceListTile(
            invoice: _invoices[index],
            onTap: () {
              // TODO: Navigate to invoice detail if needed
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator()
            : OutlinedButton.icon(
                onPressed: _loadMore,
                icon: const Icon(Icons.expand_more),
                label: const Text('Cargar más'),
              ),
      ),
    );
  }
}

/// Tab button widget for the segment control
class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final String? badge;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDisabled = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? AppColors.primary
        : (isDisabled ? Colors.grey.shade200 : Colors.grey.shade100);
    final textColor = isSelected
        ? Colors.white
        : (isDisabled ? AppColors.textSecondary : AppColors.textPrimary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacingS,
          horizontal: AppConstants.spacingM,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badge != null && isDisabled) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
