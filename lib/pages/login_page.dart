import 'package:flutter/material.dart';
import 'package:marble_and_granite/Widgets/custom_text_feild.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  static String id = 'LoginPage';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        elevation: 10,
        scrolledUnderElevation: 10,
        shadowColor: Colors.black.withValues(alpha: .5, red: 12),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        title: Text(
          'MarbleAndAranite',
          style: TextStyle(
            fontFamily: 'Tuffy',
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: ListView(
          children: [
            SizedBox(height: 20),
            Text(
              'LogIn',
              style: TextStyle(
                fontFamily: 'Tuffy',
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CustomTextField(hint: 'User Name' ,icon: Icons.person,),
            SizedBox(height: 20),
            CustomTextField(hint: 'Password',icon: Icons.password, ),
            SizedBox(height: 20),
            CustomTextField(hint: 'Token',icon: Icons.key,),
          ],
        ),
      ),
    );
  }
}
