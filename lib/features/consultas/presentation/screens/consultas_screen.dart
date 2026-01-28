import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/mock_data/consultas_mock.dart';

/// Consultas list screen with mock data
class ConsultasScreen extends StatelessWidget {
  const ConsultasScreen({super.key});

  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return AppColors.warning;
      case 'en_proceso':
        return AppColors.info;
      case 'resuelta':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_proceso':
        return 'En Proceso';
      case 'resuelta':
        return 'Resuelta';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final consultas = ConsultasMock.consultas;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Consultas'),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        itemCount: consultas.length,
        itemBuilder: (context, index) {
          final consulta = consultas[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
            child: ListTile(
              title: Text(consulta.titulo),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    consulta.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingS,
                          vertical: AppConstants.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(consulta.estado).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: Text(
                          _getStatusText(consulta.estado),
                          style: TextStyle(
                            color: _getStatusColor(consulta.estado),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${consulta.fecha.day}/${consulta.fecha.month}/${consulta.fecha.year}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('${AppConstants.consultasRoute}/${consulta.id}'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO PHASE 2: Navigate to create consulta
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Función disponible en Fase 2')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
