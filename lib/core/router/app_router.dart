import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/consultas/presentation/screens/consultas_screen.dart';
import '../../features/consultas/presentation/screens/consulta_detail_screen.dart';
import '../../features/pagos/presentation/screens/pagos_screen.dart';
import '../../features/pagos/presentation/screens/pago_detail_screen.dart';
import '../../features/notificaciones/presentation/screens/notificaciones_screen.dart';
import '../../features/ajustes/presentation/screens/ajustes_screen.dart';
import '../../features/descargas/presentation/screens/descargas_screen.dart';
import '../../features/descargas/presentation/screens/historial_screen.dart';
import '../constants/app_constants.dart';

/// Global navigation router configuration
class AppRouter {
  AppRouter._();

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
      GoRoute(
        path: AppConstants.consultasRoute,
        name: 'consultas',
        builder: (context, state) => const ConsultasScreen(),
        routes: [
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
}
