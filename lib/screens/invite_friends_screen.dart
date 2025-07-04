import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/material.dart';
import '../services/telegram_webapp_service.dart';

class InviteFriendsScreen extends StatefulWidget {
  final String? referralCode;
  
  const InviteFriendsScreen({super.key, this.referralCode});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  List<Map<String, dynamic>> _selectedContacts = [];
  bool _isLoading = false;
  String? _referralCode;
  String? _referralLink;

  @override
  void initState() {
    super.initState();
    _referralCode = widget.referralCode ?? TelegramWebAppService.getUserId();
    _generateReferralLink();
  }

  void _generateReferralLink() {
    if (_referralCode != null) {
      _referralLink = "https://t.me/FSRUBOT?start=ref$_referralCode";
    }
  }

  Future<void> _selectContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Проверяем, запущено ли приложение в Telegram
      if (TelegramWebAppService.isTelegramWebApp) {
        // Используем Telegram Web App API для выбора контактов
        final contacts = await _selectContactsTelegram();
        if (contacts != null) {
          setState(() {
            _selectedContacts = contacts;
          });
        }
      } else {
        // Fallback для браузера - показываем инструкцию
        _showBrowserInstructions();
      }
    } catch (e) {
      _showError('Ошибка выбора контактов: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>?> _selectContactsTelegram() async {
    try {
      final webApp = js.context['Telegram']['WebApp'];
      
      // Используем Telegram Web App API для выбора контактов
      final result = await _callTelegramMethod('showPopup', {
        'title': 'Выберите друзей',
        'message': 'Выберите друзей для приглашения в FSR',
        'buttons': [
          {
            'id': 'select_contacts',
            'type': 'select_contacts',
            'text': 'Выбрать контакты'
          },
          {
            'id': 'cancel',
            'type': 'cancel',
            'text': 'Отмена'
          }
        ]
      });

      if (result != null && result['button_id'] == 'select_contacts') {
        // Получаем выбранные контакты
        final contacts = await _callTelegramMethod('getContacts');
        if (contacts != null && contacts is List) {
          return contacts.map((contact) => {
            'id': contact['user_id'],
            'name': contact['first_name'] + (contact['last_name'] != null ? ' ${contact['last_name']}' : ''),
            'username': contact['username'],
            'phone': contact['phone_number'],
          }).toList();
        }
      }
      
      return null;
    } catch (e) {
      print('Error selecting contacts: $e');
      return null;
    }
  }

  Future<dynamic> _callTelegramMethod(String method, [Map<String, dynamic>? params]) async {
    try {
      final webApp = js.context['Telegram']['WebApp'];
      if (params != null) {
        return webApp.callMethod(method, [js.JsObject.jsify(params)]);
      } else {
        return webApp.callMethod(method);
      }
    } catch (e) {
      print('Error calling Telegram method $method: $e');
      return null;
    }
  }

  void _showBrowserInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          'Приглашение друзей',
          style: TextStyle(color: Colors.white, fontFamily: 'NauryzKeds'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Для приглашения друзей:',
              style: TextStyle(color: Colors.white, fontFamily: 'NauryzKeds'),
            ),
            const SizedBox(height: 12),
            const Text(
              '1. Скопируйте ссылку ниже\n'
              '2. Отправьте друзьям в Telegram\n'
              '3. За каждого приглашенного друга получите +100 XP',
              style: TextStyle(color: Colors.white70, fontFamily: 'NauryzKeds'),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border.all(color: Colors.white24),
              ),
              child: SelectableText(
                _referralLink ?? 'Ошибка генерации ссылки',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Закрыть',
              style: TextStyle(color: Color(0xFFFF6EC7)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendInvites() async {
    if (_selectedContacts.isEmpty) {
      _showError('Выберите хотя бы одного друга');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      int successCount = 0;
      
      for (final contact in _selectedContacts) {
        try {
          // Отправляем приглашение через Telegram API
          final success = await _sendInviteToContact(contact);
          if (success) {
            successCount++;
          }
        } catch (e) {
          print('Error sending invite to ${contact['name']}: $e');
        }
      }

      if (successCount > 0) {
        _showSuccess('Приглашения отправлены $successCount друзьям! 🎉');
        setState(() {
          _selectedContacts.clear();
        });
      } else {
        _showError('Не удалось отправить приглашения');
      }
    } catch (e) {
      _showError('Ошибка отправки приглашений: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _sendInviteToContact(Map<String, dynamic> contact) async {
    try {
      final inviteText = _generateInviteText();
      
      // Используем Telegram Web App API для отправки сообщения
      final result = await _callTelegramMethod('sendMessage', {
        'chat_id': contact['id'],
        'text': inviteText,
        'parse_mode': 'HTML'
      });

      return result != null;
    } catch (e) {
      print('Error sending invite: $e');
      return false;
    }
  }

  String _generateInviteText() {
    return '''
🔥 <b>Привет! Нашел крутую платформу для поиска артистов - Fresh Style Russia!</b>

🎯 <b>Что тут есть:</b>
• AI-поиск мастеров по фото
• Каталог артистов по городам  
• Розыгрыш на 170,000₽
• Бьюти-услуги и сертификаты

🎁 <b>Присоединяйся по моей ссылке и получи бонусы:</b>
<a href="$_referralLink">🚀 Открыть FSR</a>

💎 <b>Вместе выиграем призы!</b>

#FSR #FreshStyleRussia #Giveaway
    ''';
  }

  void _showError(String message) {
    TelegramWebAppService.showAlert(message);
  }

  void _showSuccess(String message) {
    TelegramWebAppService.showAlert(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/giveaway_banner.png',
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Пригласи друзей',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'NauryzKeds',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'И получи бонусы за каждого друга',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'NauryzKeds',
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Информация о бонусах
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.star, color: Color(0xFFFF6EC7), size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Бонусы за приглашения:',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'NauryzKeds',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 20),
                            SizedBox(width: 12),
                            Text(
                              '+100 XP тебе за каждого друга',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'NauryzKeds',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 20),
                            SizedBox(width: 12),
                            Text(
                              '+100 XP другу за регистрацию',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'NauryzKeds',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 20),
                            SizedBox(width: 12),
                            Text(
                              'Шанс выиграть призы на 170,000₽',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'NauryzKeds',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Выбранные контакты
                  if (_selectedContacts.isNotEmpty) ...[
                    Text(
                      'Выбрано друзей: ${_selectedContacts.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'NauryzKeds',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _selectedContacts.length,
                        itemBuilder: (context, index) {
                          final contact = _selectedContacts[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFFF6EC7),
                                  child: Text(
                                    contact['name'][0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        contact['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'NauryzKeds',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (contact['username'] != null)
                                        Text(
                                          '@${contact['username']}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontFamily: 'NauryzKeds',
                                            fontSize: 14,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _selectedContacts.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Кнопки действий
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _selectContacts,
                          icon: _isLoading 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.people, color: Colors.white),
                          label: Text(
                            _isLoading ? 'Загрузка...' : 'Выбрать друзей',
                            style: const TextStyle(
                              fontFamily: 'NauryzKeds',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.08),
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide(color: Colors.white, width: 1.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                        ),
                      ),
                      if (_selectedContacts.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _sendInvites,
                            icon: const Icon(Icons.send, color: Colors.white),
                            label: const Text(
                              'Отправить',
                              style: TextStyle(
                                fontFamily: 'NauryzKeds',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6EC7),
                              foregroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ],
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