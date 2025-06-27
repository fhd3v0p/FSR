import 'package:flutter/material.dart';
import '../models/master_model.dart';
import '../widgets/master_gallery_carousel.dart';

class MasterDetailScreen extends StatelessWidget {
  final MasterModel master;
  const MasterDetailScreen({super.key, required this.master});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(master.name, style: const TextStyle(fontFamily: 'Lepka')), backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundImage: AssetImage(master.avatar), radius: 40),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(master.telegram, style: const TextStyle(color: Colors.white)),
                    Text(master.instagram, style: const TextStyle(color: Colors.white)),
                    Text(master.tiktok, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Галерея работ', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Lepka')),
            const SizedBox(height: 12),
            MasterGalleryCarousel(images: master.gallery),
          ],
        ),
      ),
    );
  }
}
