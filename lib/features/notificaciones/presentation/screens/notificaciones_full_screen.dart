import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../providers/notifications_provider.dart';

/// Legacy notifications screen.
/// Not used by the current router configuration.
class NotificacionesFullScreen extends ConsumerStatefulWidget {
  const NotificacionesFullScreen({super.key});

  @override
  ConsumerState<NotificacionesFullScreen> createState() =>
      _NotificacionesFullScreenState();
}

class _NotificacionesFullScreenState
    extends ConsumerState<NotificacionesFullScreen> {
  static const _statusBarColor = Color(0xFFEB5C00);
  static const _appBarColor = Color(0xFFCDD1D5);

  static const _lightStatusBarStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  static const _defaultStatusBarStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(_lightStatusBarStyle);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final s = ref.read(notificationsControllerProvider);
      if (s.items.isEmpty && !s.isLoading && s.errorMessage == null) {
        ref.read(notificationsControllerProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(_defaultStatusBarStyle);
    super.dispose();
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'info':
        return AppColors.info;
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      case 'success':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'info':
        return Icons.info_outline;
      case 'warning':
        return Icons.warning_amber;
      case 'error':
        return Icons.error_outline;
      case 'success':
        return Icons.check_circle_outline;
      default:
        return Icons.notifications;
    }
  }

  Widget _buildCustomHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: statusBarHeight,
          color: _statusBarColor,
        ),
        Container(
          width: double.infinity,
          height: kToolbarHeight,
          color: _appBarColor,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Text(
                'Notificaciones',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _lightStatusBarStyle,
      child: AppScaffold(
        bottomNavIndex: 2,
        showInfoBar: false,
        body: Column(
          children: [
            _buildCustomHeader(context),
            Expanded(child: _buildContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(NotificationsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppConstants.spacingM),
              Text(state.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: AppConstants.spacingL),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(notificationsControllerProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.items.isEmpty) {
      return const Center(child: Text('No hay notificaciones'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
          color: item.isRead
              ? null
              : AppColors.primary.withValues(alpha: 0.05),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  _getTipoColor(item.type).withValues(alpha: 0.2),
              child: Icon(
                _getTipoIcon(item.type),
                color: _getTipoColor(item.type),
              ),
            ),
            title: Row(
              children: [
                Expanded(child: Text(item.title)),
                if (!item.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  item.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  _formatFecha(item.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Detalle disponible en Fase 2'),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatFecha(DateTime fecha) {
    final now = DateTime.now();
    final difference = now.difference(fecha);

    if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }
}
