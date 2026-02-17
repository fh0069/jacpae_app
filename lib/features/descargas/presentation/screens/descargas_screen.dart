import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../invoices/data/repositories/invoices_repository.dart';
import '../../data/downloaded_pdf.dart';

/// Descargas screen — lists locally downloaded PDF invoices with pagination.
class DescargasScreen extends StatefulWidget {
  const DescargasScreen({super.key});

  @override
  State<DescargasScreen> createState() => _DescargasScreenState();
}

class _DescargasScreenState extends State<DescargasScreen> {
  static const _statusBarColor = Color(0xFFEB5C00);
  static const _appBarColor = Color(0xFFCDD1D5);
  static const _pageSize = 50;

  static const _lightStatusBarStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  static const _defaultStatusBarStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  late final InvoicesRepository _repository;

  final List<DownloadedPdf> _items = [];
  int _offset = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(_lightStatusBarStyle);
    final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';
    _repository = InvoicesRepository.create(apiBaseUrl: apiBaseUrl);
    _loadInitial();
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(_defaultStatusBarStyle);
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final pdfs = await _repository.getDownloadedInvoices(
        limit: _pageSize,
        offset: 0,
      );
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(pdfs);
        _offset = pdfs.length;
        _hasMore = pdfs.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al cargar descargas';
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePdf(int index) async {
    final pdf = _items[index];

    // Optimistic removal
    setState(() => _items.removeAt(index));

    try {
      await _repository.deleteDownloadedPdf(pdf.file);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF eliminado')),
      );
    } catch (_) {
      if (!mounted) return;
      // Restore item on failure
      setState(() => _items.insert(index.clamp(0, _items.length), pdf));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar el PDF')),
      );
    }
  }

  Future<void> _confirmDelete(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar PDF'),
        content: const Text(
          '¿Quieres eliminar este PDF descargado del dispositivo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _deletePdf(index);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final pdfs = await _repository.getDownloadedInvoices(
        limit: _pageSize,
        offset: _offset,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(pdfs);
        _offset += pdfs.length;
        _hasMore = pdfs.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  Widget _buildCustomHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: statusBarHeight,
          color: _statusBarColor,
        ),
        Container(
          width: double.infinity,
          height: kToolbarHeight,
          color: _appBarColor,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Text(
                'Descargas',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.download_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay descargas aún',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los PDFs descargados desde Facturas aparecerán aquí.',
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

  Widget _buildList() {
    // itemCount: items + 1 extra row for "load more" button when applicable
    final itemCount = _items.length + (_hasMore ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // "Cargar más" button at the end
        if (index == _items.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
            child: Center(
              child: _isLoadingMore
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : OutlinedButton.icon(
                      onPressed: _loadMore,
                      icon: const Icon(Icons.expand_more),
                      label: const Text('Cargar más'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
            ),
          );
        }

        final pdf = _items[index];
        final fechaStr = _dateFormat.format(pdf.modified);

        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.error.withValues(alpha: 0.1),
              child:
                  const Icon(Icons.picture_as_pdf, color: AppColors.error),
            ),
            title: Text(
              pdf.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(fechaStr),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary),
              tooltip: 'Eliminar',
              onPressed: () => _confirmDelete(index),
            ),
            onTap: () => OpenFilex.open(pdf.file.path),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _lightStatusBarStyle,
      child: AppScaffold(
        // bottomNavIndex: null → footer visible, sin tab seleccionado
        showInfoBar: false,
        body: Column(
          children: [
            _buildCustomHeader(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return _buildEmpty(context);
    }

    return _buildList();
  }
}
