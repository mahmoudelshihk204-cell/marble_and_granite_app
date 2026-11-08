import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../repositories/product_repository.dart';

class ProductApi {
  final ProductRepository productRepository;

  ProductApi({required this.productRepository});

  Router get router {
    final router = Router();

    router.get('/products', (Request request) async {
      try {
        final products = await productRepository.getAllProducts();

        final responseData = {
          'success': true,
          'count': products.length,
          'data': products.map((product) {
            return product.toJson();
          }).toList(),
        };

        return Response.ok(
          jsonEncode(responseData),
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      } catch (error) {
        print('Error fetching products: $error');

        return Response(
          500,
          body: jsonEncode({
            'success': false,
            'message': 'Failed to fetch products',
          }),
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
    });

    router.get('/products/barcode/<barcode>', (
      Request request,
      String barcode,
    ) async {
      try {
        final product = await productRepository.getProductByBarcode(barcode);

        if (product == null) {
          return Response(
            404,
            body: jsonEncode({
              'success': false,
              'message': 'Product not found',
            }),
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }

        return Response.ok(
          jsonEncode({'success': true, 'data': product.toJson()}),
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      } catch (error) {
        print('Error searching product by barcode: $error');

        return Response(
          500,
          body: jsonEncode({
            'success': false,
            'message': 'Failed to search product',
          }),
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
    });

    return router;
  }
}
