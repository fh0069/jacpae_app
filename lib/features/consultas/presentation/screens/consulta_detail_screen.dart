import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/mock_data/consultas_mock.dart';

/// Consulta detail screen
class ConsultaDetailScreen extends StatelessWidget {
  final String consultaId;

  const ConsultaDetailScreen({
    super.key,
    required this.consultaId,
  });

  @override
  Widget build(BuildContext context) {
    final consulta = ConsultasMock.getById(consultaId);

    if (consulta == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Consulta'),
        body: const Center(child: Text('Consulta no encontrada')),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Detalle de Consulta'),
      body: SingleChildScrollView(
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
                  color: AppColors.success.withOpacity(0.1),
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
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pending, color: AppColors.warning),
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
    );
  }
}
