import 'package:flutter/material.dart';
import 'package:marble_and_granite/Widgets/custom_bottom.dart';
import 'package:marble_and_granite/Widgets/custom_text_feild.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  static String id = 'LoginPage';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                'LogIn',
                style: TextStyle(
                  fontFamily: 'Tuffy',
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
                
              ),
              
              Center(
                child: SizedBox(
                  height: 230,
                  width: 200,
                  
                  child: Image.asset(
                    'assets/Images/Logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        'Image Error: $error',
                        style: const TextStyle(color: Colors.red),
                      );
                    },
                  ),
                ),
              ),
              
              CustomTextField(hint: 'User Name', icon: Icons.person),
              SizedBox(height: 10),
              CustomTextField(hint: 'Password', icon: Icons.password),
              SizedBox(height: 10),
              CustomTextField(hint: 'Token', icon: Icons.key),
              SizedBox(height: 40),
              CustomBotton(bottonName: 'Login'),
              SizedBox(height: 10),
              CustomBotton(bottonName: 'Offline Mode'),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
