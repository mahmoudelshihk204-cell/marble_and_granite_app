import 'dart:async';
import 'dart:convert';

import 'package:backend/services/topsoftware_api_client.dart';
import 'package:backend/services/topsoftware_auth_api.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

class SlowMockClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await Future<void>.delayed(const Duration(seconds: 31));

    return http.StreamedResponse(Stream.value(utf8.encode('{}')), 200);
  }
}

void main() {
  group('TopSoftware API Timeout Tests', () {
    test(
      'Login should throw TimeoutException after 30 seconds',
      () async {
        final apiClient = TopSoftwareApiClient(
          baseUrl: 'http://127.0.0.1:8086/api/v1/topsoftware',
          username: 'test',
          password: 'test',
          schema: 'EXP2013',
          client: SlowMockClient(),
        );

        try {
          expect(() => apiClient.login(), throwsA(isA<TimeoutException>()));
        } finally {
          apiClient.close();
        }
      },
      timeout: const Timeout(Duration(seconds: 40)),
    );

    test(
      'Login route should return HTTP 504 on timeout',
      () async {
        final app = TopSoftwareAuthApi(
          clientFactory:
              ({
                required String username,
                required String password,
                required String token,
              }) {
                return TopSoftwareApiClient(
                  baseUrl: 'http://127.0.0.1:8086/api/v1/topsoftware',
                  username: username,
                  password: password,
                  schema: 'EXP2013',
                  client: SlowMockClient(),
                );
              },
        );

        final handler = app.router.call;

        final response = await handler(
          Request(
            'POST',
            Uri.parse('http://localhost/api/auth/login'),
            body: jsonEncode({
              'username': 'test',
              'password': 'test',
              'token': 'test-token',
            }),
          ),
        );

        expect(response.statusCode, 504);

        final responseBody = jsonDecode(await response.readAsString());

        expect(responseBody['success'], false);
        expect(
          responseBody['message'],
          'TopSoftware server timed out. Please try again later.',
        );
      },
      timeout: const Timeout(Duration(seconds: 40)),
    );
  });
}
