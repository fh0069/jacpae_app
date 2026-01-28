import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/mock_data/notificaciones_mock.dart';

/// Notificaciones list screen with mock data
class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final notificaciones = NotificacionesMock.notificaciones;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Notificaciones'),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        itemCount: notificaciones.length,
        itemBuilder: (context, index) {
          final notif = notificaciones[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
            color: notif.leida ? null : AppColors.primary.withOpacity(0.05),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getTipoColor(notif.tipo).withOpacity(0.2),
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
                      decoration: BoxDecoration(
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
                // TODO PHASE 2: Mark as read and navigate to detail
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Detalle disponible en Fase 2')),
                );
              },
            ),
          );
        },
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
