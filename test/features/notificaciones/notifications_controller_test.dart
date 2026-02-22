import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:jacpae_app/features/notificaciones/data/models/notification_item.dart';
import 'package:jacpae_app/features/notificaciones/data/repositories/notifications_repository.dart';
import 'package:jacpae_app/features/notificaciones/presentation/providers/notifications_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock
// ─────────────────────────────────────────────────────────────────────────────

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

// ─────────────────────────────────────────────────────────────────────────────
// Helper factory
// ─────────────────────────────────────────────────────────────────────────────

NotificationItem _item({String id = '1', bool isRead = false}) =>
    NotificationItem(
      id: id,
      type: 'giro',
      title: 'Título $id',
      body: 'Cuerpo $id',
      createdAt: DateTime(2026, 1, 1),
      isRead: isRead,
      data: const {},
    );

NotificationsResult _result(List<NotificationItem> items) =>
    NotificationsResult(
      items: items,
      hasMore: false,
      nextOffset: items.length,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockNotificationsRepository repo;
  late NotificationsController ctrl;

  setUp(() {
    repo = MockNotificationsRepository();
    ctrl = NotificationsController(repo);
  });

  tearDown(() => ctrl.dispose());

  // ── Caso 1 ──────────────────────────────────────────────────────────────────

  test(
    'refresh() éxito → items cargados, isLoading=false, errorMessage=null',
    () async {
      final items = [_item(id: '1'), _item(id: '2')];
      when(
        () => repo.fetchNotifications(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => _result(items));

      await ctrl.refresh();

      expect(ctrl.state.isLoading, isFalse);
      expect(ctrl.state.errorMessage, isNull);
      expect(ctrl.state.items, equals(items));
    },
  );

  // ── Caso 2 ──────────────────────────────────────────────────────────────────

  test(
    'refresh() fallo de red → errorMessage no nulo, isLoading=false, items vacíos',
    () async {
      when(
        () => repo.fetchNotifications(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenThrow(Exception('sin conexión'));

      await ctrl.refresh();

      expect(ctrl.state.isLoading, isFalse);
      expect(ctrl.state.errorMessage, isNotNull);
      expect(ctrl.state.items, isEmpty);
    },
  );

  // ── Caso 3 ──────────────────────────────────────────────────────────────────

  test(
    'markAsRead() éxito → item marcado como leído y markingIds vacío al terminar',
    () async {
      // Pre-cargar estado con un item no leído
      when(
        () => repo.fetchNotifications(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => _result([_item(id: '42', isRead: false)]));
      await ctrl.refresh();

      when(() => repo.markAsRead('42')).thenAnswer((_) async {});

      await ctrl.markAsRead('42');

      expect(ctrl.state.items.first.isRead, isTrue);
      expect(ctrl.state.markingIds, isEmpty);
    },
  );

  // ── Caso 4 ──────────────────────────────────────────────────────────────────

  test(
    'markAsRead() fallo → item revertido a isRead=false, markingIds vacío, excepción re-lanzada',
    () async {
      // Pre-cargar estado con un item no leído
      when(
        () => repo.fetchNotifications(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => _result([_item(id: '99', isRead: false)]));
      await ctrl.refresh();

      when(() => repo.markAsRead('99')).thenThrow(Exception('PATCH 500'));

      await expectLater(ctrl.markAsRead('99'), throwsException);

      expect(ctrl.state.items.first.isRead, isFalse); // revertido
      expect(ctrl.state.markingIds, isEmpty);
    },
  );

  // ── Caso 5 ──────────────────────────────────────────────────────────────────

  test(
    'loadMore() appends items and updates offset correctly',
    () async {
      // Página 1: 1 item, hasMore=true, nextOffset=1
      when(
        () => repo.fetchNotifications(
          limit: any(named: 'limit'),
          offset: 0,
        ),
      ).thenAnswer(
        (_) async => NotificationsResult(
          items: [_item(id: '1')],
          hasMore: true,
          nextOffset: 1,
        ),
      );

      // Página 2: 1 item nuevo, hasMore=false, nextOffset=2
      when(
        () => repo.fetchNotifications(
          limit: any(named: 'limit'),
          offset: 1,
        ),
      ).thenAnswer(
        (_) async => NotificationsResult(
          items: [_item(id: '2')],
          hasMore: false,
          nextOffset: 2,
        ),
      );

      // Estado inicial real vía refresh()
      await ctrl.refresh();
      expect(ctrl.state.items.length, 1);
      expect(ctrl.state.hasMore, isTrue);

      await ctrl.loadMore();

      expect(ctrl.state.items.length, 2);           // append, no replace
      expect(ctrl.state.items[1].id, '2');           // nuevo item al final
      expect(ctrl.state.offset, 2);                  // nextOffset aplicado
      expect(ctrl.state.hasMore, isFalse);           // segunda página sin más
      expect(ctrl.state.isLoadingMore, isFalse);     // reset correcto
    },
  );

  // ── Caso 6 ──────────────────────────────────────────────────────────────────

  test(
    'loadMore() fallo → re-lanza excepción, isLoadingMore=false, items intactos',
    () async {
      // Página 1: estado real vía refresh()
      when(
        () => repo.fetchNotifications(
          limit: any(named: 'limit'),
          offset: 0,
        ),
      ).thenAnswer(
        (_) async => NotificationsResult(
          items: [_item(id: '1')],
          hasMore: true,
          nextOffset: 1,
        ),
      );

      // Página 2: lanza excepción
      when(
        () => repo.fetchNotifications(
          limit: any(named: 'limit'),
          offset: 1,
        ),
      ).thenThrow(Exception('boom'));

      await ctrl.refresh();

      await expectLater(ctrl.loadMore(), throwsException);

      expect(ctrl.state.isLoadingMore, isFalse);      // catch resetea el flag
      expect(ctrl.state.items.length, 1);              // items no se vacían
      expect(ctrl.state.items.first.id, '1');          // item original intacto
    },
  );
}
