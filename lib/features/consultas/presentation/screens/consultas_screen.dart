import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';

/// Consultas menu screen with navigation options
/// Shows three categories: Facturas (enabled), Albaranes (disabled), Pedidos (disabled)
class ConsultasScreen extends StatelessWidget {
  const ConsultasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const CustomAppBar(title: 'Consultas'),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        children: [
          // Header text
          Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacingL),
            child: Text(
              'Selecciona el tipo de documento que deseas consultar',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),

          // Facturas - Enabled
          _ConsultaOptionCard(
            icon: Icons.receipt_long,
            title: 'Facturas',
            subtitle: 'Consulta tus facturas emitidas',
            enabled: true,
            onTap: () => context.push(AppConstants.facturasRoute),
          ),

          const SizedBox(height: AppConstants.spacingM),

          // Albaranes - Disabled
          _ConsultaOptionCard(
            icon: Icons.local_shipping,
            title: 'Albaranes',
            subtitle: 'Consulta tus albaranes de entrega',
            enabled: false,
            badge: 'Próximamente',
            onTap: () => _showComingSoonSnackbar(context, 'Albaranes'),
          ),

          const SizedBox(height: AppConstants.spacingM),

          // Pedidos - Disabled
          _ConsultaOptionCard(
            icon: Icons.shopping_cart,
            title: 'Pedidos',
            subtitle: 'Consulta el estado de tus pedidos',
            enabled: false,
            badge: 'Próximamente',
            onTap: () => _showComingSoonSnackbar(context, 'Pedidos'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackbar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature estará disponible en la próxima fase'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Card widget for each consultation option
class _ConsultaOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final String? badge;
  final VoidCallback onTap;

  const _ConsultaOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = enabled
        ? Theme.of(context).cardColor
        : Theme.of(context).cardColor.withOpacity(0.6);

    final iconColor = enabled ? AppColors.primary : AppColors.textSecondary;
    final textColor = enabled ? null : AppColors.textSecondary;

    return Card(
      color: cardColor,
      elevation: enabled ? 2 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: iconColor,
                ),
              ),

              const SizedBox(width: AppConstants.spacingM),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: AppConstants.spacingS),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacingS,
                              vertical: AppConstants.spacingXS,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.2),
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusS),
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.info,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textColor ?? AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                enabled ? Icons.arrow_forward_ios : Icons.lock_outline,
                size: 16,
                color: enabled ? AppColors.textSecondary : AppColors.textSecondary.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
