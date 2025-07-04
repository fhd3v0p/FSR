import 'package:flutter/material.dart';
import 'master_cloud_screen.dart';
import '../services/telegram_webapp_service.dart';
import '../models/photo_upload_model.dart';

class AiPhotoSearchScreen extends StatefulWidget {
  const AiPhotoSearchScreen({super.key});

  @override
  State<AiPhotoSearchScreen> createState() => _AiPhotoSearchScreenState();
}

class _AiPhotoSearchScreenState extends State<AiPhotoSearchScreen> {
  late List<String> categories;
  String? selectedCategory;
  bool _isUploading = false;
  PhotoUploadModel? _lastUploadedPhoto;

  @override
  void initState() {
    super.initState();
    // Получаем категории из master_cloud_screen.dart
    categories = MasterCloudScreen.categories;
    selectedCategory = categories.isNotEmpty ? categories.first : null;
  }

  Future<void> _uploadPhoto() async {
    if (selectedCategory == null) {
      _showError('Пожалуйста, выберите категорию');
      return;
    }

    if (!TelegramWebAppService.isTelegramWebApp) {
      _showError('Эта функция доступна только в Telegram');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final photoUpload = await TelegramWebAppService.uploadPhoto(
        category: selectedCategory!,
        description: 'AI photo search reference',
      );

      if (photoUpload != null) {
        setState(() {
          _lastUploadedPhoto = photoUpload;
        });
        
        _showSuccess('Фото успешно загружено! Мы найдем для вас подходящего артиста.');
        
        // Здесь можно добавить логику для перехода к результатам поиска
        // или показать превью загруженного фото
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
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
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 60),
                  const SizedBox(height: 24),
                  const Text(
                    'Выберите категорию',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'NauryzKeds',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  DropdownButton<String>(
                    value: selectedCategory,
                    dropdownColor: Colors.black87,
                    iconEnabledColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'NauryzKeds',
                      fontSize: 18,
                    ),
                    items: categories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCategory = val;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Загрузите фото-референс\nдля AI-подбора артиста',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'NauryzKeds',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Поддерживаются только фото и видео файлы\nМаксимальный размер: 10MB',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'NauryzKeds',
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Показываем информацию о последнем загруженном фото
                  if (_lastUploadedPhoto != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        border: Border.all(color: Colors.green.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 24),
                          const SizedBox(height: 8),
                          Text(
                            'Фото загружено: ${_lastUploadedPhoto!.fileName}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontFamily: 'NauryzKeds',
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Категория: ${_lastUploadedPhoto!.category}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontFamily: 'NauryzKeds',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadPhoto,
                    icon: _isUploading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.upload_file_rounded, color: Colors.white),
                    label: Text(
                      _isUploading ? 'Загрузка...' : 'Загрузить фото',
                      style: const TextStyle(
                        fontFamily: 'NauryzKeds',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isUploading 
                          ? Colors.white.withOpacity(0.04)
                          : Colors.white.withOpacity(0.08),
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(color: Colors.white, width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 22),
                      elevation: 0,
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