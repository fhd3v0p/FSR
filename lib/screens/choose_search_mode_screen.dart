import 'package:flutter/material.dart';
import 'city_selection_screen.dart';
import 'ai_photo_search_screen.dart';

class ChooseSearchModeScreen extends StatefulWidget {
  const ChooseSearchModeScreen({super.key});

  @override
  State<ChooseSearchModeScreen> createState() => _ChooseSearchModeScreenState();
}

class _ChooseSearchModeScreenState extends State<ChooseSearchModeScreen> {
  int _selectedMode = 0; // 0 - ничего, 1 - каталог, 2 - AI

  void _onSelect(int mode) {
    setState(() {
      _selectedMode = mode;
    });
  }

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
                    'Как вы хотите произвести поиск?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'NauryzKeds',
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _ModeButton(
                    icon: Icons.list_alt_rounded,
                    text: 'Перейти в каталог',
                    fontFamily: 'OpenSans',
                    fontSize: 28,
                    selected: _selectedMode == 1,
                    onTap: () {
                      _onSelect(1);
                      Future.delayed(const Duration(milliseconds: 120), () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CitySelectionScreen()),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _ModeButton(
                    icon: Icons.camera_alt_rounded,
                    text: 'AI-подбор по фото',
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    selected: _selectedMode == 2,
                    onTap: () {
                      _onSelect(2);
                      Future.delayed(const Duration(milliseconds: 120), () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AiPhotoSearchScreen()),
                        );
                      });
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
  final String fontFamily;
  final double fontSize;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.text,
    required this.fontFamily,
    required this.fontSize,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.zero, // острые углы
          color: Colors.black.withOpacity(selected ? 0.45 : 0.45), // затемнение всегда на весь баннер
          border: Border.all(
            color: selected ? const Color(0xFFFF6EC7) : Colors.white,
            width: selected ? 3 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF6EC7).withOpacity(0.25),
                    blurRadius: 16,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 18),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontFamily: fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: text == 'Перейти в каталог' ? 22 : fontSize,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}