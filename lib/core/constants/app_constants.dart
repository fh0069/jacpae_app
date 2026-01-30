/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'JacPae App';
  static const String appVersion = '1.0.0 (PHASE 1)';

  // Route names
  static const String loginRoute = '/';
  static const String mfaEnrollRoute = '/mfa/enroll';
  static const String mfaVerifyRoute = '/mfa/verify';
  static const String homeRoute = '/home';
  static const String consultasRoute = '/consultas';
  static const String consultaDetailRoute = '/consultas/:id';
  static const String pagosRoute = '/pagos';
  static const String pagoDetailRoute = '/pagos/:id';
  static const String notificacionesRoute = '/notificaciones';
  static const String ajustesRoute = '/ajustes';
  static const String descargasRoute = '/descargas';
  static const String historialRoute = '/historial';

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
}
