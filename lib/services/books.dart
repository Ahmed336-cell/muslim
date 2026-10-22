/// Free Arabic Islamic books (IslamHouse — free read/download).
enum BookCategory {
  aqidah,
  tafsir,
  hadith,
  seerah,
  adhkar,
  fiqh,
}

class IslamicBook {
  const IslamicBook({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.authorAr,
    required this.authorEn,
    required this.category,
    required this.url,
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final String authorAr;
  final String authorEn;
  final BookCategory category;

  /// Free Arabic page on IslamHouse (read + PDF).
  final String url;

  String title(bool ar) => ar ? titleAr : titleEn;
  String author(bool ar) => ar ? authorAr : authorEn;
}

const islamicBooks = <IslamicBook>[
  IslamicBook(
    id: 'bukhari',
    titleAr: 'صحيح البخاري',
    titleEn: 'Sahih al-Bukhari',
    authorAr: 'محمد بن إسماعيل البخاري',
    authorEn: 'Imam al-Bukhari',
    category: BookCategory.hadith,
    url: 'https://islamhouse.com/ar/books/72992/',
  ),
  IslamicBook(
    id: 'riyad',
    titleAr: 'رياض الصالحين',
    titleEn: 'Riyad as-Salihin',
    authorAr: 'أبو زكريا النووي',
    authorEn: 'Imam an-Nawawi',
    category: BookCategory.hadith,
    url: 'https://islamhouse.com/ar/books/111275/',
  ),
  IslamicBook(
    id: 'nawawi40',
    titleAr: 'الأربعون النووية',
    titleEn: 'An-Nawawi\'s Forty Hadith',
    authorAr: 'أبو زكريا النووي',
    authorEn: 'Imam an-Nawawi',
    category: BookCategory.hadith,
    url: 'https://islamhouse.com/ar/books/5271/',
  ),
  IslamicBook(
    id: 'ibn-kathir',
    titleAr: 'تفسير ابن كثير',
    titleEn: 'Tafsir Ibn Kathir',
    authorAr: 'ابن كثير',
    authorEn: 'Ibn Kathir',
    category: BookCategory.tafsir,
    url: 'https://islamhouse.com/ar/books/2458/',
  ),
  IslamicBook(
    id: 'ibn-hisham',
    titleAr: 'السيرة النبوية لابن هشام',
    titleEn: 'Sirah of Ibn Hisham',
    authorAr: 'عبد الملك بن هشام',
    authorEn: 'Ibn Hisham',
    category: BookCategory.seerah,
    url: 'https://islamhouse.com/ar/books/57662/',
  ),
  IslamicBook(
    id: 'iman',
    titleAr: 'كتاب الإيمان',
    titleEn: 'Kitab al-Iman',
    authorAr: 'أبو عبيد القاسم بن سلام',
    authorEn: 'Abu Ubayd al-Qasim',
    category: BookCategory.aqidah,
    url: 'https://islamhouse.com/ar/books/2127/',
  ),
  IslamicBook(
    id: 'wasitiyyah',
    titleAr: 'شرح العقيدة الواسطية',
    titleEn: 'Sharh al-Aqidah al-Wasitiyyah',
    authorAr: 'صالح بن عبد الله العصيمي',
    authorEn: 'Salih al-Usaymi',
    category: BookCategory.aqidah,
    url: 'https://islamhouse.com/ar/books/2828658/',
  ),
  IslamicBook(
    id: 'hisn',
    titleAr: 'حصن المسلم',
    titleEn: 'Fortress of the Muslim',
    authorAr: 'سعيد بن علي القحطاني',
    authorEn: 'Sa\'id al-Qahtani',
    category: BookCategory.adhkar,
    url: 'https://islamhouse.com/ar/books/2522/',
  ),
];

List<IslamicBook> booksIn(BookCategory c) => [
  for (final b in islamicBooks)
    if (b.category == c) b,
];
