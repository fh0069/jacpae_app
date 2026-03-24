import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jacpae_app/core/network/api_exception.dart';
import 'package:jacpae_app/core/push/push_api.dart';
import 'package:jacpae_app/core/push/push_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks / Fakes
// ─────────────────────────────────────────────────────────────────────────────

class MockPushApi extends Mock implements PushApi {}

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

PushRepository _buildRepoWithToken(MockPushApi api, String token) {
  final session = FakeSession(token);
  final auth = FakeGoTrueClient(session);
  final supabase = FakeSupabaseClient(auth);
  return PushRepository(pushApi: api, supabaseClient: supabase);
}

PushRepository _buildRepoWithoutSession(MockPushApi api) {
  final auth = FakeGoTrueClient(null);
  final supabase = FakeSupabaseClient(auth);
  return PushRepository(pushApi: api, supabaseClient: supabase);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockPushApi api;

  setUp(() {
    api = MockPushApi();
  });

  group('PushRepository', () {
    test(
      'registerDevice() con sesión activa → llama api.registerDevice con JWT y fcmToken correctos',
      () async {
        final repo = _buildRepoWithToken(api, 'test-jwt');

        when(() => api.registerDevice(
              token: any(named: 'token'),
              fcmToken: any(named: 'fcmToken'),
              platform: any(named: 'platform'),
            )).thenAnswer((_) async {});

        await repo.registerDevice(fcmToken: 'fcm-abc');

        verify(() => api.registerDevice(
              token: 'test-jwt',
              fcmToken: 'fcm-abc',
              platform: 'android', // valor real en entorno de test (no iOS)
            )).called(1);
      },
    );

    test(
      'registerDevice() sin sesión activa → lanza UnauthorizedException sin llamar al API',
      () async {
        final repo = _buildRepoWithoutSession(api);

        expect(
          () => repo.registerDevice(fcmToken: 'fcm-abc'),
          throwsA(isA<UnauthorizedException>()),
        );

        verifyNever(() => api.registerDevice(
              token: any(named: 'token'),
              fcmToken: any(named: 'fcmToken'),
              platform: any(named: 'platform'),
            ));
      },
    );

    test(
      'registerDevice() cuando api lanza ApiException → se propaga la excepción',
      () async {
        final repo = _buildRepoWithToken(api, 'test-jwt');

        when(() => api.registerDevice(
              token: any(named: 'token'),
              fcmToken: any(named: 'fcmToken'),
              platform: any(named: 'platform'),
            )).thenThrow(const ServiceUnavailableException());

        await expectLater(
          repo.registerDevice(fcmToken: 'fcm-abc'),
          throwsA(isA<ServiceUnavailableException>()),
        );
      },
    );
  });
}
