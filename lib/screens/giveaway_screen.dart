import 'package:flutter/material.dart';
import 'role_selection_screen.dart';
import 'invite_friends_screen.dart';
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

  void _showPrizesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          '🎁 Подарки гивевея',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'NauryzKeds',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PrizeCard(
                title: 'Сертификат в ZARA',
                description: 'Сертификат на покупки в ZARA на сумму 20,000 рублей',
                value: '20,000₽',
                icon: Icons.shopping_bag,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              _PrizeCard(
                title: 'Бьюти-услуги',
                description: 'Комплекс бьюти-услуг на сумму 100,000 рублей (маникюр, педикюр, окрашивание, стрижка, макияж)',
                value: '100,000₽',
                icon: Icons.face,
                color: Colors.pink,
              ),
              const SizedBox(height: 16),
              _PrizeCard(
                title: 'VIP-статус',
                description: 'Приоритетный доступ к новым артистам и эксклюзивным предложениям',
                value: '50,000₽',
                icon: Icons.star,
                color: Colors.amber,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6EC7).withOpacity(0.2),
                  border: Border.all(color: const Color(0xFFFF6EC7)),
                ),
                child: const Text(
                  '🏆 Общая стоимость призов: 170,000₽',
                  style: TextStyle(
                    color: Color(0xFFFF6EC7),
                    fontFamily: 'NauryzKeds',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Закрыть',
              style: TextStyle(
                color: Color(0xFFFF6EC7),
                fontFamily: 'NauryzKeds',
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
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
                // Мэйн баннер опущен вниз на 20% экрана
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.20,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Image.asset(
                    'assets/giveaway_banner.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  color: Colors.black.withOpacity(0.25),
                ),
              ],
            ),
          ),
          // Контент поверх фона
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.10), // 10% экрана отступ сверху
                // Бокс для заголовка GIVEAWAY — максимально большой
                Container(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'GIVEAWAY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NauryzKeds',
                        letterSpacing: 2,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8), // минимальный отступ между GIVEAWAY и таймером
                // Бокс для таймера — максимально большой
                Container(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formatDuration(_timeLeft),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 220,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -2,
                        fontFamily: 'NauryzKeds',
                        height: 0.9,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8), // минимальный отступ до следующего блока
                const Spacer(), // Всё что ниже таймера — уходит вниз
                // Кнопка "Подарки"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      _showPrizesDialog();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6EC7).withOpacity(0.2),
                        border: Border.all(color: const Color(0xFFFF6EC7), width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.card_giftcard, color: Color(0xFFFF6EC7), size: 24),
                          const SizedBox(width: 12),
                          const Text(
                            'Подарки',
                            style: TextStyle(
                              color: Color(0xFFFF6EC7),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NauryzKeds',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Список заданий и кнопка
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: Column(
                    children: [
                      _TaskTile(
                        title: 'Подписаться на Telegram-папку',
                        subtitle: '10 каналов одним кликом\n+1000 XP',
                        icon: Icons.folder_special,
                        onTap: () async {
                          const url = 'https://t.me/addlist/f3YaeLmoNsdkYjVl';
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
                          // Открываем экран приглашения друзей
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const InviteFriendsScreen(),
                            ),
                          );
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
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 350),
                        ),
                      );
                    },
                    enabled: true, // Всегда активна для тестирования
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

class _PrizeCard extends StatelessWidget {
  final String title;
  final String description;
  final String value;
  final IconData icon;
  final Color color;

  const _PrizeCard({
    required this.title,
    required this.description,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'NauryzKeds',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'NauryzKeds',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              border: Border.all(color: color),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontFamily: 'NauryzKeds',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}