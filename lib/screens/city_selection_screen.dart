import 'package:flutter/material.dart';
import 'master_cloud_screen.dart';

class CitySelectionScreen extends StatelessWidget {
  const CitySelectionScreen({super.key});

  final List<Map<String, String>> cities = const [
    {'name': 'Москва', 'emoji': '🌆'},
    {'name': 'Санкт-Петербург', 'emoji': '🌉'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Выберите город',
          style: TextStyle(
            fontFamily: 'Lepka',
            color: Colors.white,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: cities.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final city = cities[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MasterCloudScreen(city: city['name']!),
                ),
              ),
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  leading: Text(
                    city['emoji']!,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(
                    city['name']!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontFamily: 'Lepka',
                      color: Colors.white,
                    ),
                  ),
                  trailing:
                      const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
