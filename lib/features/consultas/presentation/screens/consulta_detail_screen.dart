import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/mock_data/consultas_mock.dart';

/// Consulta detail screen
class ConsultaDetailScreen extends StatefulWidget {
  final String consultaId;

  const ConsultaDetailScreen({
    super.key,
    required this.consultaId,
  });

  @override
  State<ConsultaDetailScreen> createState() => _ConsultaDetailScreenState();
}

class _ConsultaDetailScreenState extends State<ConsultaDetailScreen> {
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
    final consulta = ConsultasMock.getById(widget.consultaId);

    if (consulta == null) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: _lightStatusBarStyle,
        child: AppScaffold(
          // showBottomNav: true (default) → footer visible, bottomNavIndex: null → sin selección
          showInfoBar: false,
          body: Column(
            children: [
              _buildCustomHeader(context, 'Consulta'),
              const Expanded(
                child: Center(child: Text('Consulta no encontrada')),
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
            _buildCustomHeader(context, 'Detalle de Consulta'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consulta.titulo,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    Text(
                      'Fecha: ${consulta.fecha.day}/${consulta.fecha.month}/${consulta.fecha.year}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppConstants.spacingL),
                    Text(
                      'Descripción',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppConstants.spacingS),
                    Text(consulta.descripcion),
                    const SizedBox(height: AppConstants.spacingL),
                    if (consulta.respuesta != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spacingM),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          border: Border.all(color: AppColors.success),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Respuesta',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.success,
                                  ),
                            ),
                            const SizedBox(height: AppConstants.spacingS),
                            Text(consulta.respuesta!),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spacingM),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          border: Border.all(color: AppColors.warning),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.pending, color: AppColors.warning),
                            const SizedBox(width: AppConstants.spacingM),
                            Expanded(
                              child: Text(
                                'Pendiente de respuesta',
                                style: TextStyle(color: AppColors.warning),
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
}
