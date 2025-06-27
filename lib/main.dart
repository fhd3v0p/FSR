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
      title: 'Fresh Style Russia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SFProDisplay', // основной минималистичный шрифт
        scaffoldBackgroundColor: const Color(0xFFE3C8F1),
      ),
      home: const WelcomeScreen(),
    );
  }
}
