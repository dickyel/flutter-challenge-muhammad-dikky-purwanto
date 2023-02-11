import 'package:flutter/material.dart';
import 'package:flutter_challenge_2/pages/simple_dashboard.dart';
import 'package:flutter_challenge_2/pages/login_page.dart';
import 'package:flutter_challenge_2/pages/splash_page.dart';
import 'package:hive/hive.dart';

Future<void> main() async {
  await Hive.openBox("favorites");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => SplashPage(),
        '/login': (context) => LoginPage(),
        '/dashboard': (context) => SimpleDashboard(),
      },
    );
  }
}
