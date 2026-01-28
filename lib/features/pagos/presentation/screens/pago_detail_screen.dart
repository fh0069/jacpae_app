import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/mock_data/pagos_mock.dart';

/// Pago detail screen
class PagoDetailScreen extends StatelessWidget {
  final String pagoId;

  const PagoDetailScreen({
    super.key,
    required this.pagoId,
  });

  @override
  Widget build(BuildContext context) {
    final pago = PagosMock.getById(pagoId);

    if (pago == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Pago'),
        body: const Center(child: Text('Pago no encontrado')),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Detalle de Pago'),
      body: SingleChildScrollView(
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
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.info),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info),
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
