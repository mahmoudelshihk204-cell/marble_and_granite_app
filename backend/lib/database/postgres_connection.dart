
import 'dart:io';

import 'package:postgres/postgres.dart';

class PostgresDatabase {
  Connection? _connection;

  // قراءة بيانات الاتصال من Environment Variables
  Future<Connection> connect() async {
    print('Connecting to Supabase PostgreSQL...');

    final endpoint = Endpoint(
      host: Platform.environment['PG_HOST'] ?? '',
      port: int.tryParse(
            Platform.environment['PG_PORT'] ?? '5432',
          ) ??
          5432,
      database: Platform.environment['PG_DATABASE'] ?? 'postgres',
      username: Platform.environment['PG_USER'] ?? '',
      password: Platform.environment['PG_PASSWORD'] ?? '',
    );

    // الاتصال مشفر باستخدام SSL
    _connection = await Connection.open(
      endpoint,
      settings: const ConnectionSettings(
        sslMode: SslMode.require,
      ),
    );

    print('PostgreSQL connected successfully!');

    return _connection!;
  }

  // إغلاق الاتصال بعد انتهاء الاختبار
  Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;

      print('PostgreSQL connection closed.');
    }
  }
}
