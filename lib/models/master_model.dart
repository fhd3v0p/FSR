import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class MasterModel {
  final String name;
  final String city;
  final String category;
  final String avatar;
  final String telegram;
  final String instagram;
  final String tiktok;
  final List<String> gallery;
  // Новые поля для ссылок и html
  final String? pinterest;
  final String? pinterestUrl;
  final String? telegramUrl;
  final String? tiktokUrl;
  final String? bookingUrl;
  final String? bio;
  final String? locationHtml;
  final String? galleryHtml;

  MasterModel({
    required this.name,
    required this.city,
    required this.category,
    required this.avatar,
    required this.telegram,
    required this.instagram,
    required this.tiktok,
    required this.gallery,
    this.pinterest,
    this.pinterestUrl,
    this.telegramUrl,
    this.tiktokUrl,
    this.bookingUrl,
    this.bio,
    this.locationHtml,
    this.galleryHtml,
  });

  static List<MasterModel> sampleData = [
    MasterModel(
      name: 'Аня',
      city: 'Москва',
      category: 'Тату',
      avatar: 'assets/m1.png',
      telegram: '@anya_tg',
      instagram: '@anya_ig',
      tiktok: '@anya_tt',
      gallery: ['assets/work1.png', 'assets/work2.png'],
      pinterest: '@anya_pin',
      pinterestUrl: 'https://pinterest.com/anya_pin',
      telegramUrl: 'https://t.me/anya_tg',
      tiktokUrl: 'https://tiktok.com/@anya_tt',
      bookingUrl: 'https://t.me/emi3mo',
      bio: '<b>Аня</b> — топовый мастер по тату в Москве. Работает с 2015 года.<br>Победитель чемпионата 2023.',
      locationHtml: '<b>Москва, м. Арбатская</b><br>ул. Новый Арбат, 21',
      galleryHtml: '',
    ),
    MasterModel(
      name: 'Игорь',
      city: 'Москва',
      category: 'Маник',
      avatar: 'assets/m2.png',
      telegram: '@igor_tg',
      instagram: '@igor_ig',
      tiktok: '@igor_tt',
      gallery: ['assets/work1.png', 'assets/work2.png'],
    ),
    MasterModel(
      name: 'Оля',
      city: 'Москва',
      category: 'Хэир',
      avatar: 'assets/m3.png',
      telegram: '@olya_tg',
      instagram: '@olya_ig',
      tiktok: '@olya_tt',
      gallery: ['assets/work1.png', 'assets/work2.png'],
    ),
    MasterModel(
      name: 'Макс',
      city: 'Москва',
      category: 'Ювелирка',
      avatar: 'assets/m4.png',
      telegram: '@max_tg',
      instagram: '@max_ig',
      tiktok: '@max_tt',
      gallery: ['assets/work1.png', 'assets/work2.png'],
    ),
    MasterModel(
      name: 'Света',
      city: 'Москва',
      category: 'Кастом',
      avatar: 'assets/m5.png',
      telegram: '@sveta_tg',
      instagram: '@sveta_ig',
      tiktok: '@sveta_tt',
      gallery: ['assets/work1.png', 'assets/work2.png'],
    ),
    MasterModel(
      name: 'Дима',
      city: 'Москва',
      category: 'Тату',
      avatar: 'assets/m6.png',
      telegram: '@dima_tg',
      instagram: '@dima_ig',
      tiktok: '@dima_tt',
      gallery: ['assets/work1.png', 'assets/work2.png'],
    ),
    MasterModel(
      name: 'Лена',
      city: 'Москва',
      category: 'Маник',
      avatar: 'assets/avatar1.png',
      telegram: '@lena_tg',
      instagram: '@lena_ig',
      tiktok: '@lena_tt',
      gallery: ['assets/work1.png', 'assets/work2.png'],
    ),
    MasterModel(
      name: 'Женя',
      city: 'Москва',
      category: 'Хэир',
      avatar: 'assets/avatar2.png',
      telegram: '@zhenya_tg',
      instagram: '@zhenya_ig',
      tiktok: '@zhenya_tt',
      gallery: ['assets/work1.png', 'assets/work2.png'],
    ),
    MasterModel(
      name: 'Катя',
      city: 'Москва',
      category: 'Ювелирка',
      avatar: 'assets/avatar3.png',
      telegram: '@katya_tg',
      instagram: '@katya_ig',
      tiktok: '@katya_tt',
      gallery: ['assets/work1.png', 'assets/work2.png'],
    ),
    MasterModel(
      name: 'Кирилл',
      city: 'Москва',
      category: 'Кастом',
      avatar: 'assets/avatar4.png',
      telegram: '@kirill_tg',
      instagram: '@kirill_ig',
      tiktok: '@kirill_tt',
      gallery: ['assets/work1.png', 'assets/work2.png'],
    ),
  ];

  static Future<MasterModel> fromArtistFolder(String folderPath) async {
    String bio = '';
    Map<String, dynamic> links = {};
    final gallery = <String>[];
    try {
      bio = await rootBundle.loadString('$folderPath/bio.txt');
    } catch (e) {
      print('Ошибка чтения bio.txt для $folderPath: $e');
    }
    try {
      final linksJson = await rootBundle.loadString('$folderPath/links.json');
      links = jsonDecode(linksJson);
    } catch (e) {
      print('Ошибка чтения или парсинга links.json для $folderPath: $e');
    }
    for (var i = 1; i <= 10; i++) {
      final path = '$folderPath/gallery$i.jpg';
      try {
        await rootBundle.load(path);
        gallery.add(path);
      } catch (e) {
        print('Галерея: не найден $path для $folderPath: $e');
        break;
      }
    }
    return MasterModel(
      name: links['name'] ?? 'Artist',
      city: links['city'] ?? '',
      category: links['category'] ?? '',
      avatar: '$folderPath/avatar.png',
      telegram: links['telegram'] ?? '',
      instagram: links['instagram'] ?? '',
      tiktok: links['tiktok'] ?? '',
      gallery: gallery,
      pinterest: links['pinterest'],
      pinterestUrl: links['pinterestUrl'],
      telegramUrl: links['telegramUrl'],
      tiktokUrl: links['tiktokUrl'],
      bookingUrl: links['bookingUrl'],
      bio: bio, // bio только из файла
      locationHtml: links['locationHtml'],
      galleryHtml: links['galleryHtml'],
    );
  }

  static Future<List<MasterModel>> loadAllFromFolders(List<String> artistFolders) async {
    final loaded = <MasterModel>[];
    for (final folder in artistFolders) {
      try {
        final m = await MasterModel.fromArtistFolder(folder);
        loaded.add(m);
      } catch (_) {}
    }
    return loaded;
  }
}
