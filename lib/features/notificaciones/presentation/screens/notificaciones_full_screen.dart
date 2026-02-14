import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/mock_data/notificaciones_mock.dart';

/// Notificaciones list screen with mock data — preserved for Phase 2.
/// Currently inactive; the active route uses [NotificacionesScreen] (en desarrollo).
class NotificacionesFullScreen extends StatefulWidget {
  const NotificacionesFullScreen({super.key});

  @override
  State<NotificacionesFullScreen> createState() =>
      _NotificacionesFullScreenState();
}

class _NotificacionesFullScreenState extends State<NotificacionesFullScreen> {
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

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'info':
        return AppColors.info;
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      case 'success':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'info':
        return Icons.info_outline;
      case 'warning':
        return Icons.warning_amber;
      case 'error':
        return Icons.error_outline;
      case 'success':
        return Icons.check_circle_outline;
      default:
        return Icons.notifications;
    }
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
              const SizedBox(width: 12),
              // Título
              const Text(
                'Notificaciones',
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
    final notificaciones = NotificacionesMock.notificaciones;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _lightStatusBarStyle,
      child: AppScaffold(
        bottomNavIndex: 2,
        showInfoBar: false,
        body: Column(
          children: [
            // Header corporativo
            _buildCustomHeader(context),

            // Lista de notificaciones
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                itemCount: notificaciones.length,
                itemBuilder: (context, index) {
                  final notif = notificaciones[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
                    color: notif.leida
                        ? null
                        : AppColors.primary.withValues(alpha: 0.05),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            _getTipoColor(notif.tipo).withValues(alpha: 0.2),
                        child: Icon(
                          _getTipoIcon(notif.tipo),
                          color: _getTipoColor(notif.tipo),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text(notif.titulo)),
                          if (!notif.leida)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppConstants.spacingS),
                          Text(
                            notif.mensaje,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppConstants.spacingS),
                          Text(
                            _formatFecha(notif.fecha),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Detalle disponible en Fase 2'),
                          ),
                        );
                      },
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

  String _formatFecha(DateTime fecha) {
    final now = DateTime.now();
    final difference = now.difference(fecha);

    if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }
}
