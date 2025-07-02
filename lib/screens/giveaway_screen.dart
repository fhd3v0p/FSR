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
  Duration _timeLeft = Duration.zero;

  bool _task1Done = false;
  bool _task2Done = false;

  final DateTime giveawayDate = DateTime(2025, 7, 10, 20, 0, 0); // 10 июля 2025, 20:00

  @override
  void initState() {
    super.initState();
    _updateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeLeft();
    });
  }

  void _updateTimeLeft() {
    final now = DateTime.now();
    setState(() {
      _timeLeft = giveawayDate.difference(now);
      if (_timeLeft.isNegative) {
        _timeLeft = Duration.zero;
      }
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
      body: Stack(
        children: [
          // Фон: оба баннера друг над другом
          Positioned.fill(
            child: Stack(
              children: [
                Image.asset(
                  'assets/giveaway_back_banner.png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Уменьшаем giveaway_banner.png на 20% и центрируем
                Center(
                  child: Transform.scale(
                    scale: 0.8, // уменьшение на 20%
                    child: Image.asset(
                      'assets/giveaway_banner.png',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Затемнение для читаемости текста (по желанию)
                Container(
                  color: Colors.black.withOpacity(0.15),
                ),
              ],
            ),
          ),
          // Контент поверх фона
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Бокс для заголовка GIVEAWAY
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    'GIVEAWAY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42, // Уменьшен с 54 до 42
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NauryzKeds',
                      letterSpacing: 2,
                      height: 0.8, // Уменьшаем высоту строки для минимального отступа
                    ),
                  ),
                ),
                // Минимальный отступ между заголовком и таймером
                const SizedBox(height: 4),
                // Бокс для таймера
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: SizedBox(
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
                          fontFamily: 'NauryzKeds',
                          height: 0.9, // Уменьшаем высоту строки таймера
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Список заданий
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: Column(
                    children: [
                      _TaskTile(
                        title: 'Подписаться на Telegram-папку',
                        subtitle: '10 каналов одним кликом\n+1000 XP',
                        icon: Icons.folder_special,
                        onTap: () async {
                          const url = 'https://t.me/addlist/IcPQxDiYrwU3Mjgy';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                          }
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
                  child: GradientButton(
                    text: 'Перейти в приложение',
                    onTap: allTasksDone
                        ? () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const RoleSelectionScreen(),
                              ),
                            );
                          }
                        : null,
                    enabled: allTasksDone,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withOpacity(0.7),
        // Убрали borderRadius
      ),
      child: Material(
        color: Colors.transparent,
        // Убрали borderRadius
        child: InkWell(
          // Убрали borderRadius
          splashColor: Colors.white.withOpacity(0.08),
          highlightColor: Colors.white.withOpacity(0.04),
          onTap: onTap,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFF6EC7),
              child: Icon(icon, color: Colors.white),
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
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool enabled;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.enabled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.zero, // острые углы
          gradient: enabled
              ? const LinearGradient(
                  colors: [
                    Colors.white,
                    Color(0xFFFFE3F3), // очень светло-розовый
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: enabled
              ? null
              : Colors.grey[900]!.withOpacity(0.7),
          border: enabled
              ? Border.all(
                  color: Color(0xFFFF6EC7),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: enabled
                    ? Color(0xFFFF6EC7)
                    : Colors.white.withOpacity(0.6),
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'SFProDisplay',
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 12),
              Icon(
                icon,
                color: enabled
                    ? Color(0xFFFF6EC7)
                    : Colors.white.withOpacity(0.6),
              ),
            ],
          ],
        ),
      ),
    );
  }
}