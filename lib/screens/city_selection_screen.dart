import 'dart:math';
import 'package:flutter/material.dart';
import 'master_cloud_screen.dart';

class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({super.key});

  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> with SingleTickerProviderStateMixin {
  String? _selectedCity;
  late final AnimationController _controller;

  final List<_CityPoint> _cities = [
    _CityPoint('Москва', 0.5, 0.5, 155, 'MSC'),
    _CityPoint('Санкт-Петербург', 0.22, 0.23, 84, 'SPB'),
    _CityPoint('Новосибирск', 0.5, 0.73, 54, 'NSK'), // ниже, на уровне ЕКБ
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
          // Контент
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white.withOpacity(0.7)),
                    onPressed: () => Navigator.of(context).maybePop(),
                    splashRadius: 24,
                    tooltip: 'Назад',
                  ),
                ),
                const SizedBox(height: 12),
                // Карта с кругами-городами на весь экран (кроме кнопки)
                Expanded(
                  child: Stack(
                    children: [
                      ..._cities.map((city) {
                        final selected = _selectedCity == city.name;
                        final bool dimmed = _selectedCity != null && !selected;
                        return Positioned(
                          left: city.dx * width - city.size / 2,
                          top: city.dy * (height - 120) - city.size / 2,
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
                                            // Размер CustomPaint больше круга на 2*stroke
                                            final double stroke = city.size / 13;
                                            final double paintSize = city.size + stroke * 2;
                                            return SizedBox(
                                              width: paintSize,
                                              height: paintSize,
                                              child: CustomPaint(
                                                painter: DottedCirclePainter(
                                                  color: Colors.white.withOpacity(0.85),
                                                  circleSize: city.size,
                                                  animationValue: _controller.value,
                                                ),
                                                child: Center(
                                                  child: AnimatedContainer(
                                                    duration: const Duration(milliseconds: 180),
                                                    width: city.size,
                                                    height: city.size,
                                                    decoration: BoxDecoration(
                                                      gradient: const LinearGradient(
                                                        colors: [Color(0xFFFF6EC7), Color(0xFFFFB3E6)],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: SizedBox(
                                                        width: city.size,
                                                        height: city.size,
                                                        child: Center(
                                                          child: Transform.translate(
                                                            offset: Offset(0, city.size * 0.05), // Смещение вниз на 5% радиуса круга
                                                            child: Text(
                                                              city.abbr,
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: city.size / 2.2,
                                                                fontFamily: 'NauryzKeds', // заменили Lepka на NauryzKeds
                                                                letterSpacing: 1,
                                                                height: 1,
                                                              ),
                                                            ),
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
                                          width: city.size + 18,
                                          height: city.size + 18,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFDE3DF6), Color(0xFF7B1FF6)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFDE3DF6).withOpacity(0.25),
                                                blurRadius: 18,
                                                spreadRadius: 4,
                                              )
                                            ],
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.95),
                                              width: 5,
                                            ),
                                          ),
                                          child: Center(
                                            child: SizedBox(
                                              width: city.size + 18,
                                              height: city.size + 18,
                                              child: Center(
                                                child: Transform.translate(
                                                  offset: Offset(0, city.size * 0.05), // Смещение вниз на 5% радиуса круга
                                                  child: Text(
                                                    city.abbr,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: city.size / 2.2,
                                                      fontFamily: 'NauryzKeds', // заменили Lepka на NauryzKeds
                                                      letterSpacing: 1,
                                                      height: 1,
                                                    ),
                                                  ),
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
                                      fontFamily: 'SFProDisplay',
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
                // Кнопка "Далее" в самом низу, с белой окантовкой как в giveaway
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: GestureDetector(
                    onTap: _selectedCity == null
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MasterCloudScreen(city: _selectedCity!),
                              ),
                            );
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: _selectedCity != null
                            ? const LinearGradient(
                                colors: [Color(0xFFDE3DF6), Color(0xFF7B1FF6)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : null,
                        color: _selectedCity == null
                            ? Colors.white.withOpacity(0.08)
                            : null,
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Далее',
                          style: TextStyle(
                            color: _selectedCity != null
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'SFProDisplay',
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

class _CityPoint {
  final String name;
  final double dx;
  final double dy;
  final double size;
  final String abbr;

  _CityPoint(this.name, this.dx, this.dy, this.size, this.abbr);
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
    // Длина штриха и пробела и толщина зависят от размера круга
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

    // Анимация вращения пунктиров
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