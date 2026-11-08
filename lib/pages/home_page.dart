import 'package:flutter/material.dart';
import 'package:marble_and_granite/Constant/constants.dart';
import 'package:marble_and_granite/Widgets/custom_container_item.dart';
import 'package:marble_and_granite/pages/scanner_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static String id = 'HomePage';
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
        title: Text(
          'Marble And Granite',
          style: TextStyle(
            fontFamily: 'Tuffy',
            //  fontStyle: FontStyle.italic,
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
                SizedBox(height: 10),
                Text(
                  'Welcome To Our Company',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Geist_Pixel',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Text(
                    'Please select the way you want to search',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Geist_Pixel',
                    ),
                  ),
                ),
                SizedBox(height: 50),
                CustomContainerItem(
                  containerName: 'Scan Barcode',
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScannerPage(),
                      ),
                    );
                    if (result != null) {
                      // ignore: avoid_print
                      print('Scanned Code: $result');
                    }
                  },
                  icon: Icons.qr_code_scanner,
                ),
                SizedBox(height: 20),
                CustomContainerItem(
                  containerName: 'Manual BarCode',
                  icon: Icons.import_contacts,
                ),
                SizedBox(height: 20),
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
