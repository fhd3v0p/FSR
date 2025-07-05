import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'welcome_screen.dart';
import '../services/telegram_webapp_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoFinished = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _expandTelegramWebApp();
  }

  void _expandTelegramWebApp() {
    // Открываем Mini App на весь экран
    TelegramWebAppService.callTelegramMethod('expand');
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/FSR.mp4');
      
      await _videoController.initialize();
      
      // Устанавливаем цикличное воспроизведение
      _videoController.setLooping(true);
      
      // Слушаем завершение видео
      _videoController.addListener(() {
        if (_videoController.value.position >= _videoController.value.duration) {
          if (!_isVideoFinished) {
            setState(() {
              _isVideoFinished = true;
            });
            _navigateToWelcome();
          }
        }
      });
      
      setState(() {
        _isVideoInitialized = true;
      });
      
      // Запускаем видео
      await _videoController.play();
      
      // Автоматический переход через 5 секунд (если видео короче)
      Future.delayed(const Duration(seconds: 5), () {
        if (!_isVideoFinished) {
          _navigateToWelcome();
        }
      });
      
    } catch (e) {
      print('Error initializing video: $e');
      // Fallback: переходим к welcome screen
      _navigateToWelcome();
    }
  }

  void _navigateToWelcome() {
    if (!_isVideoFinished) {
      setState(() {
        _isVideoFinished = true;
      });
    }
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Видео на весь экран с увеличением на 25%
          if (_isVideoInitialized)
            Center(
              child: Transform.scale(
                scale: 1.25, // Увеличиваем на 25% (было 15%)
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            // Fallback пока видео загружается
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'FRESH STYLE RUSSIA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NauryzKeds',
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 24),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6EC7)),
                    strokeWidth: 3,
                  ),
                ],
              ),
            ),
          
          // Кнопка пропуска - поднята на 10% от экрана
          Positioned(
            top: MediaQuery.of(context).size.height * 0.10, // 10% от экрана (было 20%)
            right: 16,
            child: GestureDetector(
              onTap: _navigateToWelcome,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Пропустить',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'NauryzKeds',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 