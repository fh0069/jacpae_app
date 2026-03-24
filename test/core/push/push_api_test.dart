import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:jacpae_app/core/network/api_client.dart';
import 'package:jacpae_app/core/network/api_exception.dart';
import 'package:jacpae_app/core/push/push_api.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks
// ─────────────────────────────────────────────────────────────────────────────

class MockApiClient extends Mock implements ApiClient {}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockApiClient apiClient;
  late PushApi pushApi;

  setUp(() {
    apiClient = MockApiClient();
    pushApi = PushApi(apiClient);
  });

  group('PushApi', () {
    test(
      'registerDevice() → llama a ApiClient.post con path, token, y body correctos',
      () async {
        when(() => apiClient.post(
              any(),
              token: any(named: 'token'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => {'status': 'registered'});

        await pushApi.registerDevice(
          token: 'jwt-token',
          fcmToken: 'fcm-token-abc',
          platform: 'android',
        );

        verify(() => apiClient.post(
              '/devices/register',
              token: 'jwt-token',
              body: {
                'device_token': 'fcm-token-abc',
                'platform': 'android',
              },
            )).called(1);
      },
    );

    test(
      'registerDevice() cuando ApiClient.post lanza UnauthorizedException → se propaga',
      () async {
        when(() => apiClient.post(
              any(),
              token: any(named: 'token'),
              body: any(named: 'body'),
            )).thenThrow(const UnauthorizedException(message: 'boom'));

        await expectLater(
          pushApi.registerDevice(
            token: 'jwt-token',
            fcmToken: 'fcm-token-abc',
            platform: 'android',
          ),
          throwsA(isA<UnauthorizedException>()),
        );
      },
    );

    test(
      'registerDevice() cuando ApiClient.post lanza ApiException → se propaga',
      () async {
        when(() => apiClient.post(
              any(),
              token: any(named: 'token'),
              body: any(named: 'body'),
            )).thenThrow(const ServiceUnavailableException());

        await expectLater(
          pushApi.registerDevice(
            token: 'jwt-token',
            fcmToken: 'fcm-token-abc',
            platform: 'android',
          ),
          throwsA(isA<ServiceUnavailableException>()),
        );
      },
    );
  });
}
