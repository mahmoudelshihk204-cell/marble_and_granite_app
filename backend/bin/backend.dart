import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:backend/database/oracle_connection.dart';
import 'package:backend/repositories/product_repository.dart';
import 'package:backend/services/product_api.dart';

Future<void> main() async {
  final database = OracleDatabase();

  try {
    // 1. Connect to Oracle
    final connection = await database.connect();

    // 2. Create Repository
    final productRepository = ProductRepository(connection: connection);

    // 3. Create API
    final productApi = ProductApi(productRepository: productRepository);

    // 4. Configure HTTP Server
    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(productApi.router.call);

    // 5. Start Server
    final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);

    server.autoCompress = true;

    print('');
    print('Server started successfully!');
    print('Products API: http://localhost:8080/products');
    print('Press Ctrl + C to stop the server.');
  } catch (error) {
    print('Server startup failed: $error');
    await database.close();
  }
}
