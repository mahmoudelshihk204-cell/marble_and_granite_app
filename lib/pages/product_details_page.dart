import 'package:flutter/material.dart';
import 'package:marble_and_granite/models/product_model.dart';

class ProductDetailsPage extends StatelessWidget {
  final ProductModel product;
  final String barcode;

  const ProductDetailsPage({
    super.key,
    required this.product,
    required this.barcode,
  });

  static const Color goldColor = Color(0xffC5A46D);
  static const Color backgroundColor = Color(0xff151515);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: goldColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tuffy',
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: .5),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 25),

            const Icon(Icons.inventory_2_outlined, color: goldColor, size: 75),

            const SizedBox(height: 20),

            Text(
              product.productName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: goldColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tuffy',
              ),
            ),

            const SizedBox(height: 10),

            _InfoTile(
              title: 'Product ID',
              value: product.productId.toString(),
              icon: Icons.tag,
            ),

            _InfoTile(title: 'Barcode', value: barcode, icon: Icons.qr_code),

            const SizedBox(height: 20),

            const Text(
              'Stock Information',
              style: TextStyle(
                color: goldColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _InfoTile(
              title: 'Produced Quantity',
              value: product.producedQty.toString(),
              icon: Icons.precision_manufacturing,
            ),

            _InfoTile(
              title: 'Sold Quantity',
              value: product.soldQty.toString(),
              icon: Icons.shopping_cart_outlined,
            ),

            _InfoTile(
              title: 'Central Stock',
              value: product.centralStockQty.toString(),
              icon: Icons.warehouse_outlined,
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff252525),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffC5A46D), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xffC5A46D), size: 25),
          const SizedBox(width: 15),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xffC5A46D),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
