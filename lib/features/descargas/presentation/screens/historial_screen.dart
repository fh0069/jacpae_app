import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';

/// Historial screen with mock activity data
class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

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

    return Scaffold(
      appBar: const CustomAppBar(title: 'Historial'),
      body: ListView.builder(
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
                backgroundColor: color.withOpacity(0.2),
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
    );
  }
}
