import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';

/// Descargas screen with mock data
class DescargasScreen extends StatelessWidget {
  const DescargasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final documentos = [
      {'nombre': 'Factura_Enero_2026.pdf', 'fecha': DateTime.now().subtract(const Duration(days: 3))},
      {'nombre': 'Factura_Diciembre_2025.pdf', 'fecha': DateTime.now().subtract(const Duration(days: 35))},
      {'nombre': 'Contrato_Servicio.pdf', 'fecha': DateTime.now().subtract(const Duration(days: 180))},
      {'nombre': 'Certificado_Cliente.pdf', 'fecha': DateTime.now().subtract(const Duration(days: 200))},
    ];

    return Scaffold(
      appBar: const CustomAppBar(title: 'Descargas'),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        itemCount: documentos.length,
        itemBuilder: (context, index) {
          final doc = documentos[index];
          final fecha = doc['fecha'] as DateTime;
          return Card(
            margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.error.withOpacity(0.1),
                child: const Icon(Icons.picture_as_pdf, color: AppColors.error),
              ),
              title: Text(doc['nombre'] as String),
              subtitle: Text('${fecha.day}/${fecha.month}/${fecha.year}'),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  // TODO PHASE 2: Implement document download
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Descargando ${doc['nombre']}... (Demo)'),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
