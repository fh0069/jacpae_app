import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../auth/data/providers/auth_provider.dart';
import '../../data/models/dashboard_item.dart';
import '../widgets/dashboard_card.dart';

/// Home/Dashboard screen with navigation menu
class HomeScreen extends ConsumerWidget {
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

  Future<void> _showProfileMenu(BuildContext context, WidgetRef ref) async {
    final authState = ref.read(authStateProvider);
    final authService = ref.read(authServiceProvider);
    final user = authState.user;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Text('Email: ${user.email ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('ID: ${user.id}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.verified_user, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  const Text('MFA Activado'),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await authService.signOut();
                if (context.mounted) {
                  context.go(AppConstants.loginRoute);
                }
              } on AuthException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al cerrar sesión: ${e.message}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Inicio',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showProfileMenu(context, ref),
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

              // Auth status notice
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: Text(
                        'Autenticado con MFA (AAL2)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.green,
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
