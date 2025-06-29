import 'dart:math';
import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'giveaway_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  final List<String> avatars = [
    'assets/avatar1.png',
    'assets/avatar2.png',
    'assets/avatar3.png',
    'assets/avatar4.png',
    'assets/avatar5.png',
    'assets/avatar6.png',
  ];

  double _sliderProgress = 0.0;
  double _orbitAngle = 0.0;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startOrbitAnimation();
  }

  void _startOrbitAnimation() {
    const double baseSpeed = 0.009;
    const double maxAdditionalSpeed = 0.01;
    const Duration frameDuration = Duration(milliseconds: 16);

    void tick() {
      if (!mounted) return; // <--- добавьте эту проверку!
      final double speed = baseSpeed + (_sliderProgress * maxAdditionalSpeed);
      _orbitAngle += speed;
      if (_orbitAngle > 2 * pi) {
        _orbitAngle -= 2 * pi;
      }
      setState(() {});
      Future.delayed(frameDuration, tick);
    }

    tick();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Offset calculateOrbitPosition(double angle, double radius) {
    return Offset(radius * cos(angle), radius * sin(angle));
  }

  void _onSlideChange(double value) {
    setState(() {
      _sliderProgress = value.clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 320,
                height: 320,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(320, 320),
                          painter: DottedCirclePainter(),
                        ),
                        Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 224,
                            height: 224,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFF6EC7).withOpacity(0.4), // ярко-розовый
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFF6EC7).withOpacity(0.85), // ярко-розовый, плотнее
                            ),
                          ),
                        ),
                        Container(
                          width: 320,
                          height: 320,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFB3E6).withOpacity(0.2), // просто розовый цвет без градиента
                          ),
                        ),
                        for (int i = 0; i < 3; i++)
                          Transform.translate(
                            offset: calculateOrbitPosition(
                                _orbitAngle + (i * 2 * pi / 3), 160),
                            child: framedMemoji(avatars[i]),
                          ),
                        for (int i = 0; i < 2; i++)
                          Transform.translate(
                            offset: calculateOrbitPosition(
                                -_orbitAngle + (i * pi), 112),
                            child: framedMemoji(avatars[3 + i]),
                          ),
                        Transform.translate(
                          offset: calculateOrbitPosition(_orbitAngle, 86),
                          child: framedMemoji(avatars[5]),
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white, // белая рамка
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 36,
                            backgroundImage: AssetImage('assets/center_memoji.png'),
                            backgroundColor: Color(0xFF33272D), // фон внутри мемодзи теперь #33272D
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Fresh Style Russia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 54, // Было 36, стало в 1.5 раза больше
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Lepka',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Find smarter, connect faster with AI search!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              Listener(
                onPointerMove: (event) {
                  final box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(event.position);
                  final width = box.size.width - 48;
                  final progress = (localPosition.dx - 24) / width;
                  _onSlideChange(progress);
                },
                child: SlideAction(
                  text: 'Проведите для начала',
                  textStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7), // светло-серая, светлее фона
                    fontSize: 20,
                  ),
                  outerColor: Colors.white70.withOpacity(0.35), // фон слайдера
                  innerColor: Colors.white, // круг белый всегда
                  sliderButtonIcon: Icon(
                    Icons.arrow_forward,
                    color: Color(0xFFFF6EC7), // стрелочка розовая всегда
                  ),
                  elevation: 0,
                  borderRadius: 50,
                  onSubmit: () {
                    Future.microtask(() {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const GiveawayScreen()),
                      );
                    });
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget framedMemoji(String path) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundImage: AssetImage(path),
        backgroundColor: Colors.black, // фон внутри аватаров теперь чёрный
      ),
    );
  }
}

class DottedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double dashWidth = 5;
    const double dashSpace = 5;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final radius = size.width / 2;
    final circumference = 2 * pi * radius;
    final dashCount = circumference ~/ (dashWidth + dashSpace);
    final adjustedDashAngle = 2 * pi / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * adjustedDashAngle;
      final x1 = radius + radius * cos(startAngle);
      final y1 = radius + radius * sin(startAngle);
      final x2 = radius + radius * cos(startAngle + adjustedDashAngle / 2);
      final y2 = radius + radius * sin(startAngle + adjustedDashAngle / 2);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}