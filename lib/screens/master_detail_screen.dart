import 'package:flutter/material.dart';
import '../models/master_model.dart';
import '../widgets/master_gallery_carousel.dart';

class MasterDetailScreen extends StatefulWidget {
  final MasterModel master;
  const MasterDetailScreen({super.key, required this.master});

  @override
  State<MasterDetailScreen> createState() => _MasterDetailScreenState();
}

class _MasterDetailScreenState extends State<MasterDetailScreen> {
  int? _galleryIndex; // null - обычный режим, >=0 - режим просмотра фото

  void _openGallery(int index) {
    setState(() {
      _galleryIndex = index;
    });
  }

  void _closeGallery() {
    setState(() {
      _galleryIndex = null;
    });
  }

  void _prevPhoto() {
    if (_galleryIndex != null && _galleryIndex! > 0) {
      setState(() {
        _galleryIndex = _galleryIndex! - 1;
      });
    }
  }

  void _nextPhoto() {
    if (_galleryIndex != null && _galleryIndex! < widget.master.gallery.length - 1) {
      setState(() {
        _galleryIndex = _galleryIndex! + 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final master = widget.master;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/master_detail_banner.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.18),
            ),
          ),
          // Контент поверх фона
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Кнопка назад
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8, right: 0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFFF6EC7)),
                    onPressed: () => Navigator.of(context).maybePop(),
                    splashRadius: 24,
                  ),
                ),
                // Бокс с инфо о мастере
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 16, right: 16, left: 0, bottom: 0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.7), width: 2),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(master.avatar),
                          radius: 44,
                          backgroundColor: Colors.transparent,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                master.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NauryzKeds', // заменили Lepka на NauryzKeds
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.telegram, color: Color(0xFFFF6EC7), size: 20),
                                  const SizedBox(width: 6),
                                  Text(master.telegram, style: const TextStyle(color: Colors.white70, fontFamily: 'SFProDisplay')),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.camera_alt_outlined, color: Color(0xFFFF6EC7), size: 20),
                                  const SizedBox(width: 6),
                                  Text(master.instagram, style: const TextStyle(color: Colors.white70, fontFamily: 'SFProDisplay')),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.music_note, color: Color(0xFFFF6EC7), size: 20),
                                  const SizedBox(width: 6),
                                  Text(master.tiktok, style: const TextStyle(color: Colors.white70, fontFamily: 'SFProDisplay')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Категория Location
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFFFF6EC7)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Lepka',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              master.city is List
                                  ? (master.city as List).join(', ')
                                  : master.city,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'SFProDisplay',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Календарик (soon)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, color: Color(0xFFFF6EC7), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Booking calendar\nComing soon',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16,
                            fontFamily: 'SFProDisplay',
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Галерея работ с темным полупрозрачным фоном и каруселью
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Галерея работ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Lepka',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Карусель с фото работ
                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: master.gallery.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, i) {
                            return GestureDetector(
                              onTap: () => _openGallery(i),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  master.gallery[i],
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // --- Модальное окно просмотра фото ---
          if (_galleryIndex != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.18), // или 0.25, как на giveaway_screen
              ),
            ),
          if (_galleryIndex != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.92),
                child: Stack(
                  children: [
                    // Фото по центру
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          master.gallery[_galleryIndex!],
                          fit: BoxFit.contain,
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: MediaQuery.of(context).size.height * 0.7,
                        ),
                      ),
                    ),
                    // Кнопка закрыть (крестик)
                    Positioned(
                      top: 32,
                      right: 24,
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 36),
                        onPressed: _closeGallery,
                        splashRadius: 28,
                      ),
                    ),
                    // Стрелка влево
                    if (_galleryIndex! > 0)
                      Positioned(
                        left: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 38),
                            onPressed: _prevPhoto,
                            splashRadius: 28,
                          ),
                        ),
                      ),
                    // Стрелка вправо
                    if (_galleryIndex! < master.gallery.length - 1)
                      Positioned(
                        right: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 38),
                            onPressed: _nextPhoto,
                            splashRadius: 28,
                          ),
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
