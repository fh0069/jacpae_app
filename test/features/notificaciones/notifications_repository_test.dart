import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jacpae_app/core/network/api_exception.dart';
import 'package:jacpae_app/features/notificaciones/data/api/notifications_api.dart';
import 'package:jacpae_app/features/notificaciones/data/models/notification_item.dart';
import 'package:jacpae_app/features/notificaciones/data/repositories/notifications_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks / Fakes
// ─────────────────────────────────────────────────────────────────────────────

class MockNotificationsApi extends Mock implements NotificationsApi {}

class FakeSession extends Fake implements Session {
  @override
  final String accessToken;

  FakeSession(this.accessToken);
}

class FakeGoTrueClient extends Fake implements GoTrueClient {
  @override
  Session? currentSession;

  FakeGoTrueClient(this.currentSession);
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  @override
  final GoTrueClient auth;

  FakeSupabaseClient(this.auth);
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

NotificationItem _item({
  required String id,
  bool isRead = false,
}) {
  return NotificationItem(
    id: id,
    type: 'oferta',
    title: 'Title $id',
    body: 'Body $id',
    createdAt: DateTime(2026, 1, 1, 10, 0),
    isRead: isRead,
    data: const {},
  );
}

void main() {
  late MockNotificationsApi api;

  NotificationsRepository buildRepoWithToken(String token) {
    final session = FakeSession(token);
    final auth = FakeGoTrueClient(session);
    final supabase = FakeSupabaseClient(auth);

    return NotificationsRepository(
      notificationsApi: api,
      supabaseClient: supabase,
    );
  }

  NotificationsRepository buildRepoWithoutSession() {
    final auth = FakeGoTrueClient(null);
    final supabase = FakeSupabaseClient(auth);

    return NotificationsRepository(
      notificationsApi: api,
      supabaseClient: supabase,
    );
  }

  setUp(() {
    api = MockNotificationsApi();
  });

  group('NotificationsRepository', () {
    test(
      'fetchNotifications() éxito → items, hasMore=false, nextOffset correcto',
      () async {
        final repo = buildRepoWithToken('test-token');

        when(() => api.getNotifications(
              token: any(named: 'token'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => [_item(id: '1'), _item(id: '2')]);

        final result = await repo.fetchNotifications(limit: 50, offset: 0);

        expect(result.items.length, 2);
        expect(result.hasMore, isFalse); // 2 >= 50 → false
        expect(result.nextOffset, 2);

        verify(() => api.getNotifications(
              token: 'test-token',
              limit: 50,
              offset: 0,
            )).called(1);
      },
    );

    test(
      'fetchNotifications() sin sesión → lanza UnauthorizedException',
      () async {
        final repo = buildRepoWithoutSession();

        expect(
          () => repo.fetchNotifications(limit: 50, offset: 0),
          throwsA(isA<UnauthorizedException>()),
        );

        // No debe llamar al API si no hay token
        verifyNever(() => api.getNotifications(
              token: any(named: 'token'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ));
      },
    );

    test(
      'markAsRead() éxito → llama api.markAsRead con token correcto',
      () async {
        final repo = buildRepoWithToken('test-token');

        when(() => api.markAsRead(
              token: any(named: 'token'),
              notificationId: any(named: 'notificationId'),
            )).thenAnswer((_) async {});

        await repo.markAsRead('n1');

        verify(() => api.markAsRead(
              token: 'test-token',
              notificationId: 'n1',
            )).called(1);
      },
    );

    test(
      'markAsRead() error del API → se propaga la excepción',
      () async {
        final repo = buildRepoWithToken('test-token');

        when(() => api.markAsRead(
              token: any(named: 'token'),
              notificationId: any(named: 'notificationId'),
            )).thenThrow(const UnauthorizedException(message: 'boom'));

        expect(
          () => repo.markAsRead('n1'),
          throwsA(isA<UnauthorizedException>()),
        );

        verify(() => api.markAsRead(
              token: 'test-token',
              notificationId: 'n1',
            )).called(1);
      },
    );
  });
}
