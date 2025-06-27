import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FSR App',
      theme: ThemeData(
        fontFamily: 'Lepka',
        scaffoldBackgroundColor: const Color(0xFFE3C8F1),
      ),
      home: const WelcomeScreen(),
    );
  }
}
