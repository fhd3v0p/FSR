import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/master_detail_screen.dart';
import '../models/master_model.dart';
import 'dart:math';

class MasterCloudScreen extends StatefulWidget {
  static const List<String> categories = [
    'Tattoo',
    'Hair',
    // 'Nails',
    'Piercing',
    'Second',
    'Jewelry',
    // 'Custom',
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
      'assets/artists/msk_tattoo_EMI',
      'assets/artists/msk_tattoo_Alena',
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
      return const _MasterCloudLoadingScreen();
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
                                  color: Color(0xFFF3E0E6), // фон для PNG
                                ),
                                child: CircleAvatar(
                                  backgroundImage: AssetImage(m.avatar),
                                  radius: avatarSize / 2.3,
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Вместо обычного Text(m.name)
                              SizedBox(
                                height: 22,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    m.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'NauryzKeds',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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

class _MasterCloudLoadingScreen extends StatefulWidget {
  const _MasterCloudLoadingScreen();
  @override
  State<_MasterCloudLoadingScreen> createState() => _MasterCloudLoadingScreenState();
}
class _MasterCloudLoadingScreenState extends State<_MasterCloudLoadingScreen> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  double _orbitAngle = 0.0;
  final List<String> avatars = [
    'assets/avatar1.png',
    'assets/avatar2.png',
    'assets/avatar3.png',
    'assets/avatar4.png',
    'assets/avatar5.png',
    'assets/avatar6.png',
  ];
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startOrbitAnimation();
  }
  void _startOrbitAnimation() {
    const double baseSpeed = 0.012;
    const Duration frameDuration = Duration(milliseconds: 16);
    void tick() {
      if (!mounted) return;
      _orbitAngle += baseSpeed;
      if (_orbitAngle > 2 * pi) {
        _orbitAngle -= 2 * pi;
      }
      setState(() {});
      Future.delayed(frameDuration, tick);
    }
    tick();
  }
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
  Offset calculateOrbitPosition(double angle, double radius) {
    return Offset(radius * cos(angle), radius * sin(angle));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: 320,
          height: 320,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(320, 320),
                    painter: DottedCirclePainter(),
                  ),
                  Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 224,
                      height: 224,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF6EC7).withOpacity(0.4),
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF6EC7).withOpacity(0.85),
                      ),
                    ),
                  ),
                  Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFB3E6).withOpacity(0.2),
                    ),
                  ),
                  for (int i = 0; i < 3; i++)
                    Transform.translate(
                      offset: calculateOrbitPosition(
                          _orbitAngle + (i * 2 * pi / 3), 160),
                      child: _framedMemoji(avatars[i]),
                    ),
                  for (int i = 0; i < 2; i++)
                    Transform.translate(
                      offset: calculateOrbitPosition(
                          -_orbitAngle + (i * pi), 112),
                      child: _framedMemoji(avatars[3 + i]),
                    ),
                  Transform.translate(
                    offset: calculateOrbitPosition(_orbitAngle, 86),
                    child: _framedMemoji(avatars[5]),
                  ),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3E0E6),
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 36,
                      backgroundImage: AssetImage('assets/center_memoji.png'),
                      backgroundColor: Color(0xFF33272D),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  Widget _framedMemoji(String path) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Color(0xFFF3E0E6),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundImage: AssetImage(path),
        backgroundColor: Colors.black,
      ),
    );
  }
}

class DottedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double dashWidth = 5;
    const double dashSpace = 5;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final radius = size.width / 2;
    final circumference = 2 * pi * radius;
    final dashCount = circumference ~/ (dashWidth + dashSpace);
    final adjustedDashAngle = 2 * pi / dashCount;
    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * adjustedDashAngle;
      final x1 = radius + radius * cos(startAngle);
      final y1 = radius + radius * sin(startAngle);
      final x2 = radius + radius * cos(startAngle + adjustedDashAngle / 2);
      final y2 = radius + radius * sin(startAngle + adjustedDashAngle / 2);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
