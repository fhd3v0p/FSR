import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/master_detail_screen.dart';
import '../models/master_model.dart';

class MasterCloudScreen extends StatefulWidget {
  final String city;
  const MasterCloudScreen({super.key, required this.city});

  @override
  State<MasterCloudScreen> createState() => _MasterCloudScreenState();
}

class _MasterCloudScreenState extends State<MasterCloudScreen> {
  String selectedCategory = 'Тату';
  final categories = ['Тату', 'Маник', 'Хэир', 'Ювелирка', 'Кастом'];

  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
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
    final masters = MasterModel.sampleData
        .where((m) => m.city == widget.city && m.category == selectedCategory)
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Мастера в ${widget.city}',
          style: const TextStyle(fontFamily: 'Lepka'),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 64,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
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
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontFamily: 'Lepka',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: masters.map((m) {
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MasterDetailScreen(master: m),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      backgroundImage: AssetImage(m.avatar),
                      radius: 40,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
