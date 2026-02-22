import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:jacpae_app/core/network/api_client.dart';
import 'package:jacpae_app/core/network/api_exception.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks
// ─────────────────────────────────────────────────────────────────────────────

class MockHttpClient extends Mock implements http.Client {}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockHttpClient mockClient;
  late ApiClient apiClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://example.com'));
  });

  setUp(() {
    mockClient = MockHttpClient();
    apiClient = ApiClient(
      baseUrl: 'http://api.example.com',
      httpClient: mockClient,
    );
  });

  // ── Caso 1 ──────────────────────────────────────────────────────────────────

  test(
    'get() 200 → devuelve JSON decodificado',
    () async {
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('{"key":"value"}', 200));

      final result = await apiClient.get('/test', token: 'abc');

      expect(result, {'key': 'value'});
    },
  );

  // ── Caso 2 ──────────────────────────────────────────────────────────────────

  test(
    'get() 401 → lanza UnauthorizedException',
    () async {
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('', 401));

      await expectLater(
        apiClient.get('/test', token: 'bad-token'),
        throwsA(isA<UnauthorizedException>()),
      );
    },
  );

  // ── Caso 3 ──────────────────────────────────────────────────────────────────

  test(
    'get() 403 → lanza ForbiddenException',
    () async {
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer(
        (_) async => http.Response('{"detail":"sin perfil"}', 403),
      );

      await expectLater(
        apiClient.get('/test', token: 'abc'),
        throwsA(isA<ForbiddenException>()),
      );
    },
  );

  // ── Caso 4 ──────────────────────────────────────────────────────────────────

  test(
    'patch() 204 body vacío → devuelve null',
    () async {
      when(
        () => mockClient.patch(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('', 204));

      final result = await apiClient.patch('/test', token: 'abc');

      expect(result, isNull);
    },
  );

  // ── Caso 5 ──────────────────────────────────────────────────────────────────

  test(
    'getBytes() 200 → devuelve bytes correctos',
    () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);

      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response.bytes(bytes, 200));

      final result = await apiClient.getBytes('/test', token: 'abc');

      expect(result, equals(bytes));
    },
  );
}
