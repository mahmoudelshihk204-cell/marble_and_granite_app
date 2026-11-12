
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:backend/database/oracle_connection.dart';

import 'package:backend/repositories/legacy_item_repository.dart';
import 'package:backend/repositories/legacy_balance_repository.dart';
import 'package:backend/repositories/legacy_unit_repository.dart';
import 'package:backend/repositories/legacy_block_repository.dart';

import 'package:backend/services/legacy_item_api.dart';

Future<void> main() async {
  // إنشاء الاتصال بقاعدة بيانات Oracle.
  final database = OracleDatabase();

  try {
    print('Connecting to Oracle...');

    final connection = await database.connect();

    print('Oracle connected successfully!');

    // إنشاء Repositories وربطها باتصال قاعدة البيانات.
    final itemRepository = LegacyItemRepository(
      connection: connection,
    );

    final balanceRepository = LegacyBalanceRepository(
      connection: connection,
    );

    final unitRepository = LegacyUnitRepository(
      connection: connection,
    );

    // Repository الخاص بالبلوكات.
    final blockRepository = LegacyBlockRepository(
      connection: connection,
    );

    // إنشاء API وربطه بجميع Repositories.
    final legacyItemApi = LegacyItemApi(
      itemRepository: itemRepository,
      balanceRepository: balanceRepository,
      unitRepository: unitRepository,
      blockRepository: blockRepository,
    );

    // إضافة Middleware لتسجيل طلبات HTTP.
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addHandler(legacyItemApi.router.call);

    // تشغيل السيرفر على Port 8080.
    final server = await shelf_io.serve(
      handler,
      InternetAddress.anyIPv4,
      8080,
    );

    print('======================================');
    print('Legacy API Server is running!');
    print('Address: http://localhost:${server.port}');
    print('======================================');

  } catch (error, stackTrace) {
    print('Server startup failed: $error');
    print(stackTrace);

    await database.close();
  }
}
