import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/dashboard_item.dart';
import '../widgets/dashboard_card.dart';

/// Home/Dashboard screen with navigation menu
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Mock dashboard items
  List<DashboardItem> get _dashboardItems => [
        DashboardItem(
          title: 'Consultas',
          subtitle: 'Ver y crear consultas',
          icon: Icons.question_answer,
          color: AppColors.primary,
          route: AppConstants.consultasRoute,
          badgeCount: 3,
        ),
        DashboardItem(
          title: 'Pagos',
          subtitle: 'Gestionar pagos',
          icon: Icons.payment,
          color: AppColors.secondary,
          route: AppConstants.pagosRoute,
          badgeCount: 1,
        ),
        DashboardItem(
          title: 'Notificaciones',
          subtitle: 'Mensajes y alertas',
          icon: Icons.notifications,
          color: AppColors.warning,
          route: AppConstants.notificacionesRoute,
          badgeCount: 5,
        ),
        DashboardItem(
          title: 'Descargas',
          subtitle: 'Documentos y archivos',
          icon: Icons.download,
          color: AppColors.info,
          route: AppConstants.descargasRoute,
        ),
        DashboardItem(
          title: 'Historial',
          subtitle: 'Actividad reciente',
          icon: Icons.history,
          color: AppColors.textSecondary,
          route: AppConstants.historialRoute,
        ),
        DashboardItem(
          title: 'Ajustes',
          subtitle: 'Configuración',
          icon: Icons.settings,
          color: AppColors.textPrimary,
          route: AppConstants.ajustesRoute,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Inicio',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO PHASE 2: Navigate to profile
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Text(
                '¡Bienvenido!',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                'Seleccione una opción del menú',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Phase 1 notice
              Container(
                width: double.infinity,
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
                        'FASE 1: Todas las funciones usan datos de prueba',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.info,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Dashboard grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppConstants.spacingM,
                  mainAxisSpacing: AppConstants.spacingM,
                  childAspectRatio: 1.1,
                ),
                itemCount: _dashboardItems.length,
                itemBuilder: (context, index) {
                  final item = _dashboardItems[index];
                  return DashboardCard(
                    item: item,
                    onTap: () => context.push(item.route),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
