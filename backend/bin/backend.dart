import 'package:backend/database/oracle_connection.dart';
import 'package:backend/repositories/product_repository.dart';

Future<void> main() async {
  final database = OracleDatabase();

  try {
    final connection = await database.connect();

    final productRepository = ProductRepository(connection: connection);

    print('\nFetching products...\n');

    final products = await productRepository.getAllProducts();

    for (final product in products) {
      print('''
Product ID: ${product.productId}
Name: ${product.productName}
Produced: ${product.producedQty}
Sold: ${product.soldQty}
Central Stock: ${product.centralStockQty}
------------------------------
''');
    }

    print('Total products: ${products.length}');
    print('Repository test successful!');
  } catch (e) {
    print('Error: $e');
  } finally {
    await database.close();
  }
}
