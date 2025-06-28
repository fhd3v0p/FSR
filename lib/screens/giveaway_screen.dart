import 'package:flutter/material.dart';
import 'role_selection_screen.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';


class GiveawayScreen extends StatefulWidget {
  const GiveawayScreen({super.key});

  @override
  State<GiveawayScreen> createState() => _GiveawayScreenState();
}

class _GiveawayScreenState extends State<GiveawayScreen> {
  late Timer _timer;
  Duration _timeLeft = const Duration(days: 3, hours: 3, minutes: 47, seconds: 4);

  bool _task1Done = false;
  bool _task2Done = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_timeLeft.inSeconds > 0) {
          _timeLeft -= const Duration(seconds: 1);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${d.inHours.remainder(24)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final allTasksDone = _task1Done && _task2Done;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const SizedBox.shrink(), // убираем русское слово "Гивевей"
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Баннер как фон
          Positioned.fill(
            child: Image.asset(
              'assets/giveaway_banner.png',
              fit: BoxFit.cover,
            ),
          ),
          // Затемнение для читаемости текста (по желанию)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.15),
            ),
          ),
          // Надпись GIVEAWAY между верхом и таймером
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'GIVEAWAY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 90,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lepka',
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          // Основной контент
          Column(
            children: [
              const SizedBox(height: 80), // увеличиваем отступ, чтобы таймер был ниже надписи
              // Таймер — крупный, адаптивный
              SizedBox(
                height: 180,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _formatDuration(_timeLeft),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 160,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -2,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Список заданий внизу, но над кнопкой
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Column(
                  children: [
                    _TaskTile(
                      title: 'Подписаться на Telegram-папку',
                      subtitle: '10 каналов одним кликом\n+1000 XP',
                      icon: Icons.folder_special,
                      onTap: () async {
                        // Открыть ссылку на Telegram-папку
                        const url = 'https://t.me/addlist/IcPQxDiYrwU3Mjgy';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        }
                        // Отметить задание выполненным
                        setState(() {
                          _task1Done = true;
                        });
                      },
                      done: _task1Done,
                    ),
                    _TaskTile(
                      title: 'Пригласить друзей',
                      subtitle: 'За каждого друга: +100 XP',
                      icon: Icons.person_add_alt_1,
                      onTap: () {
                        setState(() {
                          _task2Done = true;
                        });
                      },
                      done: _task2Done,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: allTasksDone
                      ? () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const RoleSelectionScreen(),
                            ),
                          );
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: allTasksDone
                          ? const LinearGradient(
                              colors: [
                                Color(0xFFDE3DF6),
                                Color(0xFF3DD6F6),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      color: allTasksDone ? null : Colors.grey[800],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Перейти в приложение',
                          style: TextStyle(
                            color: Colors.white.withOpacity(allTasksDone ? 1 : 0.5),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.arrow_forward,
                            color: Colors.white.withOpacity(allTasksDone ? 1 : 0.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Измените _TaskTile, чтобы он показывал галочку при выполнении:
class _TaskTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool done;

  const _TaskTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900]!.withOpacity(0.7), // <--- прозрачность 70%
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFDDAEF5),
          child: Icon(icon, color: Colors.purple.shade800),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
        trailing: done
            ? const Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.7)),
        onTap: onTap,
      ),
    );
  }
}