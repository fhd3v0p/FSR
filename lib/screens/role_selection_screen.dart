import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'city_selection_screen.dart';
import 'master_join_info_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  bool _isClientPressed = false;
  bool _isMasterPressed = false;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateWithFade(Widget screen) {
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ));
  }

  void _onClientTap() {
    HapticFeedback.mediumImpact();
    setState(() => _isClientPressed = true);
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() => _isClientPressed = false);
      _navigateWithFade(const CitySelectionScreen());
    });
  }

  void _onMasterTap() {
    HapticFeedback.mediumImpact();
    setState(() => _isMasterPressed = true);
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() => _isMasterPressed = false);
      _navigateWithFade(const MasterJoinInfoScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = screenWidth * 0.45;
    final overlap = circleSize * 0.3;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          height: circleSize + overlap,
          width: circleSize * 2 - overlap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                child: Stack(
                  children: [
                    RotationTransition(
                      turns: _rotationController,
                      child: CustomPaint(
                        size: Size(circleSize, circleSize),
                        painter: DottedCirclePainter(),
                      ),
                    ),
                    Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFDDAEF5).withOpacity(0.3),
                            const Color(0xFFE3C8F1).withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                child: Stack(
                  children: [
                    RotationTransition(
                      turns: Tween<double>(begin: 1.0, end: 0.0)
                          .animate(_rotationController),
                      child: CustomPaint(
                        size: Size(circleSize, circleSize),
                        painter: DottedCirclePainter(),
                      ),
                    ),
                    Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFDDAEF5).withOpacity(0.3),
                            const Color(0xFFE3C8F1).withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CustomPaint(
                size: Size(circleSize * 2 - overlap, circleSize),
                painter: IntersectionLensPainter(
                  circleRadius: circleSize / 2,
                  overlap: overlap,
                ),
              ),
              Positioned(
                left: 0,
                child: GestureDetector(
                  onTap: _onClientTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: circleSize,
                    height: circleSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isClientPressed
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      'клиент',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Lepka',
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: _onMasterTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: circleSize,
                    height: circleSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isMasterPressed
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      'мастер',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Lepka',
                      ),
                    ),
                  ),
                ),
              ),
              ScaleTransition(
                scale: _pulseAnimation,
                child: const Text(
                  'Я',
                  style: TextStyle(
                    color: Color(0xFF8E5BBE),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lepka',
                  ),
                ),
              ),
            ],
          ),
        ),
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
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final radius = size.width / 2;
    final circumference = 2 * pi * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();
    final dashAngle = 2 * pi / dashCount;
    final dashArc = dashAngle * (dashWidth / (dashWidth + dashSpace));

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final endAngle = startAngle + dashArc;

      final p1 = Offset(
        radius + radius * cos(startAngle),
        radius + radius * sin(startAngle),
      );
      final p2 = Offset(
        radius + radius * cos(endAngle),
        radius + radius * sin(endAngle),
      );
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class IntersectionLensPainter extends CustomPainter {
  final double circleRadius;
  final double overlap;

  IntersectionLensPainter({
    required this.circleRadius,
    required this.overlap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final centerY = size.height / 2;

    final leftCenter = Offset(circleRadius, centerY);
    final rightCenter = Offset(size.width - circleRadius, centerY);

    final leftCircle = Path()
      ..addOval(Rect.fromCircle(center: leftCenter, radius: circleRadius));

    final rightCircle = Path()
      ..addOval(Rect.fromCircle(center: rightCenter, radius: circleRadius));

    final intersectPath = Path.combine(
      PathOperation.intersect,
      leftCircle,
      rightCircle,
    );

    canvas.drawPath(intersectPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
