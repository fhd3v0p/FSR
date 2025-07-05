import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import '../models/photo_upload_model.dart';

class TelegramWebAppService {
  static const String _telegramWebAppVar = 'Telegram.WebApp';
  
  // Проверяем, запущено ли приложение в Telegram
  static bool get isTelegramWebApp {
    try {
      return js.context.hasProperty('Telegram') && 
             js.context['Telegram'].hasProperty('WebApp');
    } catch (e) {
      return false;
    }
  }

  // Получаем данные пользователя
  static Map<String, dynamic>? getUserData() {
    if (!isTelegramWebApp) return null;
    
    try {
      final webApp = js.context['Telegram']['WebApp'];
      final initData = webApp['initData'];
      final user = webApp['initDataUnsafe']['user'];
      
      if (user != null) {
        return {
          'id': user['id'],
          'first_name': user['first_name'],
          'last_name': user['last_name'],
          'username': user['username'],
          'language_code': user['language_code'],
        };
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Получаем ID пользователя
  static String? getUserId() {
    final userData = getUserData();
    return userData?['id']?.toString();
  }

  // Вызываем метод Telegram Web App API
  static Future<dynamic> callTelegramMethod(String method, [Map<String, dynamic>? params]) async {
    if (!isTelegramWebApp) return null;
    
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

  // Получаем список контактов
  static Future<List<Map<String, dynamic>>?> getContacts() async {
    try {
      final contacts = await callTelegramMethod('getContacts');
      if (contacts != null && contacts is List) {
        return contacts.map((contact) => {
          'id': contact['user_id'],
          'first_name': contact['first_name'],
          'last_name': contact['last_name'],
          'username': contact['username'],
          'phone_number': contact['phone_number'],
        }).toList();
      }
      return null;
    } catch (e) {
      print('Error getting contacts: $e');
      return null;
    }
  }

  // Получаем список чатов
  static Future<List<Map<String, dynamic>>?> getChats() async {
    try {
      final chats = await callTelegramMethod('getChats');
      if (chats != null && chats is List) {
        return chats.map((chat) => {
          'id': chat['id'],
          'title': chat['title'],
          'username': chat['username'],
          'type': chat['type'],
        }).toList();
      }
      return null;
    } catch (e) {
      print('Error getting chats: $e');
      return null;
    }
  }

  // Отправляем сообщение
  static Future<bool> sendMessage(String chatId, String text, {String? parseMode}) async {
    try {
      final params = {
        'chat_id': chatId,
        'text': text,
      };
      
      if (parseMode != null) {
        params['parse_mode'] = parseMode;
      }
      
      final result = await callTelegramMethod('sendMessage', params);
      return result != null;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // Копируем текст в буфер обмена
  static Future<bool> copyToClipboard(String text) async {
    try {
      final result = await callTelegramMethod('copyToClipboard', {'text': text});
      return result == true;
    } catch (e) {
      print('Error copying to clipboard: $e');
      return false;
    }
  }

  // Показываем popup с кнопками (правильный метод Telegram Web App API)
  static Future<Map<String, dynamic>?> showMainButtonPopup({
    required String title,
    required String message,
    required List<Map<String, dynamic>> buttons,
  }) async {
    try {
      final webApp = js.context['Telegram']['WebApp'];
      
      // Используем правильный метод Telegram Web App API
      final result = await webApp.callMethod('showPopup', [{
        'title': title,
        'message': message,
        'buttons': buttons,
      }]);
      
      return result;
    } catch (e) {
      print('Error showing popup: $e');
      return null;
    }
  }

  // Новый метод для отправки сообщений через shareMessage
  static Future<bool> shareMessage(String messageId, {Function(bool)? callback}) async {
    try {
      final webApp = js.context['Telegram']['WebApp'];
      
      if (callback != null) {
        // С callback
        await webApp.callMethod('shareMessage', [messageId, (bool success) {
          callback(success);
        }]);
      } else {
        // Без callback
        await webApp.callMethod('shareMessage', [messageId]);
      }
      
      return true;
    } catch (e) {
      print('Error sharing message: $e');
      return false;
    }
  }

  // Метод для создания и сохранения подготовленного сообщения
  static Future<String?> createPreparedMessage({
    required String title,
    required String description,
    required String messageText,
    String? parseMode,
  }) async {
    try {
      // Отправляем запрос на сервер для создания подготовленного сообщения
      final response = await html.HttpRequest.request(
        'https://fsr.agency/api/create-prepared-message',
        method: 'POST',
        sendData: jsonEncode({
          'title': title,
          'description': description,
          'message_text': messageText,
          'parse_mode': parseMode ?? 'HTML',
          'user_id': getUserId(),
        }),
        requestHeaders: {
          'Content-Type': 'application/json',
        },
      );

      if (response.status == 200) {
        final data = jsonDecode(response.responseText ?? '{}');
        return data['message_id'];
      }
      
      return null;
    } catch (e) {
      print('Error creating prepared message: $e');
      return null;
    }
  }

  // Простой метод для приглашения друзей через Telegram Web App API
  static Future<bool> inviteFriendsWithShare() async {
    try {
      final userId = getUserId();
      if (userId == null) {
        showAlert('Откройте приложение в Telegram для использования этой функции!');
        return false;
      }

      // Создаем реферальную ссылку
      final referralLink = "https://t.me/FSRUBOT?start=ref$userId";
      // Создаем текст приглашения
      final inviteText = '''
🔥 Привет! Нашел крутую платформу для поиска артистов - Fresh Style Russia!

🎯 Что тут есть:
• AI-поиск мастеров по фото
• Каталог артистов по городам  
• Розыгрыш на 170,000₽
• Бьюти-услуги и сертификаты

🎁 Присоединяйся по моей ссылке и получи бонусы:
$referralLink

💎 Вместе выиграем призы!
#FSR #FreshStyleRussia #Giveaway
      ''';

      // Всегда используем fallback для надежности
      try {
        // Открываем Telegram share через ссылку (работает везде)
        final url = 'https://t.me/share/url?url=' +
            Uri.encodeComponent(referralLink) +
            '&text=' +
            Uri.encodeComponent(inviteText);
        
        // Открываем в новом окне/вкладке
        html.window.open(url, '_blank');
        
        // Убираем уведомление - пользователь сам увидит диалог
        return true;
        
      } catch (e) {
        // Если не удалось открыть ссылку, показываем popup с опциями
        final result = await showMainButtonPopup(
          title: 'Поделиться с друзьями',
          message: 'Выберите способ приглашения:',
          buttons: [
            {
              'id': 'copy_link',
              'type': 'default',
              'text': '📋 Скопировать ссылку'
            },
            {
              'id': 'show_link',
              'type': 'default',
              'text': '🔗 Показать ссылку'
            },
            {
              'id': 'share_text',
              'type': 'default',
              'text': '📤 Поделиться текстом'
            },
            {
              'id': 'cancel',
              'type': 'cancel',
              'text': '❌ Отмена'
            }
          ],
        );

        if (result != null) {
          switch (result['button_id']) {
            case 'copy_link':
              return await copyToClipboard(referralLink);
            case 'show_link':
              showAlert('Ссылка для приглашения:\n\n$referralLink\n\nСкопируйте эту ссылку и отправьте друзьям!');
              return true;
            case 'share_text':
              return await copyToClipboard(inviteText);
            default:
              return false;
          }
        }
        return false;
      }
    } catch (e) {
      print('Error inviting friends with share: $e');
      showAlert('Откройте приложение в Telegram для использования этой функции!');
      return false;
    }
  }

  // Метод для отправки текста в Telegram
  static Future<bool> _shareTextToTelegram(String text) async {
    try {
      // Используем Telegram Web App API для отправки сообщения
      final webApp = js.context['Telegram']['WebApp'];
      
      // Показываем popup с текстом для копирования
      final result = await webApp.callMethod('showPopup', [{
        'title': 'Текст для отправки',
        'message': 'Скопируйте этот текст и отправьте друзьям:',
        'buttons': [
          {
            'id': 'copy_text',
            'type': 'default',
            'text': '📋 Скопировать текст'
          },
          {
            'id': 'cancel',
            'type': 'cancel',
            'text': '❌ Отмена'
          }
        ]
      }]);

      if (result != null && result['button_id'] == 'copy_text') {
        return await copyToClipboard(text);
      }
      
      return false;
    } catch (e) {
      print('Error sharing text to Telegram: $e');
      return false;
    }
  }

  // Fallback метод для показа опций поделиться
  static Future<bool> _showFallbackShareOptions(String? userId) async {
    try {
      final referralLink = "https://t.me/FSRUBOT?start=ref${userId ?? 'user'}";
      
      // Простой fallback - показываем ссылку в alert
      showAlert('Ссылка для приглашения друзей:\n\n$referralLink\n\nСкопируйте эту ссылку и отправьте друзьям!');
      return true;
    } catch (e) {
      print('Error showing fallback share options: $e');
      return false;
    }
  }

  // Запрашиваем доступ на запись (для отправки сообщений)
  static Future<bool> requestWriteAccess() async {
    try {
      final webApp = js.context['Telegram']['WebApp'];
      
      // Запрашиваем разрешение на отправку сообщений
      final result = await webApp.callMethod('requestWriteAccess');
      return result == true;
    } catch (e) {
      print('Error requesting write access: $e');
      return false;
    }
  }

  // Показываем popup с кнопками (старый метод для совместимости)
  static Future<Map<String, dynamic>?> showPopup({
    required String title,
    required String message,
    required List<Map<String, dynamic>> buttons,
  }) async {
    return showMainButtonPopup(
      title: title,
      message: message,
      buttons: buttons,
    );
  }

  // Загружаем фото через HTML5 File API
  static Future<PhotoUploadModel?> uploadPhoto({
    required String category,
    String? description,
  }) async {
    try {
      // Генерируем временный ID пользователя если не в Telegram
      final userId = getUserId() ?? 'web_user_${DateTime.now().millisecondsSinceEpoch}';

      // Вызываем HTML5 File API для выбора файла
      final result = await _selectFile();
      
      if (result == null) {
        return null; // Пользователь отменил выбор
      }

      // Проверяем, что это фото или видео
      if (!_isValidMediaType(result['mime_type'])) {
        throw Exception('Пожалуйста, выберите только фото или видео файл');
      }

      // Создаем модель для сохранения в БД
      final photoUpload = PhotoUploadModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        category: category,
        fileId: result['file_id'],
        fileName: result['file_name'],
        fileSize: result['file_size'],
        mimeType: result['mime_type'],
        uploadDate: DateTime.now(),
        description: description,
      );

      // Отправляем данные на сервер для сохранения в БД
      await _saveToDatabase(photoUpload);

      return photoUpload;
    } catch (e) {
      print('Error uploading photo: $e');
      rethrow;
    }
  }

  // Выбор файла через HTML5 File API
  static Future<Map<String, dynamic>?> _selectFile() async {
    try {
      final completer = Completer<Map<String, dynamic>?>();
      
      // Создаем input элемент для выбора файла
      final input = html.FileUploadInputElement()
        ..accept = 'image/*,video/*'
        ..multiple = false;
      
      input.onChange.listen((event) {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          final file = files.first;
          
          // Проверяем размер файла (максимум 10MB)
          if (file.size > 10 * 1024 * 1024) {
            completer.completeError('Файл слишком большой. Максимальный размер: 10MB');
            return;
          }

          // Читаем файл как base64
          final reader = html.FileReader();
          reader.onLoad.listen((e) {
            final result = reader.result as String;
            final base64Data = result.split(',')[1]; // Убираем data:image/...;base64,
            
            completer.complete({
              'file_id': DateTime.now().millisecondsSinceEpoch.toString(),
              'file_name': file.name,
              'file_size': file.size,
              'mime_type': file.type,
              'base64_data': base64Data,
            });
          });
          
          reader.readAsDataUrl(file);
        } else {
          completer.complete(null);
        }
      });
      
      // Симулируем клик для открытия диалога выбора файла
      input.click();
      
      return await completer.future;
    } catch (e) {
      print('Error selecting file: $e');
      return null;
    }
  }

  // Проверяем, что файл является фото или видео
  static bool _isValidMediaType(String mimeType) {
    return mimeType.startsWith('image/') || mimeType.startsWith('video/');
  }

  // Сохраняем данные в базу данных через API
  static Future<void> _saveToDatabase(PhotoUploadModel photoUpload) async {
    try {
      // Отправляем данные на ваш сервер
      final response = await html.HttpRequest.request(
        'https://fsr.agency/api/upload-photo',
        method: 'POST',
        sendData: jsonEncode(photoUpload.toJson()),
        requestHeaders: {
          'Content-Type': 'application/json',
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to save photo to database');
      }
    } catch (e) {
      print('Error saving to database: $e');
      // В реальном приложении здесь можно добавить fallback логику
      // Например, сохранить в localStorage и отправить позже
    }
  }

  // Показываем уведомление пользователю
  static void showAlert(String message) {
    if (isTelegramWebApp) {
      try {
        final webApp = js.context['Telegram']['WebApp'];
        webApp.callMethod('showAlert', [message]);
      } catch (e) {
        print('Error showing alert: $e');
        // Fallback к обычному alert
        html.window.alert(message);
      }
    } else {
      // Используем обычный alert для браузера
      html.window.alert(message);
    }
  }

  // Показываем подтверждение пользователю
  static Future<bool> showConfirm(String message) async {
    if (isTelegramWebApp) {
      try {
        final webApp = js.context['Telegram']['WebApp'];
        final result = webApp.callMethod('showConfirm', [message]);
        return result == true;
      } catch (e) {
        print('Error showing confirm: $e');
        // Fallback к обычному confirm
        return html.window.confirm(message);
      }
    } else {
      // Используем обычный confirm для браузера
      return html.window.confirm(message);
    }
  }
} 