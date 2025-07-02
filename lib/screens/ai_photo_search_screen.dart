import 'package:flutter/material.dart';
import 'master_cloud_screen.dart'; // Импортируем для доступа к категориям

class AiPhotoSearchScreen extends StatefulWidget {
  const AiPhotoSearchScreen({super.key});

  @override
  State<AiPhotoSearchScreen> createState() => _AiPhotoSearchScreenState();
}

class _AiPhotoSearchScreenState extends State<AiPhotoSearchScreen> {
  late List<String> categories;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    // Получаем категории из master_cloud_screen.dart
    categories = MasterCloudScreen.categories; // Предполагается, что это static поле
    selectedCategory = categories.isNotEmpty ? categories.first : null;
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
                      fontFamily: 'NauryzKeds', // Lepka → NauryzKeds
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
                      fontFamily: 'NauryzKeds', // SFProDisplay → NauryzKeds
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
                    'Загрузите фото-референс\nдля AI-подбора артиста', // мастер → артист
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'NauryzKeds', // Lepka → NauryzKeds
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: реализовать загрузку фото
                    },
                    icon: const Icon(Icons.upload_file_rounded, color: Colors.white), // белая иконка
                    label: const Text(
                      'Загрузить фото',
                      style: TextStyle(
                        fontFamily: 'NauryzKeds', // SFProDisplay → NauryzKeds
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white, // белый текст
                        letterSpacing: 1.1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.08), // прозрачность как на giveaway
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // острые углы
                        side: BorderSide(color: Colors.white, width: 1.5), // белая окантовка
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