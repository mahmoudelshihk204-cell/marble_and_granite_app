import 'package:flutter/material.dart';
import 'package:marble_and_granite/Constant/constants.dart';
import 'package:marble_and_granite/Widgets/custom_container_item.dart';
import 'package:marble_and_granite/pages/scanner_page.dart';
import 'package:marble_and_granite/pages/products_page.dart';
import 'package:marble_and_granite/services/product_api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String id = 'HomePage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSearching = false;

  Future<void> scanBarcode() async {
    final String? barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const ScannerPage()),
    );

    if (barcode == null || barcode.isEmpty || !mounted) {
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final product = await ProductApiService().getProductByBarcode(barcode);

      if (!mounted) return;

      setState(() {
        isSearching = false;
      });

      if (product == null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Product Not Found'),
            content: Text('No product found for barcode: $barcode'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(product.productName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Barcode: $barcode'),
              Text('Produced: ${product.producedQty}'),
              Text('Sold: ${product.soldQty}'),
              Text('Central Stock: ${product.centralStockQty}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isSearching = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 10,
        scrolledUnderElevation: 10,
        shadowColor: Colors.black.withValues(alpha: .5),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        title: const Text(
          'Marble And Granite',
          style: TextStyle(
            fontFamily: 'Tuffy',
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Color(0xffC5A46D),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: kImage, fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Welcome To Our Company',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Geist_Pixel',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Text(
                    'Please select the way you want to search',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Geist_Pixel',
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                CustomContainerItem(
                  containerName: 'Scan Barcode',
                  onTap: isSearching ? null : scanBarcode,
                  icon: Icons.qr_code_scanner,
                ),

                if (isSearching) ...[
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  const Text('Searching product...'),
                ],

                const SizedBox(height: 20),

                CustomContainerItem(
                  containerName: 'View Products',
                  icon: Icons.inventory_2,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductsPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
                CustomContainerItem(
                  containerName: 'Manual BarCode',
                  icon: Icons.import_contacts,
                ),
                const SizedBox(height: 20),
                CustomContainerItem(
                  containerName: 'Manual Block Code',
                  icon: Icons.numbers,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
