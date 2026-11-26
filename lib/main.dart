import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marble_and_granite/pages/home_page.dart';
import 'package:marble_and_granite/pages/login_page.dart';
import 'package:marble_and_granite/repositories/block_repository.dart';
import 'package:marble_and_granite/services/legacy/legacy_api_service.dart';

void main() {
  runApp(const MarbleAndAranite());
}

class MarbleAndAranite extends StatelessWidget {
  const MarbleAndAranite({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // إنشاء خدمة الاتصال بالسيرفر مرة واحدة
        RepositoryProvider<LegacyApiService>(
          create: (context) => LegacyApiService(),
        ),

        // إنشاء Repository واستخدام خدمة الاتصال السابقة
        RepositoryProvider<BlockRepository>(
          create: (context) => BlockRepository(
            context.read<LegacyApiService>(),
          ),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          fontFamily: 'Tuffy',
          textTheme: const TextTheme(
            headlineSmall: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
              decoration: TextDecoration.none,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          HomePage.id: (context) => HomePage(),
          LoginPage.id: (context) => LoginPage(),
        },
        home: LoginPage(),
      ),
    );
  }
}
