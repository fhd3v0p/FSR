import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/master_detail_screen.dart';
import '../models/master_model.dart';

class MasterCloudScreen extends StatefulWidget {
  static const List<String> categories = [
    'Tattoo',
    'Hair',
    // 'Nails',
    'Piercing',
    // 'Jewelry',
    // 'Custom',
    // 'Second',
  ];

  final String city;
  const MasterCloudScreen({super.key, required this.city});

  @override
  State<MasterCloudScreen> createState() => _MasterCloudScreenState();
}

class _MasterCloudScreenState extends State<MasterCloudScreen> {
  String selectedCategory = 'Tattoo';

  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _isPaused = false;

  List<MasterModel> masters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _loadMasters();
  }

  Future<void> _loadMasters() async {
    // Сканируем все папки в assets/artists/
    final artistFolders = [
      'assets/artists/Lin++',
      'assets/artists/Blodivamp',
      'assets/artists/Aspergill',
      'assets/artists/EMI',
      'assets/artists/Naidi',
      'assets/artists/MurderDoll',
      'assets/artists/Клубника',
      'assets/artists/Чучундра',
      'assets/artists/SonyaHair', // Новый артист категории Hair
      'assets/artists/moscow_tattoo',
      'assets/artists/msk_tattoo_3',
      // 'assets/artists/naidi2',
      // Добавьте новые папки здесь по мере необходимости
    ];
    final loaded = <MasterModel>[];
    for (final folder in artistFolders) {
      try {
        final m = await MasterModel.fromArtistFolder(folder);
        loaded.add(m);
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      masters = loaded;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_isPaused) return;
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        final newScroll = currentScroll + 1.0;
        if (newScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(newScroll);
        }
      }
    });
  }

  void _pauseAutoScroll() {
    setState(() {
      _isPaused = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isPaused = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final filtered = masters.where((m) =>
      (m.category.toLowerCase() == selectedCategory.toLowerCase() || selectedCategory == '') &&
      (m.city.toLowerCase() == widget.city.toLowerCase() || widget.city == '' || m.city == '')
    ).toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = (screenWidth - 24 * 2 - 40) / 3 * 0.7; // уменьшили на 30%

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/master_cloud_banner.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
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
            child: Column(
              children: [
                const SizedBox(height: 64), // Было 48, увеличил чтобы не перекрывать стрелку
                SizedBox(
                  height: 72,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: MasterCloudScreen.categories.length,
                    itemBuilder: (context, index) {
                      final cat = MasterCloudScreen.categories[index];
                      final isSelected = selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => selectedCategory = cat);
                            _pauseAutoScroll();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white),
                            ),
                            child: Center(
                              child: Text(
                                cat,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white,
                                  fontFamily: 'NauryzKeds',
                                  fontSize: 20,
                                  height: 1.2,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: GridView.builder(
                      clipBehavior: Clip.none,
                      itemCount: filtered.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, i) {
                        final m = filtered[i];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MasterDetailScreen(master: m),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  color: Colors.black.withOpacity(0.8), // фон для PNG
                                ),
                                child: CircleAvatar(
                                  backgroundImage: AssetImage(m.avatar),
                                  radius: avatarSize / 2.3,
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                m.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'NauryzKeds',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Добавьте extension для copyWith
extension MasterModelCopy on MasterModel {
  MasterModel copyWith({
    String? name,
    String? city,
    String? category,
    String? avatar,
    String? telegram,
    String? instagram,
    String? tiktok,
    List<String>? gallery,
  }) {
    return MasterModel(
      name: name ?? this.name,
      city: city ?? this.city,
      category: category ?? this.category,
      avatar: avatar ?? this.avatar,
      telegram: telegram ?? this.telegram,
      instagram: instagram ?? this.instagram,
      tiktok: tiktok ?? this.tiktok,
      gallery: gallery ?? this.gallery,
    );
  }
}
