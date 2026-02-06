import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';

/// Historial screen with mock activity data
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
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
                onPressed: () => context.pop(),
              ),
              // Título
              const Text(
                'Historial',
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

  @override
  Widget build(BuildContext context) {
    final actividades = [
      {
        'accion': 'Inicio de sesión',
        'fecha': DateTime.now().subtract(const Duration(hours: 1)),
        'icono': Icons.login,
        'color': AppColors.success
      },
      {
        'accion': 'Consulta creada',
        'fecha': DateTime.now().subtract(const Duration(days: 2)),
        'icono': Icons.question_answer,
        'color': AppColors.primary
      },
      {
        'accion': 'Factura descargada',
        'fecha': DateTime.now().subtract(const Duration(days: 3)),
        'icono': Icons.download,
        'color': AppColors.info
      },
      {
        'accion': 'Pago realizado',
        'fecha': DateTime.now().subtract(const Duration(days: 35)),
        'icono': Icons.payment,
        'color': AppColors.success
      },
      {
        'accion': 'Perfil actualizado',
        'fecha': DateTime.now().subtract(const Duration(days: 60)),
        'icono': Icons.person,
        'color': AppColors.secondary
      },
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _lightStatusBarStyle,
      child: AppScaffold(
        // showBottomNav: true (default) → footer visible, bottomNavIndex: null → sin selección
        showInfoBar: false,
        body: Column(
          children: [
            // Header corporativo
            _buildCustomHeader(context),

            // Lista de actividades
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                itemCount: actividades.length,
                itemBuilder: (context, index) {
                  final actividad = actividades[index];
                  final fecha = actividad['fecha'] as DateTime;
                  final icono = actividad['icono'] as IconData;
                  final color = actividad['color'] as Color;

                  return Card(
                    margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.2),
                        child: Icon(icono, color: color),
                      ),
                      title: Text(actividad['accion'] as String),
                      subtitle: Text(
                        '${fecha.day}/${fecha.month}/${fecha.year} - ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
