import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/mock_data/pagos_mock.dart';

/// Pago detail screen
class PagoDetailScreen extends StatefulWidget {
  final String pagoId;

  const PagoDetailScreen({
    super.key,
    required this.pagoId,
  });

  @override
  State<PagoDetailScreen> createState() => _PagoDetailScreenState();
}

class _PagoDetailScreenState extends State<PagoDetailScreen> {
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

  /// Header corporativo: [StatusBar naranja] + [AppBar gris con logo]
  Widget _buildCustomHeader(BuildContext context, String title) {
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
                onPressed: () => context.pop(),
              ),
              // Título
              Text(
                title,
                style: const TextStyle(
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

  @override
  Widget build(BuildContext context) {
    final pago = PagosMock.getById(widget.pagoId);

    if (pago == null) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: _lightStatusBarStyle,
        child: AppScaffold(
          // showBottomNav: true (default) → footer visible, bottomNavIndex: null → sin selección
          showInfoBar: false,
          body: Column(
            children: [
              _buildCustomHeader(context, 'Pago'),
              const Expanded(
                child: Center(child: Text('Pago no encontrado')),
              ),
            ],
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _lightStatusBarStyle,
      child: AppScaffold(
        // showBottomNav: true (default) → footer visible, bottomNavIndex: null → sin selección
        showInfoBar: false,
        body: Column(
          children: [
            _buildCustomHeader(context, 'Detalle de Pago'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      pago.concepto,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: AppConstants.spacingL),
                    _buildInfoRow('Monto:', '€${pago.monto.toStringAsFixed(2)}', context),
                    _buildInfoRow('Estado:', pago.estado.toUpperCase(), context),
                    _buildInfoRow(
                      'Fecha:',
                      '${pago.fecha.day}/${pago.fecha.month}/${pago.fecha.year}',
                      context,
                    ),
                    if (pago.metodoPago != null)
                      _buildInfoRow('Método de Pago:', pago.metodoPago!, context),
                    const SizedBox(height: AppConstants.spacingXL),
                    if (pago.estado == 'pendiente') ...[
                      CustomButton(
                        text: 'Pagar Ahora',
                        icon: Icons.payment,
                        onPressed: () {
                          // TODO PHASE 2: Implement Redsys payment
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Integración de pago disponible en Fase 2'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spacingM),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          border: Border.all(color: AppColors.info),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.info),
                            const SizedBox(width: AppConstants.spacingM),
                            Expanded(
                              child: Text(
                                'FASE 1: Integración de pagos (Redsys) pendiente',
                                style: TextStyle(color: AppColors.info),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
