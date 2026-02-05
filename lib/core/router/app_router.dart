import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/mfa_enroll_screen.dart';
import '../../features/auth/presentation/screens/mfa_verify_screen.dart';
import '../../features/auth/data/providers/auth_provider.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/consultas/presentation/screens/consultas_screen.dart';
import '../../features/consultas/presentation/screens/consulta_detail_screen.dart';
import '../../features/invoices/presentation/screens/invoices_screen.dart';
import '../../features/pagos/presentation/screens/pagos_screen.dart';
import '../../features/pagos/presentation/screens/pago_detail_screen.dart';
import '../../features/notificaciones/presentation/screens/notificaciones_screen.dart';
import '../../features/ajustes/presentation/screens/ajustes_screen.dart';
import '../../features/descargas/presentation/screens/descargas_screen.dart';
import '../../features/descargas/presentation/screens/historial_screen.dart';
import '../constants/app_constants.dart';

/// Global navigation router configuration with auth guards
class AppRouter {
  AppRouter._();

  static final provider = Provider<GoRouter>((ref) {
    final routerNotifier = ref.watch(routerRefreshNotifierProvider);

    return GoRouter(
      initialLocation: AppConstants.loginRoute,
      refreshListenable: routerNotifier,
      redirect: (context, state) {
        final isAuthenticated = routerNotifier.isAuthenticated;
        final isAAL2 = routerNotifier.isAAL2;
        final currentPath = state.uri.path;

        // DEBUG: Print auth state
        print('🔐 Router redirect: path=$currentPath, auth=$isAuthenticated, aal2=$isAAL2');

        // Public routes (no auth required)
        final isLoginRoute = currentPath == AppConstants.loginRoute;
        final isMFARoute = currentPath.startsWith('/mfa');

        // If user is fully authenticated (AAL2) and trying to access auth pages
        if (isAuthenticated && isAAL2) {
          print('✅ User is AAL2, redirecting away from auth pages');
          if (isLoginRoute || isMFARoute) {
            return AppConstants.homeRoute;
          }
          // Allow access to private routes
          return null;
        }

        // If user is authenticated but not AAL2
        if (isAuthenticated && !isAAL2) {
          print('⚠️  User is AAL1, needs MFA verification');
          // Allow access to MFA routes
          if (isMFARoute) {
            print('📍 Already on MFA route, allowing');
            return null;
          }
          // Redirect to MFA verification (the screen will handle enroll vs verify)
          print('🔄 Redirecting to MFA verify');
          return AppConstants.mfaVerifyRoute;
        }

        // If user is not authenticated
        if (!isAuthenticated) {
          print('❌ User not authenticated');
          // Allow access to login
          if (isLoginRoute) {
            print('📍 Already on login, allowing');
            return null;
          }
          // Redirect to login for any protected route
          print('🔄 Redirecting to login');
          return AppConstants.loginRoute;
        }

        return null;
      },
      routes: [
        // Auth routes
        GoRoute(
          path: AppConstants.loginRoute,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppConstants.mfaEnrollRoute,
          name: 'mfa-enroll',
          builder: (context, state) => const MFAEnrollScreen(),
        ),
        GoRoute(
          path: AppConstants.mfaVerifyRoute,
          name: 'mfa-verify',
          builder: (context, state) => const MFAVerifyScreen(),
        ),

        // Private routes (require auth + AAL2)
        GoRoute(
          path: AppConstants.homeRoute,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppConstants.consultasRoute,
          name: 'consultas',
          builder: (context, state) => const ConsultasScreen(),
          routes: [
            GoRoute(
              path: 'facturas',
              name: 'facturas',
              builder: (context, state) => const InvoicesScreen(),
            ),
            GoRoute(
              path: ':id',
              name: 'consulta-detail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ConsultaDetailScreen(consultaId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: AppConstants.pagosRoute,
          name: 'pagos',
          builder: (context, state) => const PagosScreen(),
          routes: [
            GoRoute(
              path: ':id',
              name: 'pago-detail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return PagoDetailScreen(pagoId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: AppConstants.notificacionesRoute,
          name: 'notificaciones',
          builder: (context, state) => const NotificacionesScreen(),
        ),
        GoRoute(
          path: AppConstants.ajustesRoute,
          name: 'ajustes',
          builder: (context, state) => const AjustesScreen(),
        ),
        GoRoute(
          path: AppConstants.descargasRoute,
          name: 'descargas',
          builder: (context, state) => const DescargasScreen(),
        ),
        GoRoute(
          path: AppConstants.historialRoute,
          name: 'historial',
          builder: (context, state) => const HistorialScreen(),
        ),
      ],
    );
  });

  /// Legacy static router for backwards compatibility
  /// Use AppRouter.provider instead for proper auth guards
  @Deprecated('Use AppRouter.provider instead')
  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.loginRoute,
    routes: [
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.homeRoute,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
