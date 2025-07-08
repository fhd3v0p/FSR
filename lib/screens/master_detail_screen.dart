import 'package:flutter/material.dart';
import '../models/master_model.dart';
import 'package:url_launcher/url_launcher.dart';

class MasterDetailScreen extends StatefulWidget {
  final MasterModel master;
  const MasterDetailScreen({super.key, required this.master});

  @override
  State<MasterDetailScreen> createState() => _MasterDetailScreenState();
}

class _MasterDetailScreenState extends State<MasterDetailScreen> {
  int? _galleryIndex;

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

  // Для аватара с обводкой
  Widget buildAvatar(String avatarPath, double radius) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
        backgroundImage: AssetImage(avatarPath),
        radius: radius,
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final master = widget.master;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // --- ФОН: master_detail_back_banner ---
          Positioned.fill(
            child: Image.asset(
              'assets/master_detail_back_banner.png',
              fit: BoxFit.cover,
            ),
          ),
          // --- ЗАТЕМНЕНИЕ 10% ПОД ЛОГО, НО НАД ФОНОМ ---
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.10),
            ),
          ),
          // --- ЛОГО БАННЕР: master_detail_logo_banner ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/master_detail_logo_banner.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          // --- КОНТЕНТ (dark boxes) ---
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  // --- ВЕРХНЯЯ ТЁМНАЯ РАМКА с соцсетями и кнопкой ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.zero,
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: Row(
                            children: [
                              buildAvatar(master.avatar, 38),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Text(
                                  master.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NauryzKeds',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: _SocialButton(
                            icon: Icons.telegram,
                            label: master.telegram ?? '',
                            url: master.telegramUrl ?? '',
                            color: Color(0xFF229ED9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: _SocialButton(
                            icon: Icons.music_note,
                            label: master.tiktok ?? '',
                            url: master.tiktokUrl ?? '',
                            color: Color(0xFF010101),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: _SocialButton(
                            icon: Icons.push_pin,
                            label: master.pinterest ?? '',
                            url: master.pinterestUrl ?? '',
                            color: Color(0xFFE60023),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Кнопка записаться — стиль как активная кнопка (градиент)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 0),
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () async {
                              const url = 'https://t.me/FSR_Adminka';
                              await launchUrl(Uri.parse(url));
                            },
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.zero,
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Color(0xFFFFE3F3),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: Color(0xFFFF6EC7),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Записаться',
                                  style: TextStyle(
                                    color: Color(0xFFFF6EC7),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'SFProDisplay',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // BIO блок
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.zero,
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'BIO',
                          style: TextStyle(
                            color: Color(0xFFFF6EC7),
                            fontFamily: 'NauryzKeds',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Занимаюсь стрижками и окрашиваниями в альтернативном стиле, вдохновлёнными субкультурами, аниме, мультиками и всем остальным, т.к. работаю по мудбордам',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'OpenSans',
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // --- ЛОКАЦИЯ ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.zero,
                      border: Border.all(color: Colors.white24, width: 1), // добавили белую/серую рамку
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
                                  fontFamily: 'NauryzKeds',
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
                                  fontFamily: 'NauryzKeds',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // --- КАЛЕНДАРЬ ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.zero,
                      border: Border.all(color: Colors.white24, width: 1), // добавили белую/серую рамку
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Color(0xFFFF6EC7), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Booking calendar\nComing soon',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 16,
                              fontFamily: 'NauryzKeds',
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // --- ГАЛЕРЕЯ ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.zero,
                      // border убран
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Галерея работ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'NauryzKeds',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
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
                                  borderRadius: BorderRadius.circular(0),
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
          ),
          // --- Модальное окно просмотра фото ---
          if (_galleryIndex != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.18),
              ),
            ),
          if (_galleryIndex != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.92),
                child: Stack(
                  children: [
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
                    Positioned(
                      top: 32,
                      right: 24,
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 36),
                        onPressed: _closeGallery,
                        splashRadius: 28,
                      ),
                    ),
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
          // Кнопка назад — теперь в самом конце, поверх всего
          Positioned(
            top: 51,
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).maybePop(),
              splashRadius: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final Color color;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (url.isNotEmpty) {
          await launchUrl(Uri.parse(url));
        }
      },
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'NauryzKeds',
            ),
          ),
        ],
      ),
    );
  }
}
