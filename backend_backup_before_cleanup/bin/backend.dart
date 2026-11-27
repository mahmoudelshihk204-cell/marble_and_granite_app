import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:backend/services/topsoftware_auth_api.dart';

Future<void> main() async {
  HttpServer? server;

  try {
    // إنشاء Login API المستقل عن Oracle المحلي.
    final authApi = TopSoftwareAuthApi();

    // إعداد استقبال طلبات HTTP.
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addHandler(authApi.router.call);

    // تشغيل السيرفر على Port 8080.
    server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);

    print('======================================');
    print('TopSoftware Backend is running!');
    print('Address: http://localhost:${server.port}');
    print('Login API: POST /api/auth/login');
    print('Press Ctrl + C to stop the server.');
    print('======================================');

    // انتظار Ctrl + C.
    await ProcessSignal.sigint.watch().first;

    print('\nShutdown signal received...');
  } catch (error, stackTrace) {
    print('Server error: $error');
    print(stackTrace);
  } finally {
    // إغلاق السيرفر عند الإيقاف.
    if (server != null) {
      await server.close();
      print('HTTP Server closed.');
    }
  }
}
