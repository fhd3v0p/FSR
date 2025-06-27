import 'package:flutter/material.dart';

class MasterJoinInfoScreen extends StatelessWidget {
  const MasterJoinInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('Для мастеров', style: TextStyle(fontFamily: 'Lepka'))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Размещение мастеров бесплатно!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Lepka')),
              const SizedBox(height: 16),
              const Text('Просто напиши нам и мы добавим тебя в каталог', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Lepka')),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(color: Colors.purpleAccent, borderRadius: BorderRadius.circular(24)),
                child: const Text('@FSR_adminka', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Lepka')),
              )
            ],
          ),
        ),
      ),
    );
  }
}
