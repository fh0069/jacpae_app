import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../offers/data/repositories/offers_repository.dart';
import '../../data/models/notification_item.dart';
import '../providers/notifications_provider.dart';

/// Pantalla de Avisos/Notificaciones.
///
/// El estado vive en [NotificationsController] (Riverpod).
/// Esta pantalla solo lee estado y delega acciones al controlador.
class NotificacionesScreen extends ConsumerStatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  ConsumerState<NotificacionesScreen> createState() =>
      _NotificacionesScreenState();
}

class _NotificacionesScreenState extends ConsumerState<NotificacionesScreen> {
  // Colores del patrón visual corporativo
  static const _statusBarColor = Color(0xFFEB5C00);
  static const _appBarColor = Color(0xFFCDD1D5);

  // IDs de notificaciones tipo oferta cuya descarga está en curso.
  final Set<String> _downloadingOfferIds = {};

  // Repositorio de ofertas. null si API_BASE_URL no está configurada.
  OffersRepository? _offersRepository;

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
    final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (apiBaseUrl.isNotEmpty) {
      _offersRepository = OffersRepository.create(apiBaseUrl: apiBaseUrl);
    }
    // Trigger full load only if the controller has no data yet.
    // If HomeScreen already ran silentRefresh, items are shown immediately.
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

  // ── Action handlers ─────────────────────────────────────────────────────────

  Future<void> _onTapItem(NotificationItem item) async {
    if (item.isRead) return;
    try {
      await ref
          .read(notificationsControllerProvider.notifier)
          .markAsRead(item.id);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('No se pudo marcar como leída. Inténtalo de nuevo.');
    }
  }

  Future<void> _onLoadMore() async {
    try {
      await ref.read(notificationsControllerProvider.notifier).loadMore();
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(
        'No se pudieron cargar más notificaciones. Inténtalo de nuevo.',
      );
    }
  }

  Future<void> _onMarkAllAsRead() async {
    final failures = await ref
        .read(notificationsControllerProvider.notifier)
        .markAllAsRead();
    if (!mounted) return;
    if (failures > 0) {
      _showSnackBar('No se pudieron marcar algunas notificaciones.');
    } else {
      _showSnackBar('Todas las notificaciones marcadas como leídas.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _downloadOfferPdf(String notificationId) async {
    if (_offersRepository == null) {
      _showSnackBar('Configuración API inválida. Contacta con soporte.');
      return;
    }
    if (_downloadingOfferIds.contains(notificationId)) return;
    setState(() => _downloadingOfferIds.add(notificationId));
    try {
      await _offersRepository!.downloadCurrentOfferPdf();
      if (!mounted) return;
      _showSnackBar('Oferta descargada. Disponible en Descargas.');
      context.go(AppConstants.descargasRoute);
    } on UnauthorizedException {
      if (!mounted) return;
      _showSnackBar('Sesión caducada. Vuelve a iniciar sesión.');
    } on OfferNotAvailableException {
      if (!mounted) return;
      _showSnackBar('No hay oferta activa en este momento.');
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('No se pudo descargar la oferta. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _downloadingOfferIds.remove(notificationId));
    }
  }

  // ── Formatting ──────────────────────────────────────────────────────────────

  static String _formatDate(DateTime dt) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(dt.day)}/${pad(dt.month)}/${dt.year} '
        '${pad(dt.hour)}:${pad(dt.minute)}';
  }

  // ── Build ───────────────────────────────────────────────────────────────────

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
            _buildCustomHeader(state),
            Expanded(child: _buildContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader(NotificationsState state) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Trailing: spinner while isMarkAllLoading; otherwise always a PopupMenu.
    final bool hasUnread = state.unreadCount > 0;
    Widget trailingAction;
    if (state.isMarkAllLoading) {
      trailingAction = const SizedBox(
        width: 48,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    } else {
      trailingAction = SizedBox(
        width: 48,
        child: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          tooltip: 'Opciones',
          padding: EdgeInsets.zero,
          onSelected: (value) {
            if (value == 'mark_all') _onMarkAllAsRead();
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'mark_all',
              enabled: hasUnread,
              child: const Row(
                children: [
                  Icon(Icons.done_all),
                  SizedBox(width: 8),
                  Text('Marcar todas como leídas'),
                ],
              ),
            ),
          ],
        ),
      );
    }

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
              trailingAction,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(NotificationsState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppConstants.spacingM),
            Text('Cargando notificaciones...'),
          ],
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none,
                size: 64,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                'No hay notificaciones',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildList(state);
  }

  Widget _buildList(NotificationsState state) {
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(notificationsControllerProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: AppConstants.spacingS,
          bottom: AppConstants.spacingL,
        ),
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return _buildLoadMoreButton(state.isLoadingMore);
          }
          return _buildNotificationTile(
            state.items[index],
            state.markingIds,
            _downloadingOfferIds,
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(
    NotificationItem item,
    Set<String> markingIds,
    Set<String> downloadingOfferIds,
  ) {
    final isMarking = markingIds.contains(item.id);
    final isOferta = item.type == 'oferta';
    final isDownloadingOffer = downloadingOfferIds.contains(item.id);

    return InkWell(
      onTap: isMarking || item.isRead ? null : () => _onTapItem(item),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            bottom: BorderSide(
              color: AppColors.disabled.withValues(alpha: 0.4),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread indicator dot
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 12),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isRead ? Colors.transparent : AppColors.accent,
                ),
              ),
            ),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          item.isRead ? FontWeight.w400 : FontWeight.w600,
                      color: item.isRead
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Body (max 3 lines) or fallback
                  if (item.body.trim().isNotEmpty)
                    Text(
                      item.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: item.isRead
                            ? AppColors.textSecondary.withValues(alpha: 0.7)
                            : AppColors.textSecondary,
                      ),
                    )
                  else
                    const Text(
                      '(Sin contenido)',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.disabled,
                      ),
                    ),
                  const SizedBox(height: 6),

                  Text(
                    _formatDate(item.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.disabled,
                    ),
                  ),
                ],
              ),
            ),

            // Botón "Ver oferta PDF" — solo para type == 'oferta'
            if (isOferta)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: isDownloadingOffer
                    ? const SizedBox(
                        width: 32,
                        height: 32,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.picture_as_pdf),
                        tooltip: 'Ver oferta PDF',
                        color: AppColors.primary,
                        iconSize: 22,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: () => _downloadOfferPdf(item.id),
                      ),
              ),

            // Per-item loading indicator while marking as read
            if (isMarking)
              const Padding(
                padding: EdgeInsets.only(left: 8, top: 4),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton(bool isLoadingMore) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Center(
        child: isLoadingMore
            ? const CircularProgressIndicator()
            : OutlinedButton.icon(
                onPressed: _onLoadMore,
                icon: const Icon(Icons.expand_more),
                label: const Text('Cargar más'),
              ),
      ),
    );
  }
}
