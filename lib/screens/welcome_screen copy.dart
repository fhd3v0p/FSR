import 'package:flutter/material.dart';
import 'role_selection_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(radius: 60, backgroundImage: AssetImage('assets/center_memoji.png')),
              const SizedBox(height: 32),
              const Text('F. resh\nS. tyle\nR. ussia', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              const Text('Choose Smarter,\nConnect Faster.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white70)),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoleSelectionScreen())),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Погнали!'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 36),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
