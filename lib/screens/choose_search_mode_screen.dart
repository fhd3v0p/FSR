import 'package:flutter/material.dart';
import 'city_selection_screen.dart';
import 'ai_photo_search_screen.dart';

class ChooseSearchModeScreen extends StatelessWidget {
  const ChooseSearchModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/giveaway_banner.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.18),
            ),
          ),
          // Кнопка назад
          Positioned(
            top: 36,
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).maybePop(),
              splashRadius: 24,
            ),
          ),
          // Контент
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Как вы хотите искать артиста?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'NauryzKeds', // заменили Lepka на NauryzKeds
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _ModeButton(
                    icon: Icons.list_alt_rounded,
                    text: 'Каталог артистов', // заменили мастеров на артистов
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CitySelectionScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _ModeButton(
                    icon: Icons.camera_alt_rounded,
                    text: 'AI-подбор по фото',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AiPhotoSearchScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.zero, // острые углы
          color: Colors.white.withOpacity(0.08), // как на giveaway
          border: Border.all(color: Colors.white, width: 1.5), // белая окантовка
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32), // белая иконка
            const SizedBox(width: 18),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white, // белый текст
                fontFamily: 'NauryzKeds', // заменили SFProDisplay на NauryzKeds
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}