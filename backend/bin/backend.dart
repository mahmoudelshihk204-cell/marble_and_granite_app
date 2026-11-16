import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:backend/database/oracle_connection.dart';
import 'package:backend/database/oracle_operation_queue.dart';

import 'package:backend/repositories/legacy_item_repository.dart';
import 'package:backend/repositories/legacy_balance_repository.dart';
import 'package:backend/repositories/legacy_unit_repository.dart';
import 'package:backend/repositories/legacy_block_repository.dart';

import 'package:backend/services/legacy_item_api.dart';

Future<void> main() async {
  // مسؤول إدارة اتصال Oracle.
  final database = OracleDatabase();

  // هنحتفظ بمرجع السيرفر علشان نقدر نقفله وقت الإيقاف.
  HttpServer? server;

  try {
    // فتح اتصال واحد بقاعدة بيانات Oracle.
    final connection = await database.connect();

    // إنشاء Queue واحدة مشتركة لكل عمليات Oracle.
    final oracleQueue = OracleOperationQueue();

    // إنشاء Repositories وربطها بنفس الاتصال ونفس الطابور.
    final itemRepository = LegacyItemRepository(
      connection: connection,
      queue: oracleQueue,
    );

    final balanceRepository = LegacyBalanceRepository(
      connection: connection,
      queue: oracleQueue,
    );

    final unitRepository = LegacyUnitRepository(
      connection: connection,
      queue: oracleQueue,
    );

    final blockRepository = LegacyBlockRepository(
      connection: connection,
      queue: oracleQueue,
    );

    // إنشاء API وربطه بجميع Repositories.
    final legacyItemApi = LegacyItemApi(
      itemRepository: itemRepository,
      balanceRepository: balanceRepository,
      unitRepository: unitRepository,
      blockRepository: blockRepository,
    );

    // إعداد استقبال طلبات HTTP وتسجيلها.
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addHandler(legacyItemApi.router.call);

    // تشغيل السيرفر على Port 8080.
    server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);

    print('======================================');
    print('Legacy API Server is running!');
    print('Address: http://localhost:${server.port}');
    print('Press Ctrl + C to stop the server.');
    print('======================================');

    // انتظار إشارة Ctrl + C من المستخدم.
    await ProcessSignal.sigint.watch().first;

    print('\nShutdown signal received...');
  } catch (error, stackTrace) {
    print('Server error: $error');
    print(stackTrace);
  } finally {
    // إغلاق السيرفر أولاً لمنع استقبال طلبات جديدة.
    if (server != null) {
      await server.close();
      print('HTTP Server closed.');
    }

    // إغلاق اتصال Oracle بعد إغلاق السيرفر.
    await database.close();
  }
}
