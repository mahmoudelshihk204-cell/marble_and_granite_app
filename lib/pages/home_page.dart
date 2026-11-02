import 'package:flutter/material.dart';
import 'package:marble_and_granite/Widgets/custom_container_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static String id = 'HomePage';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
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
            fontSize: 30
          ),
        ),
      ),
      body: Center(
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
            Text(
              'Please select the way you want to search',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontFamily: 'Geist_Pixel',
              ),
            ),
            SizedBox(height: 50),
            CustomContainerItem(),
            SizedBox(height: 20),
            CustomContainerItem(),
          ],
        ),
      ),
    );
  }
}
