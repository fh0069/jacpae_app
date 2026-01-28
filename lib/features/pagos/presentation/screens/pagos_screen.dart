import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/mock_data/pagos_mock.dart';

/// Pagos list screen with mock data
class PagosScreen extends StatelessWidget {
  const PagosScreen({super.key});

  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return AppColors.warning;
      case 'pagado':
        return AppColors.success;
      case 'rechazado':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'pagado':
        return 'Pagado';
      case 'rechazado':
        return 'Rechazado';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagos = PagosMock.pagos;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Pagos'),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        itemCount: pagos.length,
        itemBuilder: (context, index) {
          final pago = pagos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
            child: ListTile(
              title: Text(pago.concepto),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    '€${pago.monto.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
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
                          color: _getStatusColor(pago.estado).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: Text(
                          _getStatusText(pago.estado),
                          style: TextStyle(
                            color: _getStatusColor(pago.estado),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${pago.fecha.day}/${pago.fecha.month}/${pago.fecha.year}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('${AppConstants.pagosRoute}/${pago.id}'),
            ),
          );
        },
      ),
    );
  }
}
