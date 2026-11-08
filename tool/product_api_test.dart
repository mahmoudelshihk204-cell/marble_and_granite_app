
// ignore_for_file: avoid_print, avoid_relative_lib_imports

import '../lib/services/product_api_service.dart';

Future<void> main() async {
  print('Testing Product API...');

  try {
    final service = ProductApiService();

    final products = await service.getProducts();

    print('\nProducts received: ${products.length}\n');

    for (final product in products) {
      print('''
Product ID: ${product.productId}
Name: ${product.productName}
Produced: ${product.producedQty}
Sold: ${product.soldQty}
Central Stock: ${product.centralStockQty}
-------------------------
''');
    }

    print('API Test Successful!');
  } catch (error) {
    print('API Test Failed: $error');
  }
}
