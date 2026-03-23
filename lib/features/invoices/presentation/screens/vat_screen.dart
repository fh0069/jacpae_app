import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/date_filter_section.dart';
import '../../data/models/vat_models.dart';
import '../providers/vat_provider.dart';
import '../widgets/vat_entry_tile.dart';

/// VAT list screen — shows issued invoices with IVA breakdown for a date range.
///
/// Corporate header pattern, DateFilterSection from core/widgets/.
/// ConsumerStatefulWidget required for SystemChrome lifecycle.
class VatScreen extends ConsumerStatefulWidget {
  const VatScreen({super.key});

  @override
  ConsumerState<VatScreen> createState() => _VatScreenState();
}

class _VatScreenState extends ConsumerState<VatScreen> {
  // Corporate visual pattern — identical across all app screens
  static const _statusBarColor = Color(0xFFEB5C00);
  static const _appBarColor = Color(0xFFCDD1D5);

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

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(_lightStatusBarStyle);
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(_defaultStatusBarStyle);
    super.dispose();
  }

  // ── Header ─────────────────────────────────────────────────────────────────

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
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              ),
              const Text(
                'Listado de facturas',
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

  // ── Totals ─────────────────────────────────────────────────────────────────

  Widget _buildTotals(BuildContext context, VatTotals totals) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del periodo',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            _buildTotalRow(context, 'Base imponible', totals.totalBaseFormatted),
            _buildTotalRow(context, 'Cuota IVA', totals.totalIvaFormatted),
            if (totals.totalRecargo > 0)
              _buildTotalRow(context, 'Recargo', totals.totalRecargoFormatted),
            const Divider(height: AppConstants.spacingM),
            _buildTotalRow(
              context,
              'Total facturado',
              totals.totalFacturaFormatted,
              highlight: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(
    BuildContext context,
    String label,
    String value, {
    bool highlight = false,
  }) {
    final style = highlight
        ? Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            )
        : Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }

  // ── Content states ──────────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context, VatState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.isInitial) {
      return _buildScrollable(
        child: _buildMessage(
          context,
          icon: Icons.tune,
          text: 'Selecciona un periodo y pulsa Aplicar',
        ),
      );
    }
    if (state.errorMessage != null) {
      return _buildScrollable(
        child: _buildMessage(
          context,
          icon: Icons.error_outline,
          text: state.errorMessage!,
        ),
      );
    }
    if (state.isEmpty) {
      return _buildScrollable(
        child: _buildMessage(
          context,
          icon: Icons.receipt_long_outlined,
          text: 'Sin facturas en el periodo seleccionado',
        ),
      );
    }

    // Totals pinned above the scrollable list
    return Column(
      children: [
        _buildTotals(context, state.result!.totals),
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.result!.items.length,
            itemBuilder: (_, index) =>
                VatEntryTile(item: state.result!.items[index]),
          ),
        ),
      ],
    );
  }

  /// Wraps a message widget in a scrollable container so RefreshIndicator works.
  Widget _buildScrollable({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildMessage(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vatControllerProvider);
    final notifier = ref.read(vatControllerProvider.notifier);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _lightStatusBarStyle,
      child: AppScaffold(
        showInfoBar: false,
        body: Column(
          children: [
            _buildCustomHeader(context),
            DateFilterSection(
              fromDate: state.fromDate,
              toDate: state.toDate,
              onFromDateChanged: notifier.updateFromDate,
              onToDateChanged: notifier.updateToDate,
              onApplyFilter: notifier.applyFilter,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: notifier.refresh,
                child: _buildContent(context, state),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
