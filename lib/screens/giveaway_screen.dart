import 'package:flutter/material.dart';
import 'role_selection_screen.dart';
import 'invite_friends_screen.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart'; // добавлено для kDebugMode
import '../services/telegram_webapp_service.dart';


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

  String? _username;
  int _tickets = 0;
  int _totalTickets = 0;

  final DateTime giveawayDate = DateTime(2025, 7, 20, 20, 0, 0); // 20 июля 2025, 20:00 по МСК

  bool get _isTask1Done => _tickets >= 1; // Подписан на канал (есть 1 билет)
  bool get _isTask2Done => _tickets > 1; // Есть хотя бы 1 приглашённый друг (2+ билета)

  @override
  void initState() {
    super.initState();
    _updateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeLeft();
    });
    _fetchUserTickets();
  }

  void _updateTimeLeft() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 3)); // МСК = UTC+3
    setState(() {
      _timeLeft = giveawayDate.difference(now);
      if (_timeLeft.isNegative) {
        _timeLeft = Duration.zero;
      }
    });
  }

  Future<void> _fetchUserTickets() async {
    try {
      final userId = TelegramWebAppService.getUserId();
      if (userId == null) return;
      final response = await html.HttpRequest.request(
        'https://fsr.agency/api/user/$userId/tickets',
        method: 'GET',
        requestHeaders: {
          'Content-Type': 'application/json',
        },
      );
      if (response.status == 200) {
        final data = jsonDecode(response.responseText ?? '{}');
        setState(() {
          _tickets = data['tickets'] ?? 0;
          _username = data['username'] ?? '';
        });
      }
      // Получаем общее количество билетов
      final totalResponse = await html.HttpRequest.request(
        'https://fsr.agency/api/tickets/total',
        method: 'GET',
        requestHeaders: {
          'Content-Type': 'application/json',
        },
      );
      if (totalResponse.status == 200) {
        final totalData = jsonDecode(totalResponse.responseText ?? '{}');
        setState(() {
          _totalTickets = totalData['total'] ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching tickets: $e');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${d.inHours}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  Future<void> _logTaskCompletion(String userId, String taskName, int taskNumber) async {
    try {
      // Отправляем запрос на сервер для логирования
      final response = await html.HttpRequest.request(
        'https://fsr.agency/api/log-task-completion',
        method: 'POST',
        sendData: jsonEncode({
          'user_id': userId,
          'task_name': taskName,
          'task_number': taskNumber,
        }),
        requestHeaders: {
          'Content-Type': 'application/json',
        },
      );

      if (response.status != 200) {
        print('Error logging task completion: ${response.status}');
      }
    } catch (e) {
      print('Error logging task completion: $e');
    }
  }

  Future<void> _logFolderSubscription(String userId) async {
    try {
      // Отправляем запрос на сервер для логирования подписки на папку
      final response = await html.HttpRequest.request(
        'https://fsr.agency/api/log-folder-subscription',
        method: 'POST',
        sendData: jsonEncode({
          'user_id': userId,
        }),
        requestHeaders: {
          'Content-Type': 'application/json',
        },
      );

      if (response.status != 200) {
        print('Error logging folder subscription: ${response.status}');
      }
    } catch (e) {
      print('Error logging folder subscription: $e');
    }
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
              // Призы
              _PrizeCard(
                title: 'Золотое яблоко',
                descriptionWidget: _buildRichText([
                  TextSpan(text: 'Будет '),
                  TextSpan(text: 'одно', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  TextSpan(text: ' призовое место — сертификат на покупку в '),
                  TextSpan(text: 'Золотом Яблоке', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  TextSpan(text: ' на сумму 20000 рублей'),
                ]),
                value: '20,000₽',
                icon: Icons.emoji_events,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              _PrizeCard(
                title: 'Бьюти-услуги',
                descriptionWidget: _buildRichText([
                  TextSpan(text: '4 победителя,', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  TextSpan(text: ' каждый из которых по очереди может выбрать:\n\n'),
                  TextSpan(text: 'Татуировку до 15 см', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  TextSpan(text: ' у: '),
                  ..._tgLinksInline(['@naidenka_tatto0', '@emi3mo', '@ufantasiesss']),
                  TextSpan(text: '\n'),
                  TextSpan(text: 'Татуировку до 10 см', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  TextSpan(text: ' у: '),
                  ..._tgLinksInline(['@g9r1a', '@murderd0lll']),
                  TextSpan(text: '\n'),
                  TextSpan(text: 'Сертификат на пирсинг', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  TextSpan(text: ' у: '),
                  ..._tgLinksInline(['@bloodivampin']),
                  TextSpan(text: '\n'),
                  TextSpan(text: 'Стрижку ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  TextSpan(text: 'или ', style: TextStyle(color: Colors.white)),
                  TextSpan(text: 'авторский проект', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  TextSpan(text: ' у: '),
                  ..._tgLinksInline(['@punk2_n0t_d34d']),
                  TextSpan(text: '\n'),
                  TextSpan(text: '50% скидку', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  TextSpan(text: ' на любой тату-проект у: '),
                  ..._tgLinksInline(['@chchndra_tattoo']),
                ]),
                value: '100,000₽',
                icon: Icons.spa,
                color: Colors.pink,
              ),
              const SizedBox(height: 16),
              _PrizeCard(
                title: 'Telegram Premium (3 мес)',
                descriptionWidget: _buildRichText([
                  TextSpan(text: ''),
                  TextSpan(text: 'Х3', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  TextSpan(text: ' подписки Telegram Premium на 3 месяца, для тех победителей которые не могут воспользоваться бьюти-услугами артистов.'),
                ]),
                value: '3,500₽',
                icon: Icons.telegram,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              _PrizeCard(
                title: 'Скидки всем',
                descriptionWidget: _buildRichText([
                  TextSpan(text: ''),
                  TextSpan(text: '7% всем участникам', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  TextSpan(text: ', получившим '),
                  TextSpan(text: 'хотя бы 1 билет', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  TextSpan(text: ' розыгрыша на услуги всех резидентов '),
                  TextSpan(text: 'FRESH STYLE RUSSIA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ]),
                value: '7%',
                icon: Icons.percent,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              // Общая стоимость призов по центру снизу
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6EC7).withOpacity(0.2),
                  border: Border.all(color: const Color(0xFFFF6EC7)),
                ),
                child: const Text(
                  '🏆 Общая стоимость призов: > 123,500₽',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'NauryzKeds',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Условия начисления билетов
              Container(
                margin: const EdgeInsets.only(top: 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.confirmation_num, color: Color(0xFFFF6EC7), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Как получить билеты:',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'NauryzKeds',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: Colors.white, fontSize: 16)),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(color: Colors.white, fontFamily: 'OpenSans', fontSize: 15),
                              children: [
                                TextSpan(text: '+1 билет', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                TextSpan(text: ' — за подписку на Telegram-папку (не отписываться до конца розыгрыша, условия проверяются)'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: Colors.white, fontSize: 16)),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(color: Colors.white, fontFamily: 'OpenSans', fontSize: 15),
                              children: [
                                TextSpan(text: '+1 билет', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                TextSpan(text: ' — за каждого друга, который стартует бота по вашей реферальной ссылке'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
    final allTasksDone = _tickets >= 1;
    final task1Done = _isTask1Done;
    final task2Done = _isTask2Done;

    final bool isGoToAppButtonEnabled = allTasksDone; // Активна только если есть хотя бы 1 билет

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Фон: оба баннера друг над другом
          Positioned.fill(
            child: Stack(
              children: [
                // Фоновый баннер на весь экран
                Positioned.fill(
                  child: Image.asset(
                    'assets/giveaway_back_banner.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Мэйн баннер увеличен на 13% и поднят вверх на 5% экрана
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final height = constraints.maxHeight;
                      return Transform.translate(
                        offset: Offset(0, -height * 0.05), // Поднимаем вверх на 5% (было 10%)
                        child: Transform.scale(
                          scale: 1.13,
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/giveaway_banner.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Возвращаем затемнение до 25%
                Container(
                  color: Colors.black.withOpacity(0.25), // вернули к 25%
                ),
              ],
            ),
          ),
          // Контент поверх фона
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Убираем мини-бейдж с username и билетами
                SizedBox(height: MediaQuery.of(context).size.height * 0.05 + 50), // Было 0.05, теперь +50px вниз
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
                // Опускаем все блоки максимально вниз
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                                          // Кнопка "Подарки" с иконкой билета и количеством билетов
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
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
                                const Icon(Icons.card_giftcard, color: Colors.white, size: 24),
                                const SizedBox(width: 12),
                                const Text(
                                  'Подарки',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NauryzKeds',
                                  ),
                                ),
                                const SizedBox(width: 18),
                                // Иконка билета и количество билетов
                                const Icon(Icons.confirmation_num, color: Color(0xFFFF6EC7), size: 22),
                                const SizedBox(width: 4),
                                Text(
                                  _totalTickets > 0 ? '$_tickets/$_totalTickets' : '$_tickets',
                                  style: const TextStyle(
                                    color: Color(0xFFFF6EC7),
                                    fontFamily: 'NauryzKeds',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Список заданий и кнопка
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _TaskTile(
                            title: 'Подписаться на Telegram-папку',
                            subtitle: '10 каналов одним кликом\n+1 билет',
                            icon: Icons.folder_special,
                            onTap: () async {
                              const url = 'https://t.me/addlist/f3YaeLmoNsdkYjVl';
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                              }
                              setState(() {
                                _task1Done = true;
                              });
                              // Проверка подписки на канал
                              try {
                                final userId = TelegramWebAppService.getUserId();
                                if (userId != null) {
                                  // Проверяем подписку через API
                                  final response = await html.HttpRequest.request(
                                    'https://fsr.agency/api/check-subscription',
                                    method: 'POST',
                                    sendData: jsonEncode({
                                      'user_id': userId,
                                      'username': _username,
                                    }),
                                    requestHeaders: {
                                      'Content-Type': 'application/json',
                                    },
                                  );
                                  final data = jsonDecode(response.responseText ?? '{}');
                                  if (data['subscribed'] == true) {
                                    await _logFolderSubscription(userId);
                                    await _logTaskCompletion(userId, 'Подписаться на Telegram-папку', 1);
                                    await _fetchUserTickets(); // Обновить счетчик билетов
                                  } else {
                                    TelegramWebAppService.showAlert('Пожалуйста, подпишитесь на канал!');
                                  }
                                }
                              } catch (e) {
                                print('Error checking subscription: $e');
                              }
                            },
                            done: task1Done,
                            taskNumber: 1,
                            completedTasks: (task1Done ? 1 : 0) + (task2Done ? 1 : 0),
                          ),
                          _TaskTile(
                            title: 'Пригласить друзей',
                            subtitle: 'За каждого друга: +1 билет',
                            icon: Icons.person_add_alt_1,
                            onTap: () async {
                              // Показываем индикатор загрузки
                              setState(() {
                                _task2Done = false;
                              });
                              
                              // Открываем Telegram share popup
                              final success = await TelegramWebAppService.inviteFriendsWithShare();
                              
                              if (success) {
                                setState(() {
                                  _task2Done = true;
                                });
                                // Показываем уведомление об успехе
                                TelegramWebAppService.showAlert('Отлично!');
                                
                                // Логируем выполнение задания
                                try {
                                  final userId = TelegramWebAppService.getUserId();
                                  if (userId != null) {
                                    await _logTaskCompletion(userId, 'Пригласить друзей', 2);
                                  }
                                } catch (e) {
                                  print('Error logging task completion: $e');
                                }
                              } else {
                                // Показываем уведомление об ошибке
                                TelegramWebAppService.showAlert('Не удалось открыть диалог. Попробуйте еще раз.');
                              }
                            },
                            done: task2Done,
                            taskNumber: 2,
                            completedTasks: (task1Done ? 1 : 0) + (task2Done ? 1 : 0),
                          ),
                        ],
                      ),
                    ),
                    // Кнопка "Перейти в приложение" прямо под заданиями
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Уменьшили с 8 на 4 (в 2 раза)
                      child: GradientButton(
                        text: allTasksDone ? 'Перейти в приложение' : 'Выполните задания',
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
                        enabled: isGoToAppButtonEnabled, // Активна если есть хотя бы 1 билет
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Измените _TaskTile, чтобы он показывал счетчик при выполнении:
class _TaskTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool done;
  final int taskNumber;
  final int completedTasks;

  const _TaskTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.done,
    required this.taskNumber,
    required this.completedTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3), // Уменьшили с 8 на 3 (в 3 раза)
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
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      '$completedTasks/2',
                      style: const TextStyle(
                        color: Colors.green,
                        fontFamily: 'NauryzKeds',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      '0/2',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontFamily: 'NauryzKeds',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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

// _PrizeCard: value по центру снизу, иконка слева
class _PrizeCard extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? descriptionWidget;
  final String value;
  final IconData icon;
  final Color color;

  const _PrizeCard({
    required this.title,
    this.description,
    this.descriptionWidget,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                        fontFamily: 'OpenSans', // OpenSans for title
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (descriptionWidget != null)
                      descriptionWidget!
                    else if (description != null)
                      Text(
                        description!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'OpenSans',
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                border: Border.all(color: color),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontFamily: 'NauryzKeds', // цифры оставляем NauryzKeds
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<InlineSpan> _tgLinks(List<String> usernames) {
  return usernames.expand((u) => [
    const TextSpan(text: '\n'),
    WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse('https://t.me/' + u.substring(1))),
        child: Text(
          u,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ),
  ]).toList();
}

List<InlineSpan> _tgLinksInline(List<String> usernames) {
  return usernames.expand((u) => [
    WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse('https://t.me/' + u.substring(1))),
        child: Text(
          u,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ),
    const TextSpan(text: ' '),
  ]).toList();
}

Widget _buildRichText(List<InlineSpan> spans) {
  return RichText(
    text: TextSpan(
      style: const TextStyle(color: Colors.white70, fontFamily: 'OpenSans', fontSize: 14),
      children: spans,
    ),
  );
}