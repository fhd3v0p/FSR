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