import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:backend/services/topsoftware_auth_api.dart';

// الحد الأقصى للطلبات من نفس عنوان IP.
const int _maxRequests = 60;
const int _maxTrackedIps = 10000;

// مدة احتساب الطلبات.
const Duration _rateLimitWindow = Duration(minutes: 1);

// تخزين عدد الطلبات ووقت بداية الفترة لكل IP.
final Map<String, _RateLimitEntry> _requestCounts = {};

class _RateLimitEntry {
  int count;
  DateTime windowStart;

  _RateLimitEntry({required this.count, required this.windowStart});
}

// Middleware لتحديد عدد الطلبات لكل IP.
Middleware rateLimitMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final connectionInfo =
          request.context['shelf.io.connection_info'] as HttpConnectionInfo?;

      final ipAddress = connectionInfo?.remoteAddress.address ?? 'unknown';
      final now = DateTime.now();

      // تنظيف العناوين التي انتهت فترة احتسابها.
      _requestCounts.removeWhere(
        (_, entry) => now.difference(entry.windowStart) >= _rateLimitWindow,
      );

      final entry = _requestCounts[ipAddress];
      if (entry == null && _requestCounts.length >= _maxTrackedIps) {
        return Response(
          503,
          body: jsonEncode({
            'success': false,
            'message': 'Server is temporarily busy. Please try again later.',
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

    final handler = Pipeline()
        .addMiddleware(rateLimitMiddleware())
        .addHandler(authApi.router.call);

    server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);

    print('======================================');
    print('TopSoftware Backend is running!');
    print('Address: http://localhost:${server.port}');
    print('Rate limit: $_maxRequests requests per minute per IP');
    print('Press Ctrl + C to stop the server.');
    print('======================================');

    await ProcessSignal.sigint.watch().first;

    print('\nShutdown signal received...');
  } catch (_) {
    print('Backend server failed to start or stopped unexpectedly.');
  } finally {
    if (server != null) {
      await server.close();
      print('HTTP Server closed.');
    }
  }
}
