import 'package:flutter/material.dart';
import '../models/master_model.dart';
import '../widgets/master_gallery_carousel.dart';

class MasterDetailScreen extends StatelessWidget {
  final MasterModel master;
  const MasterDetailScreen({super.key, required this.master});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          master.name,
          style: const TextStyle(
            fontFamily: 'Lepka',
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Баннер как фон
          Positioned.fill(
            child: Image.asset(
              'assets/giveaway_banner.png',
              fit: BoxFit.cover,
            ),
          ),
          // Затемнение
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          // Контент
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Карточка мастера
                  Container(
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
                                  fontFamily: 'Lepka',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.telegram, color: Colors.white70, size: 20),
                                  const SizedBox(width: 6),
                                  Text(master.telegram, style: const TextStyle(color: Colors.white70, fontFamily: 'SFProDisplay')),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 20),
                                  const SizedBox(width: 6),
                                  Text(master.instagram, style: const TextStyle(color: Colors.white70, fontFamily: 'SFProDisplay')),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.music_note, color: Colors.white70, size: 20),
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
                  const SizedBox(height: 32),
                  // Галерея работ
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
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
                        MasterGalleryCarousel(images: master.gallery),
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
