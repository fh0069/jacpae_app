import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/notification_item.dart';
import '../../data/repositories/notifications_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable state for the notifications feature.
class NotificationsState {
  final List<NotificationItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool hasMore;
  final int offset;

  /// IDs currently being marked as read (anti double-tap per item).
  final Set<String> markingIds;

  final bool isMarkAllLoading;

  const NotificationsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.hasMore = false,
    this.offset = 0,
    this.markingIds = const {},
    this.isMarkAllLoading = false,
  });

  /// Derived: number of unread notifications.
  int get unreadCount => items.where((n) => !n.isRead).length;

  /// Returns a copy of this state with [errorMessage] cleared to null.
  /// (Cannot be done via [copyWith] since null would be ignored.)
  NotificationsState withClearedError() => NotificationsState(
        items: items,
        isLoading: isLoading,
        isLoadingMore: isLoadingMore,
        hasMore: hasMore,
        offset: offset,
        markingIds: markingIds,
        isMarkAllLoading: isMarkAllLoading,
      );

  NotificationsState copyWith({
    List<NotificationItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool? hasMore,
    int? offset,
    Set<String>? markingIds,
    bool? isMarkAllLoading,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
      markingIds: markingIds ?? this.markingIds,
      isMarkAllLoading: isMarkAllLoading ?? this.isMarkAllLoading,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────────────────────────────────────

class NotificationsController extends StateNotifier<NotificationsState> {
  final NotificationsRepository _repository;

  static const int _limit = 50;
  static const String _networkError =
      'No se pudieron cargar las notificaciones. '
      'Revisa tu conexión e inténtalo de nuevo.';

  NotificationsController(this._repository)
      : super(const NotificationsState());

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Full refresh from page 0. Sets [isLoading], clears existing items.
  Future<void> refresh() async {
    state = const NotificationsState(isLoading: true);
    await _fetchPage(fromOffset: 0, append: false);
  }

  /// Silent background refresh — does NOT set [isLoading].
  /// Used by HomeScreen on init. Failures are swallowed; badge just won't update.
  Future<void> silentRefresh() async {
    try {
      final result = await _repository.fetchNotifications(
        limit: _limit,
        offset: 0,
      );
      if (!mounted) return;
      state = NotificationsState(
        items: result.items,
        hasMore: result.hasMore,
        offset: result.nextOffset,
      );
    } catch (_) {
      // Intentionally swallowed: Home must not show any error.
    }
  }

  /// Appends the next page. Throws on failure (caller shows SnackBar).
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _repository.fetchNotifications(
        limit: _limit,
        offset: state.offset,
      );
      if (!mounted) return;
      state = state.copyWith(
        items: _deduplicate(state.items, result.items),
        hasMore: result.hasMore,
        offset: result.nextOffset,
        isLoadingMore: false,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(isLoadingMore: false);
      rethrow; // Caller (screen) shows SnackBar; existing items stay visible.
    }
  }

  /// Marks a single notification as read (optimistic).
  /// Throws on PATCH failure after reverting the item (caller shows SnackBar).
  Future<void> markAsRead(String id) async {
    final idx = state.items.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    final original = state.items[idx];
    if (original.isRead) return;
    if (state.markingIds.contains(id)) return; // Guard: already in-flight

    // Optimistic: mark as read + register as in-flight
    state = state.copyWith(
      items: [...state.items]..[idx] = original.copyWith(isRead: true),
      markingIds: {...state.markingIds, id},
    );

    try {
      await _repository.markAsRead(id);
    } catch (_) {
      // Revert item
      if (mounted) {
        final revertIdx = state.items.indexWhere((n) => n.id == id);
        if (revertIdx != -1) {
          state = state.copyWith(
            items: [...state.items]..[revertIdx] = original,
          );
        }
      }
      rethrow; // Caller shows SnackBar
    } finally {
      // Always clear in-flight flag (even after rethrow)
      if (mounted) {
        state = state.copyWith(
          markingIds: state.markingIds.difference({id}),
        );
      }
    }
  }

  /// Marks all unread items as read (optimistic batch PATCH).
  ///
  /// Returns the count of failed items.
  /// Caller shows SnackBar if count > 0.
  /// Failed items are individually reverted.
  Future<int> markAllAsRead() async {
    final unread = state.items.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return 0;

    // Optimistic: mark everything as read in memory
    state = state.copyWith(
      isMarkAllLoading: true,
      items: state.items
          .map((n) => n.isRead ? n : n.copyWith(isRead: true))
          .toList(),
    );

    final failed = <NotificationItem>[];
    for (final item in unread) {
      try {
        await _repository.markAsRead(item.id);
      } catch (_) {
        failed.add(item);
      }
    }

    if (!mounted) return failed.length;

    if (failed.isNotEmpty) {
      // Revert only the failed items
      final failedIds = {for (final f in failed) f.id};
      state = state.copyWith(
        items: state.items
            .map((n) => failedIds.contains(n.id) ? n.copyWith(isRead: false) : n)
            .toList(),
      );
    }

    state = state.copyWith(isMarkAllLoading: false);
    return failed.length;
  }

  // ── Private ────────────────────────────────────────────────────────────────

  Future<void> _fetchPage({
    required int fromOffset,
    required bool append,
  }) async {
    try {
      final result = await _repository.fetchNotifications(
        limit: _limit,
        offset: fromOffset,
      );
      if (!mounted) return;
      final newItems =
          append ? _deduplicate(state.items, result.items) : result.items;
      state = NotificationsState(
        items: newItems,
        hasMore: result.hasMore,
        offset: result.nextOffset,
        markingIds: state.markingIds, // preserve in-flight marks
      );
    } on UnauthorizedException {
      if (!mounted) return;
      state = const NotificationsState(
        errorMessage: 'Sesión caducada. Vuelve a iniciar sesión.',
      );
    } on ForbiddenException {
      if (!mounted) return;
      state = const NotificationsState(
        errorMessage: 'No tienes permisos para ver estas notificaciones.',
      );
    } on ServiceUnavailableException {
      if (!mounted) return;
      state = const NotificationsState(
        errorMessage: 'Servicio temporalmente no disponible.',
      );
    } on SocketException {
      if (!mounted) return;
      state = const NotificationsState(errorMessage: _networkError);
    } on ApiException catch (e) {
      if (!mounted) return;
      state = NotificationsState(errorMessage: e.message);
    } catch (_) {
      if (!mounted) return;
      state = const NotificationsState(errorMessage: _networkError);
    }
  }

  /// Appends [incoming] to [existing], deduplicating by id.
  static List<NotificationItem> _deduplicate(
    List<NotificationItem> existing,
    List<NotificationItem> incoming,
  ) {
    final existingIds = {for (final n in existing) n.id};
    return [...existing, ...incoming.where((n) => !existingIds.contains(n.id))];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Global controller for all notification state.
///
/// Kept alive for the duration of the app so HomeScreen and
/// NotificacionesScreen share the same instance.
final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
  final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';
  return NotificationsController(
    NotificationsRepository.create(apiBaseUrl: apiBaseUrl),
  );
});

/// Derived: count of unread notifications for badge display.
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsControllerProvider).unreadCount;
});
