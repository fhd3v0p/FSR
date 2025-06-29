import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MasterJoinInfoScreen extends StatefulWidget {
  const MasterJoinInfoScreen({super.key});

  @override
  State<MasterJoinInfoScreen> createState() => _MasterJoinInfoScreenState();
}

class _MasterJoinInfoScreenState extends State<MasterJoinInfoScreen> with TickerProviderStateMixin {
  final List<String> advantages = [
    '⏰ 1. Занятость nonstop, no cap!\n— Клиенты прямо фрагят тебя через TG/WebApp — пустых слотов тупо нет, всё стримится, zero дейс.',
    '💡 2. Твой Drip = наш контент!\n— Твои тату,маник, окрасы и кастомы — в постоянном дропе хайпа: мемы, сториз, розыгрыши —  просто творишь, а твой стиль набирает бешеные обороты.',
    '📈 3.  Профессиональный взлёт = твой glow-up!\n— С Fresh Style Russia ты в elite squad: учишься, boost’ишь челленджи, поднимаешь ценник, удлинняешь цифры, укорачиваешь заеб',
  ];

  final List<AnimationController> _controllers = [];
  final List<Animation<Offset>> _offsetAnimations = [];
  final List<Animation<double>> _fadeAnimations = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < advantages.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      final offset = Tween<Offset>(
        begin: const Offset(0, -1.2),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.elasticOut)).animate(controller);
      final fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeIn),
      );
      _controllers.add(controller);
      _offsetAnimations.add(offset);
      _fadeAnimations.add(fade);
    }
    _runAnimations();
  }

  Future<void> _runAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'For Masters',
          style: TextStyle(
            fontFamily: 'Lepka',
            color: Colors.white,
            fontSize: 56, // В 2 раза больше
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 100, // чтобы не перекрывался
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
          // Затемнение
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          // Контент
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  // Преимущества с анимацией и отдельной рамкой для каждого
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(advantages.length, (i) {
                      return AnimatedBuilder(
                        animation: _controllers[i],
                        builder: (context, child) => FadeTransition(
                          opacity: _fadeAnimations[i],
                          child: SlideTransition(
                            position: _offsetAnimations[i],
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 18),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.7),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                advantages[i],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'SFProDisplay',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFDE3DF6),
                          Color(0xFF7B1FF6),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () async {
                        const url = 'https://t.me/FSR_Adminka';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        }
                      },
                      child: const Text(
                        'Присоединиться',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'SFProDisplay',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
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
