import 'dart:math';
import 'package:flutter/material.dart';
import 'master_cloud_screen.dart';

class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({super.key});

  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CityPoint {
  final String name;
  final double dx;
  final double dy;
  final double size;
  final String abbr;

  _CityPoint(this.name, this.dx, this.dy, this.size, this.abbr);
}

class _CitySelectionScreenState extends State<CitySelectionScreen> with SingleTickerProviderStateMixin {
  String? _selectedCity;
  late final AnimationController _controller;

  final List<_CityPoint> _cities = [
    _CityPoint('Москва', 0.5, 0.5, 155, 'MSC'),
    _CityPoint('Санкт-Петербург', 0.22, 0.23, 84, 'SPB'),
    _CityPoint('Новосибирск', 0.5, 0.73, 54, 'NSK'),
    _CityPoint('Казань', 0.73, 0.60, 42, 'KAZ'),
    _CityPoint('Екатеринбург', 0.80, 0.73, 48, 'EKB'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void navigateWithFade(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF232026),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/city_selection_banner.png',
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
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 48), // Отступ для кнопки назад
                Expanded(
                  child: Stack(
                    children: _cities.map((city) {
                      final double citySize = city.size * 1.15;
                      final selected = _selectedCity == city.name;
                      final bool dimmed = _selectedCity != null && !selected;
                      return Positioned(
                        left: city.dx * width - citySize / 2,
                        top: city.dy * (height - 120) - citySize / 2,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCity = city.name;
                            });
                          },
                          child: Column(
                            children: [
                              Opacity(
                                opacity: dimmed ? 0.18 : 1,
                                child: !selected
                                    ? AnimatedBuilder(
                                        animation: _controller,
                                        builder: (context, child) {
                                          final double stroke = citySize / 13;
                                          final double paintSize = citySize + stroke * 2;
                                          return SizedBox(
                                            width: paintSize,
                                            height: paintSize,
                                            child: CustomPaint(
                                              painter: DottedCirclePainter(
                                                color: Colors.white.withOpacity(0.85),
                                                circleSize: citySize,
                                                animationValue: _controller.value,
                                              ),
                                              child: Center(
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 180),
                                                  width: citySize,
                                                  height: citySize,
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      colors: [Color(0xFFFF6EC7), Color(0xFFFFB3E6)],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Transform.translate(
                                                      offset: Offset(0, citySize * 0.05),
                                                      child: Text(
                                                        city.abbr,
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: citySize / 2.2,
                                                          fontFamily: 'NauryzKeds',
                                                          letterSpacing: 1,
                                                          height: 1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : AnimatedContainer(
                                        duration: const Duration(milliseconds: 180),
                                        width: citySize + 18,
                                        height: citySize + 18,
                                        decoration: BoxDecoration(
                                          color: Colors.white, // как у активной кнопки "Далее"
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFFFF6EC7), // розовая окантовка как у активной кнопки
                                            width: 5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFF6EC7).withOpacity(0.15),
                                              blurRadius: 18,
                                              spreadRadius: 4,
                                            )
                                          ],
                                        ),
                                        child: Center(
                                          child: Transform.translate(
                                            offset: Offset(0, citySize * 0.05),
                                            child: Text(
                                              city.abbr,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.black, // как у активной кнопки "Далее"
                                                fontWeight: FontWeight.bold,
                                                fontSize: citySize / 2.2,
                                                fontFamily: 'NauryzKeds',
                                                letterSpacing: 1,
                                                height: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 8),
                              if (selected)
                                Text(
                                  city.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'NauryzKeds',
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: GestureDetector(
                    onTap: _selectedCity == null
                        ? null
                        : () {
                            navigateWithFade(
                              context,
                              MasterCloudScreen(city: _selectedCity!),
                            );
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.zero, // острые углы
                        color: _selectedCity != null
                            ? Colors.white // выбран — белый фон
                            : Colors.white.withOpacity(0.08), // не выбран — прозрачный
                        border: Border.all(
                          color: _selectedCity != null
                              ? const Color(0xFFFF6EC7) // выбран — розовая окантовка
                              : Colors.white, // не выбран — белая окантовка
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Далее',
                          style: TextStyle(
                            color: _selectedCity != null
                                ? Colors.black // выбран — чёрный текст
                                : Colors.white.withOpacity(0.5), // не выбран — белый полупрозрачный
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NauryzKeds',
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DottedCirclePainter extends CustomPainter {
  final Color color;
  final double circleSize;
  final double animationValue;

  DottedCirclePainter({
    required this.color,
    required this.circleSize,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double dashWidth = circleSize / 6;
    final double dashSpace = circleSize / 6;
    final double stroke = circleSize / 13;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final radius = size.width / 2 - stroke / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final circumference = 2 * pi * radius;
    double distance = 0;

    final double startRotation = 2 * pi * animationValue;

    while (distance < circumference) {
      final startAngle = startRotation + distance / radius;
      final endAngle = startRotation + (distance + dashWidth) / radius;
      canvas.drawLine(
        center.translate(radius * cos(startAngle), radius * sin(startAngle)),
        center.translate(radius * cos(endAngle), radius * sin(endAngle)),
        paint,
      );
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant DottedCirclePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.circleSize != circleSize ||
        oldDelegate.color != color;
  }
}