class MasterModel {
  final String name;
  final String city;
  final String category;
  final String avatar;
  final String telegram;
  final String instagram;
  final String tiktok;
  final List<String> gallery;

  MasterModel({
    required this.name,
    required this.city,
    required this.category,
    required this.avatar,
    required this.telegram,
    required this.instagram,
    required this.tiktok,
    required this.gallery,
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
}
