import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../auth/data/services/auth_service.dart';

/// Ajustes/Settings screen
class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Ajustes'),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        children: [
          _buildSection(
            context,
            'Cuenta',
            [
              _buildTile(
                context,
                'Perfil',
                Icons.person,
                () {
                  // TODO PHASE 2: Navigate to profile
                  _showPlaceholder(context);
                },
              ),
              _buildTile(
                context,
                'Cambiar contraseña',
                Icons.lock,
                () {
                  // TODO PHASE 2: Navigate to change password
                  _showPlaceholder(context);
                },
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingL),
          _buildSection(
            context,
            'Notificaciones',
            [
              _buildSwitchTile(
                context,
                'Notificaciones push',
                Icons.notifications,
                true,
                (value) {
                  // TODO PHASE 2: Update notification settings
                  _showPlaceholder(context);
                },
              ),
              _buildSwitchTile(
                context,
                'Notificaciones por email',
                Icons.email,
                false,
                (value) {
                  // TODO PHASE 2: Update email settings
                  _showPlaceholder(context);
                },
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingL),
          _buildSection(
            context,
            'Sobre la app',
            [
              _buildTile(
                context,
                'Versión',
                Icons.info,
                null,
                trailing: Text(
                  AppConstants.appVersion,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              _buildTile(
                context,
                'Términos y condiciones',
                Icons.description,
                () {
                  // TODO PHASE 2: Show terms
                  _showPlaceholder(context);
                },
              ),
              _buildTile(
                context,
                'Política de privacidad',
                Icons.privacy_tip,
                () {
                  // TODO PHASE 2: Show privacy policy
                  _showPlaceholder(context);
                },
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXL),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              await AuthService.instance.logout();
              if (context.mounted) {
                context.go(AppConstants.loginRoute);
              }
            },
          ),
        ],
      ),
    );
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

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función disponible en Fase 2')),
    );
  }
}
