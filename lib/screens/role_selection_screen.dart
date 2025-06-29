import 'package:flutter/material.dart';
import 'giveaway_screen.dart';
import 'city_selection_screen.dart';
import 'master_join_info_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth * 0.45;
    final overlap = circleSize * 0.3;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const GiveawayScreen()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // Новый баннер как фон
          Positioned.fill(
            child: Image.asset(
              'assets/main_banner.png',
              fit: BoxFit.cover,
            ),
          ),
          // Затемнение для читаемости
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          // Контент
          Center(
            child: SizedBox(
              height: circleSize + overlap,
              width: circleSize * 2 - overlap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Круг "Клиент"
                  Positioned(
                    left: 0,
                    child: _RoleCircle(
                      label: 'клиент',
                      icon: Icons.person_outline,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CitySelectionScreen()),
                        );
                      },
                      size: circleSize,
                    ),
                  ),
                  // Круг "Мастер"
                  Positioned(
                    right: 0,
                    child: _RoleCircle(
                      label: 'мастер',
                      icon: Icons.star_outline,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MasterJoinInfoScreen()),
                        );
                      },
                      size: circleSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Заголовок
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Выберите роль',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SFProDisplay',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCircle extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _RoleCircle({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.size,
    Key? key,
  }) : super(key: key);

  @override
  State<_RoleCircle> createState() => _RoleCircleState();
}

class _RoleCircleState extends State<_RoleCircle> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: widget.onTap,
        onHighlightChanged: (value) {
          setState(() {
            _pressed = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: _pressed
                ? Colors.white.withOpacity(0.28) // осветление при нажатии
                : Colors.white.withOpacity(0.13),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.7),
              width: 4,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 48),
              const SizedBox(height: 18),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SFProDisplay',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
