import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jacpae_app/core/network/api_exception.dart';
import 'package:jacpae_app/features/offers/data/api/offers_api.dart';
import 'package:jacpae_app/features/offers/data/repositories/offers_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks / Fakes
// ─────────────────────────────────────────────────────────────────────────────

class MockOffersApi extends Mock implements OffersApi {}

class FakeSession extends Fake implements Session {
  final String _token;
  FakeSession(this._token);

  @override
  String get accessToken => _token;
}

class FakeGoTrueClient extends Fake implements GoTrueClient {
  final Session? _session;
  FakeGoTrueClient(this._session);

  @override
  Session? get currentSession => _session;
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  final GoTrueClient _auth;
  FakeSupabaseClient(this._auth);

  @override
  GoTrueClient get auth => _auth;
}

/// Intercepta getApplicationDocumentsDirectory() para evitar MissingPluginException
class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async =>
      Directory.systemTemp.path;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockOffersApi api;

  setUpAll(() {
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });

  setUp(() {
    api = MockOffersApi();
  });

  OffersRepository buildRepoWithToken(String token) {
    final auth = FakeGoTrueClient(FakeSession(token));
    final supabaseClient = FakeSupabaseClient(auth);
    return OffersRepository(
      offersApi: api,
      supabaseClient: supabaseClient,
    );
  }

  OffersRepository buildRepoNoSession() {
    final auth = FakeGoTrueClient(null);
    final supabaseClient = FakeSupabaseClient(auth);
    return OffersRepository(
      offersApi: api,
      supabaseClient: supabaseClient,
    );
  }

  // ── Caso 1 ──────────────────────────────────────────────────────────────────

  test(
    'downloadCurrentOfferPdf() éxito → devuelve File y llama API con token',
    () async {
      final repo = buildRepoWithToken('test-token');

      // token es parámetro posicional en OffersApi.downloadCurrentOfferPdf(String token)
      when(() => api.downloadCurrentOfferPdf('test-token'))
          .thenAnswer((_) async => Uint8List.fromList([1, 2, 3, 4]));

      final file = await repo.downloadCurrentOfferPdf();

      expect(file, isA<File>());
      expect(await file.exists(), isTrue);
      expect(await file.length(), greaterThan(0));

      verify(() => api.downloadCurrentOfferPdf('test-token')).called(1);
    },
  );

  // ── Caso 2 ──────────────────────────────────────────────────────────────────

  test(
    'downloadCurrentOfferPdf() sin sesión → lanza UnauthorizedException',
    () async {
      final repo = buildRepoNoSession();

      await expectLater(
        repo.downloadCurrentOfferPdf(),
        throwsA(isA<UnauthorizedException>()),
      );

      verifyNever(() => api.downloadCurrentOfferPdf(any()));
    },
  );

  // ── Caso 3 ──────────────────────────────────────────────────────────────────

  test(
    'downloadCurrentOfferPdf() oferta no disponible → propaga OfferNotAvailableException',
    () async {
      final repo = buildRepoWithToken('test-token');

      // OfferNotAvailableException no acepta parámetro message en su constructor
      when(() => api.downloadCurrentOfferPdf('test-token'))
          .thenThrow(const OfferNotAvailableException());

      await expectLater(
        repo.downloadCurrentOfferPdf(),
        throwsA(isA<OfferNotAvailableException>()),
      );

      verify(() => api.downloadCurrentOfferPdf('test-token')).called(1);
    },
  );
}
