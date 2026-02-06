import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/data/providers/auth_provider.dart';
import '../../data/models/dashboard_item.dart';
import '../widgets/dashboard_card.dart';

/// Home/Dashboard screen with navigation menu
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Colores
  static const _statusBarColor = Color(0xFFEB5C00); // Naranja corporativo
  static const _appBarColor = Color(0xFFCDD1D5); // Gris AppBar (más oscuro para contraste)

  // Estilo para iconos blancos en status bar
  static const _lightStatusBarStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparente - pintamos nosotros
    statusBarIconBrightness: Brightness.light, // Iconos blancos
    statusBarBrightness: Brightness.dark, // Para iOS
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
    // Aplicar iconos blancos en status bar
    SystemChrome.setSystemUIOverlayStyle(_lightStatusBarStyle);
  }

  @override
  void dispose() {
    // Restaurar estilo neutro al salir
    SystemChrome.setSystemUIOverlayStyle(_defaultStatusBarStyle);
    super.dispose();
  }

  // Mock dashboard items
  List<DashboardItem> get _dashboardItems => [
        DashboardItem(
          title: 'Consultas',
          subtitle: 'Facturas, albaranes o pedidos',
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

  Future<void> _showProfileMenu(BuildContext context) async {
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

  /// Construye el header custom: [StatusBar naranja] + [AppBar gris]
  Widget _buildCustomHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ========== FRANJA NARANJA (área de status bar) ==========
        Container(
          width: double.infinity,
          height: statusBarHeight,
          color: _statusBarColor,
        ),

        // ========== APPBAR GRIS ==========
        Container(
          width: double.infinity,
          height: kToolbarHeight,
          color: _appBarColor,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const SizedBox(width: 12),
              // Título a la izquierda
              const Text(
                'Inicio',
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
              // Icono de perfil
              IconButton(
                icon: const Icon(Icons.person, color: AppColors.textPrimary),
                onPressed: () => _showProfileMenu(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _lightStatusBarStyle,
      child: AppScaffold(
        bottomNavIndex: 0, // Tab Inicio seleccionado
        showInfoBar: false, // Sin footer de redes sociales
        // SIN appBar - lo pintamos manualmente en el body
        body: Column(
          children: [
            // Header custom: status bar naranja + toolbar gris
            _buildCustomHeader(context),

            // Contenido principal (scrollable)
            Expanded(
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
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: AppConstants.spacingM),
                          Expanded(
                            child: Text(
                              'Autenticado con MFA (AAL2)',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
          ],
        ),
      ),
    );
  }
}
