import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/data/providers/auth_provider.dart';

/// Ajustes/Settings screen
class AjustesScreen extends ConsumerStatefulWidget {
  const AjustesScreen({super.key});

  @override
  ConsumerState<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends ConsumerState<AjustesScreen> {
  // Colores del patrón visual corporativo
  static const _statusBarColor = Color(0xFFEB5C00); // Naranja corporativo
  static const _appBarColor = Color(0xFFCDD1D5); // Gris AppBar

  // Estilo para iconos blancos en status bar
  static const _lightStatusBarStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  // Estilo neutro para restaurar al salir
  static const _defaultStatusBarStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  // ============================================
  // ESTADO LOCAL - Preferencias de notificaciones
  // ============================================
  bool _avisoReparto = true;
  bool _avisoFacturaEmitida = true;
  int _avisoGiroDias = 3; // Días antes del vencimiento
  bool _recibirOfertas = false;

  // Opciones para el dropdown de días
  static const List<int> _opcionesDiasGiro = [0, 1, 3, 5, 7, 10, 15];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(_lightStatusBarStyle);
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(_defaultStatusBarStyle);
    super.dispose();
  }

  /// Header corporativo: [StatusBar naranja] + [AppBar gris con logo]
  Widget _buildCustomHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Franja naranja (status bar)
        Container(
          width: double.infinity,
          height: statusBarHeight,
          color: _statusBarColor,
        ),
        // AppBar gris
        Container(
          width: double.infinity,
          height: kToolbarHeight,
          color: _appBarColor,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const SizedBox(width: 12),
              // Título
              const Text(
                'Ajustes',
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
              // Espacio para equilibrar
              const SizedBox(width: 48),
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
        bottomNavIndex: 3, // Tab Ajustes
        showInfoBar: false,
        body: Column(
          children: [
            // Header corporativo
            _buildCustomHeader(context),

            // Contenido scrollable
            Expanded(
              child: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        children: [
          // ========== SECCIÓN: NOTIFICACIONES ==========
          _buildSection(
            context,
            'Notificaciones',
            [
              // A) Aviso de reparto
              _buildSwitchTile(
                title: 'Aviso de reparto',
                subtitle: 'Recibirá una notificación 2 días antes del reparto programado',
                icon: Icons.local_shipping_outlined,
                value: _avisoReparto,
                onChanged: (value) => setState(() => _avisoReparto = value),
              ),
              const Divider(height: 1),

              // B) Aviso de factura emitida
              _buildSwitchTile(
                title: 'Aviso de factura emitida',
                subtitle: 'Recibir aviso al emitirse una nueva factura',
                icon: Icons.receipt_long_outlined,
                value: _avisoFacturaEmitida,
                onChanged: (value) => setState(() => _avisoFacturaEmitida = value),
              ),
              const Divider(height: 1),

              // C) Aviso de giro (selector de días)
              _buildDropdownTile(
                title: 'Aviso de giro',
                subtitle: _formatDiasGiro(_avisoGiroDias),
                icon: Icons.event_outlined,
                value: _avisoGiroDias,
                items: _opcionesDiasGiro,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _avisoGiroDias = value);
                  }
                },
              ),
              const Divider(height: 1),

              // D) Desea recibir ofertas
              _buildSwitchTile(
                title: 'Desea recibir ofertas',
                subtitle: 'Recibir ofertas y comunicaciones comerciales',
                icon: Icons.local_offer_outlined,
                value: _recibirOfertas,
                onChanged: (value) => setState(() => _recibirOfertas = value),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingL),

          // ========== SECCIÓN: SOBRE LA APP ==========
          _buildSection(
            context,
            'Sobre la app',
            [
              _buildTile(
                context,
                'Versión',
                Icons.info_outline,
                null,
                trailing: Text(
                  AppConstants.appVersion,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const Divider(height: 1),
              _buildTile(
                context,
                'Términos y condiciones',
                Icons.description_outlined,
                () => context.push(AppConstants.legalTermsRoute),
              ),
              const Divider(height: 1),
              _buildTile(
                context,
                'Política de privacidad',
                Icons.privacy_tip_outlined,
                () => context.push(AppConstants.legalPrivacyRoute),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXL),

          // ========== CERRAR SESIÓN ==========
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              final authService = ref.read(authServiceProvider);
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
          ),
        ],
      ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HELPERS
  // ============================================

  String _formatDiasGiro(int dias) {
    if (dias == 0) {
      return 'El mismo día del vencimiento';
    } else if (dias == 1) {
      return '1 día antes del vencimiento';
    } else {
      return '$dias días antes del vencimiento';
    }
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.spacingM,
            bottom: AppConstants.spacingS,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback? onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.accent, // Naranja corporativo #EB5C00
        activeThumbColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required int value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: DropdownButton<int>(
        value: value,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: items.map((dias) {
          String label;
          if (dias == 0) {
            label = 'El mismo día';
          } else if (dias == 1) {
            label = '1 día';
          } else {
            label = '$dias días';
          }
          return DropdownMenuItem<int>(
            value: dias,
            child: Text(label),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
