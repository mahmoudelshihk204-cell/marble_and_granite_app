import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:backend/services/topsoftware_auth_api.dart';

const int _maxRequests = 60;
const int _maxTrackedIps = 10000;
const Duration _rateLimitWindow = Duration(minutes: 1);

final Map<String, _RateLimitEntry> _requestCounts = {};

class _RateLimitEntry {
  int count;
  DateTime windowStart;

  _RateLimitEntry({required this.count, required this.windowStart});
}

Middleware rateLimitMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final connectionInfo =
          request.context['shelf.io.connection_info'] as HttpConnectionInfo?;

      final ipAddress = connectionInfo?.remoteAddress.address ?? 'unknown';
      final now = DateTime.now();

      _requestCounts.removeWhere(
        (_, entry) => now.difference(entry.windowStart) >= _rateLimitWindow,
      );

      final entry = _requestCounts[ipAddress];

      if (entry == null && _requestCounts.length >= _maxTrackedIps) {
        return Response(
          503,
          body: jsonEncode({
            'success': false,
            'message': 'Server is temporarily busy.',
          }),
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }

      if (entry == null) {
        _requestCounts[ipAddress] = _RateLimitEntry(count: 1, windowStart: now);
      } else {
        if (entry.count >= _maxRequests) {
          return Response(
            429,
            body: jsonEncode({
              'success': false,
              'message': 'Too many requests. Please try again later.',
            }),
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }

        entry.count++;
      }

      return innerHandler(request);
    };
  };
}

Future<void> main() async {
  HttpServer? server;

  try {
    final authApi = TopSoftwareAuthApi();

    final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;

    final handler = Pipeline().addMiddleware(rateLimitMiddleware()).addHandler((
      request,
    ) async {
      // فحص صحة السيرفر بواسطة Render.
      if (request.method == 'GET' && request.url.path == 'health') {
        return Response.ok(
          jsonEncode({'success': true, 'message': 'Backend is healthy'}),
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }

      print('REQUEST: ${request.method} ${request.url}');

      final response = await authApi.router.call(request);

      print('RESPONSE: ${response.statusCode}');

      return response;
    });

    server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);

    print('======================================');
    print('TopSoftware Backend is running!');
    print('Address: http://0.0.0.0:${server.port}');
    print('Health Check: /health');
    print('Rate limit: $_maxRequests requests per minute per IP');
    print('======================================');

    await Future.any([
      ProcessSignal.sigint.watch().first,
      ProcessSignal.sigterm.watch().first,
    ]);

    print('Shutdown signal received...');
  } catch (error, stackTrace) {
    print('BACKEND STARTUP/RUNTIME ERROR: $error');
    print(stackTrace);
    rethrow;
  } finally {
    if (server != null) {
      await server.close(force: true);
      print('HTTP Server closed.');
    }
  }
}
