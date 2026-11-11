import 'package:flutter/material.dart';
import 'package:marble_and_granite/Constant/constants.dart';
import 'package:marble_and_granite/Widgets/custom_container_item.dart';
import 'package:marble_and_granite/pages/scanner_page.dart';
import 'package:marble_and_granite/pages/products_page.dart';
import 'package:marble_and_granite/services/product_api_service.dart';
import 'package:marble_and_granite/pages/product_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String id = 'HomePage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController barcodeController = TextEditingController();
  bool isSearching = false;

  Future<void> searchProduct(String barcode) async {
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

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ProductDetailsPage(product: product, barcode: barcode),
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

  Future<void> scanBarcode() async {
    final String? barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const ScannerPage()),
    );

    if (barcode == null || barcode.trim().isEmpty || !mounted) {
      return;
    }

    await searchProduct(barcode.trim());
  }

  // فتح نافذة إدخال Barcode يدويًا.
  Future<void> manualBarcode() async {
    // نمسح أي رقم قديم قبل فتح النافذة.
    barcodeController.clear();

    // نعرض Dialog وننتظر الرقم اللي المستخدم هيدخله.
    final barcode = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        // يسمح بمراعاة المساحة المتاحة عند ظهور الكيبورد.
        scrollable: true,

        title: const Text('Enter Barcode'),

        content: TextField(
          // ربط TextField بالـController الموجود في State.
          controller: barcodeController,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter product barcode',
            prefixIcon: Icon(Icons.qr_code),
            border: OutlineInputBorder(),
          ),
        ),

        actions: [
          // إغلاق النافذة بدون البحث.
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),

          // إغلاق النافذة وإرجاع الرقم المكتوب.
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, barcodeController.text.trim());
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );

    // لو المستخدم ألغى أو الصفحة اتقفلت، مش هنكمل.
    if (barcode == null || barcode.isEmpty || !mounted) {
      return;
    }

    // البحث عن المنتج باستخدام نفس دالة البحث المستخدمة في الكاميرا.
    await searchProduct(barcode);
  }

  // التخلص من الـController عند إزالة الصفحة نهائيًا.
  @override
  void dispose() {
    barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  onTap: isSearching ? null : manualBarcode,
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
