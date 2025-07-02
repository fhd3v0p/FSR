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
          // Фон как в giveaway
          Positioned.fill(
            child: Image.asset(
              'assets/giveaway_banner.png',
              fit: BoxFit.cover,
            ),
          ),
          // Затемнение для читаемости
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
                    'Как вы хотите искать мастера?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lepka',
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _ModeButton(
                    icon: Icons.list_alt_rounded,
                    text: 'Каталог мастеров',
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
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [Color(0xFFDE3DF6), Color(0xFF7B1FF6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 18),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'SFProDisplay',
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