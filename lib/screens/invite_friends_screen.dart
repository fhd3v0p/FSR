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
  bool _isLoading = false;
  String? _referralCode;
  String? _referralLink;
  int _invitesSent = 0;

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

  Future<void> _shareWithFriends() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (TelegramWebAppService.isTelegramWebApp) {
        // Используем Telegram Web App API для открытия диалога выбора чатов
        final success = await _openTelegramShareDialog();
        if (success) {
          _showSuccess('Диалог выбора чатов открыт! Выберите друзей для отправки приглашения.');
        }
      } else {
        // Fallback для браузера
        _showBrowserInstructions();
      }
    } catch (e) {
      _showError('Ошибка открытия диалога: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _openTelegramShareDialog() async {
    try {
      // Генерируем текст приглашения
      final inviteText = _generateInviteText();
      
      // Используем Telegram Web App API для открытия диалога выбора чатов
      final result = await TelegramWebAppService.showPopup(
        title: 'Поделиться с друзьями',
        message: 'Выберите друзей для отправки приглашения в FSR',
        buttons: [
          {
            'id': 'share_contacts',
            'type': 'share_contacts',
            'text': 'Выбрать из контактов'
          },
          {
            'id': 'share_chats',
            'type': 'share_chats', 
            'text': 'Выбрать из чатов'
          },
          {
            'id': 'share_link',
            'type': 'share_link',
            'text': 'Поделиться ссылкой'
          },
          {
            'id': 'cancel',
            'type': 'cancel',
            'text': 'Отмена'
          }
        ],
      );

      if (result != null) {
        switch (result['button_id']) {
          case 'share_contacts':
            return await _shareWithContacts();
          case 'share_chats':
            return await _shareWithChats();
          case 'share_link':
            return await _shareLink();
          default:
            return false;
        }
      }
      
      return false;
    } catch (e) {
      print('Error opening share dialog: $e');
      return false;
    }
  }

  Future<bool> _shareWithContacts() async {
    try {
      // Получаем список контактов
      final contacts = await TelegramWebAppService.getContacts();
      if (contacts != null && contacts.isNotEmpty) {
        // Показываем диалог выбора контактов
        final selectedContacts = await _showContactSelectionDialog(contacts);
        if (selectedContacts != null && selectedContacts.isNotEmpty) {
          // Отправляем приглашения выбранным контактам
          return await _sendInvitesToContacts(selectedContacts);
        }
      } else {
        _showError('У вас нет контактов для приглашения');
      }
      return false;
    } catch (e) {
      print('Error sharing with contacts: $e');
      return false;
    }
  }

  Future<bool> _shareWithChats() async {
    try {
      // Получаем список чатов
      final chats = await TelegramWebAppService.getChats();
      if (chats != null && chats.isNotEmpty) {
        // Показываем диалог выбора чатов
        final selectedChats = await _showChatSelectionDialog(chats);
        if (selectedChats != null && selectedChats.isNotEmpty) {
          // Отправляем приглашения в выбранные чаты
          return await _sendInvitesToChats(selectedChats);
        }
      } else {
        _showError('У вас нет чатов для приглашения');
      }
      return false;
    } catch (e) {
      print('Error sharing with chats: $e');
      return false;
    }
  }

  Future<bool> _shareLink() async {
    try {
      // Используем Telegram Web App API для копирования ссылки в буфер обмена
      final result = await TelegramWebAppService.copyToClipboard(_referralLink ?? '');
      
      if (result) {
        _showSuccess('Ссылка скопирована в буфер обмена! Теперь можете поделиться ею вручную.');
        return true;
      }
      return false;
    } catch (e) {
      print('Error sharing link: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> _showContactSelectionDialog(List<Map<String, dynamic>> contacts) async {
    try {
      final result = await TelegramWebAppService.showPopup(
        title: 'Выберите контакты',
        message: 'Выберите контакты для отправки приглашения',
        buttons: contacts.take(10).map((contact) => {
          'id': 'contact_${contact['id']}',
          'type': 'select',
          'text': '${contact['first_name']} ${contact['last_name'] ?? ''}'
        }).toList()..add({
          'id': 'confirm',
          'type': 'confirm',
          'text': 'Отправить выбранным'
        })..add({
          'id': 'cancel',
          'type': 'cancel',
          'text': 'Отмена'
        }),
      );

      if (result != null && result['button_id'] == 'confirm') {
        // Возвращаем выбранные контакты
        return contacts.where((contact) => 
          result['selected_ids']?.contains('contact_${contact['id']}') == true
        ).map((contact) => {
          'id': contact['id'],
          'name': '${contact['first_name']} ${contact['last_name'] ?? ''}',
          'username': contact['username'],
          'type': 'contact'
        }).toList();
      }
      
      return null;
    } catch (e) {
      print('Error showing contact selection: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> _showChatSelectionDialog(List<Map<String, dynamic>> chats) async {
    try {
      final result = await TelegramWebAppService.showPopup(
        title: 'Выберите чаты',
        message: 'Выберите чаты для отправки приглашения',
        buttons: chats.take(10).map((chat) => {
          'id': 'chat_${chat['id']}',
          'type': 'select',
          'text': chat['title'] ?? chat['username'] ?? 'Unknown'
        }).toList()..add({
          'id': 'confirm',
          'type': 'confirm',
          'text': 'Отправить в выбранные'
        })..add({
          'id': 'cancel',
          'type': 'cancel',
          'text': 'Отмена'
        }),
      );

      if (result != null && result['button_id'] == 'confirm') {
        // Возвращаем выбранные чаты
        return chats.where((chat) => 
          result['selected_ids']?.contains('chat_${chat['id']}') == true
        ).map((chat) => {
          'id': chat['id'],
          'name': chat['title'] ?? chat['username'] ?? 'Unknown',
          'type': 'chat'
        }).toList();
      }
      
      return null;
    } catch (e) {
      print('Error showing chat selection: $e');
      return null;
    }
  }

  Future<bool> _sendInvitesToContacts(List<Map<String, dynamic>> contacts) async {
    try {
      int successCount = 0;
      final inviteText = _generateInviteText();
      
      for (final contact in contacts) {
        try {
          final success = await TelegramWebAppService.sendMessage(
            contact['id'].toString(),
            inviteText,
            parseMode: 'HTML'
          );
          
          if (success) {
            successCount++;
          }
        } catch (e) {
          print('Error sending invite to contact ${contact['name']}: $e');
        }
      }

      if (successCount > 0) {
        setState(() {
          _invitesSent += successCount;
        });
        _showSuccess('Приглашения отправлены $successCount контактам! 🎉');
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error sending invites to contacts: $e');
      return false;
    }
  }

  Future<bool> _sendInvitesToChats(List<Map<String, dynamic>> chats) async {
    try {
      int successCount = 0;
      final inviteText = _generateInviteText();
      
      for (final chat in chats) {
        try {
          final success = await TelegramWebAppService.sendMessage(
            chat['id'].toString(),
            inviteText,
            parseMode: 'HTML'
          );
          
          if (success) {
            successCount++;
          }
        } catch (e) {
          print('Error sending invite to chat ${chat['name']}: $e');
        }
      }

      if (successCount > 0) {
        setState(() {
          _invitesSent += successCount;
        });
        _showSuccess('Приглашения отправлены в $successCount чатов! 🎉');
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error sending invites to chats: $e');
      return false;
    }
  }

  Future<dynamic> _callTelegramMethod(String method, [Map<String, dynamic>? params]) async {
    return TelegramWebAppService.callTelegramMethod(method, params);
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
                    'Поделиться с друзьями',
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
                    'Пригласи друзей и получи бонусы',
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
                  
                  // Статистика приглашений
                  if (_invitesSent > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        border: Border.all(color: Colors.green.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Приглашений отправлено: $_invitesSent',
                            style: const TextStyle(
                              color: Colors.green,
                              fontFamily: 'NauryzKeds',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Кнопка поделиться
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _shareWithFriends,
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.share, color: Colors.white, size: 28),
                      label: Text(
                        _isLoading ? 'Открытие диалога...' : 'Поделиться с друзьями',
                        style: const TextStyle(
                          fontFamily: 'NauryzKeds',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6EC7),
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        elevation: 0,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Дополнительная информация
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 Как это работает:',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'NauryzKeds',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. Нажмите "Поделиться с друзьями"\n'
                          '2. Выберите друзей из контактов или чатов\n'
                          '3. Отправьте им приглашение\n'
                          '4. Получите бонусы за каждого друга!',
                          style: TextStyle(
                            color: Colors.white70,
                            fontFamily: 'NauryzKeds',
                            fontSize: 14,
                          ),
                        ),
                      ],
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