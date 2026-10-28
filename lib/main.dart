import 'package:flutter/material.dart';

void main() {
  runApp(const MarbleAndAranite());
}
 class MarbleAndAranite extends StatelessWidget {
   const MarbleAndAranite({super.key});
 
   @override
   Widget build(BuildContext context) {
     return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Text('Hello'),
     );
   }
 }