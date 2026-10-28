import 'package:flutter/material.dart';
import 'package:marble_and_granite/pages/home_page.dart';
import 'package:marble_and_granite/pages/login_page.dart';

void main() {
  runApp(const MarbleAndAranite());
}

class MarbleAndAranite extends StatelessWidget {
  const MarbleAndAranite({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'Tuffy',
            
            textTheme: const TextTheme(
              headlineSmall: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
                decoration: TextDecoration.none,
              ),
            ),
          ),
      debugShowCheckedModeBanner: false,
      routes: {
        HomePage.id: (context) => HomePage(),
        LoginPage.id: (context) => LoginPage(),
      },
      initialRoute: HomePage.id,
      
    );
  }
}
