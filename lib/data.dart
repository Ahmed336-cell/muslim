class Prayer {
  const Prayer(this.name, this.arabic, this.hour, this.minute);

  /// Parses API time strings like "05:28" or "4:55 AM".
  factory Prayer.parse(String name, String arabic, String raw) {
    final m = RegExp(
      r'(\d{1,2}):(\d{2})\s*([AaPp][Mm])?',
    ).firstMatch(raw.trim());
    if (m == null) throw FormatException('Bad time for $name: $raw');
    var h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    final ampm = m.group(3)?.toLowerCase();
    if (ampm == 'pm' && h < 12) h += 12;
    if (ampm == 'am' && h == 12) h = 0;
    return Prayer(name, arabic, h, min);
  }

  /// API key: Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha, Sahur, Iftar.
  final String name;
  final String arabic;
  final int hour;
  final int minute;

  bool get isObligatory => name != 'Sunrise';

  DateTime on(DateTime day) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  String get time {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h:${minute.toString().padLeft(2, '0')}';
  }

  String get period => hour < 12 ? 'am' : 'pm';
}

/// The upcoming prayer and the one before it, with absolute times.
/// After Isha, the next is tomorrow's Fajr.
({Prayer next, DateTime at, DateTime since}) upcoming(
  List<Prayer> prayers,
  DateTime now,
) {
  for (var i = 0; i < prayers.length; i++) {
    final at = prayers[i].on(now);
    if (at.isAfter(now)) {
      final since = i == 0
          ? prayers.last.on(now.subtract(const Duration(days: 1)))
          : prayers[i - 1].on(now);
      return (next: prayers[i], at: at, since: since);
    }
  }
  return (
    next: prayers.first,
    at: prayers.first.on(now.add(const Duration(days: 1))),
    since: prayers.last.on(now),
  );
}

/// Midnight and start of the last third for tonight (Maghrib → next Fajr).
({DateTime midnight, DateTime lastThird, Duration night})? nightMarks(
  List<Prayer> today,
  List<Prayer>? tomorrow,
  DateTime now,
) {
  final maghrib = today.where((p) => p.name == 'Maghrib').firstOrNull;
  final fajr = tomorrow?.where((p) => p.name == 'Fajr').firstOrNull ??
      today.where((p) => p.name == 'Fajr').firstOrNull;
  if (maghrib == null || fajr == null) return null;
  final maghribAt = maghrib.on(now);
  var fajrAt = fajr.on(now);
  if (!fajrAt.isAfter(maghribAt)) {
    fajrAt = fajr.on(now.add(const Duration(days: 1)));
  }
  final night = fajrAt.difference(maghribAt);
  if (night.inMinutes < 60) return null;
  return (
    midnight: maghribAt.add(night ~/ 2),
    lastThird: maghribAt.add(
      Duration(seconds: (night.inSeconds * 2 / 3).round()),
    ),
    night: night,
  );
}

class Surah {
  const Surah(
    this.number,
    this.name,
    this.arabic,
    this.meaning,
    this.ayahs,
    this.meccan,
  );

  final int number;
  final String name;
  final String arabic;
  final String meaning;
  final int ayahs;
  final bool meccan;
}

const surahs = [
  Surah(1, 'Al-Fatihah', 'الفاتحة', 'The Opening', 7, true),
  Surah(2, 'Al-Baqarah', 'البقرة', 'The Cow', 286, false),
  Surah(3, 'Ali \'Imran', 'آل عمران', 'Family of Imran', 200, false),
  Surah(4, 'An-Nisa', 'النساء', 'The Women', 176, false),
  Surah(5, 'Al-Ma\'idah', 'المائدة', 'The Table Spread', 120, false),
  Surah(6, 'Al-An\'am', 'الأنعام', 'The Cattle', 165, true),
  Surah(7, 'Al-A\'raf', 'الأعراف', 'The Heights', 206, true),
  Surah(8, 'Al-Anfal', 'الأنفال', 'The Spoils of War', 75, false),
  Surah(9, 'At-Tawbah', 'التوبة', 'The Repentance', 129, false),
  Surah(10, 'Yunus', 'يونس', 'Jonah', 109, true),
  Surah(11, 'Hud', 'هود', 'Hud', 123, true),
  Surah(12, 'Yusuf', 'يوسف', 'Joseph', 111, true),
  Surah(13, 'Ar-Ra\'d', 'الرعد', 'The Thunder', 43, false),
  Surah(14, 'Ibrahim', 'إبراهيم', 'Abraham', 52, true),
  Surah(15, 'Al-Hijr', 'الحجر', 'The Rocky Tract', 99, true),
  Surah(16, 'An-Nahl', 'النحل', 'The Bee', 128, true),
  Surah(17, 'Al-Isra', 'الإسراء', 'The Night Journey', 111, true),
  Surah(18, 'Al-Kahf', 'الكهف', 'The Cave', 110, true),
  Surah(19, 'Maryam', 'مريم', 'Mary', 98, true),
  Surah(20, 'Taha', 'طه', 'Ta-Ha', 135, true),
  Surah(21, 'Al-Anbiya', 'الأنبياء', 'The Prophets', 112, true),
  Surah(22, 'Al-Hajj', 'الحج', 'The Pilgrimage', 78, false),
  Surah(23, 'Al-Mu\'minun', 'المؤمنون', 'The Believers', 118, true),
  Surah(24, 'An-Nur', 'النور', 'The Light', 64, false),
  Surah(25, 'Al-Furqan', 'الفرقان', 'The Criterion', 77, true),
  Surah(26, 'Ash-Shu\'ara', 'الشعراء', 'The Poets', 227, true),
  Surah(27, 'An-Naml', 'النمل', 'The Ant', 93, true),
  Surah(28, 'Al-Qasas', 'القصص', 'The Stories', 88, true),
  Surah(29, 'Al-\'Ankabut', 'العنكبوت', 'The Spider', 69, true),
  Surah(30, 'Ar-Rum', 'الروم', 'The Romans', 60, true),
  Surah(31, 'Luqman', 'لقمان', 'Luqman', 34, true),
  Surah(32, 'As-Sajdah', 'السجدة', 'The Prostration', 30, true),
  Surah(33, 'Al-Ahzab', 'الأحزاب', 'The Combined Forces', 73, false),
  Surah(34, 'Saba', 'سبأ', 'Sheba', 54, true),
  Surah(35, 'Fatir', 'فاطر', 'The Originator', 45, true),
  Surah(36, 'Ya-Sin', 'يس', 'Ya Sin', 83, true),
  Surah(37, 'As-Saffat', 'الصافات', 'Those Who Set the Ranks', 182, true),
  Surah(38, 'Sad', 'ص', 'The Letter Sad', 88, true),
  Surah(39, 'Az-Zumar', 'الزمر', 'The Troops', 75, true),
  Surah(40, 'Ghafir', 'غافر', 'The Forgiver', 85, true),
  Surah(41, 'Fussilat', 'فصلت', 'Explained in Detail', 54, true),
  Surah(42, 'Ash-Shura', 'الشورى', 'The Consultation', 53, true),
  Surah(43, 'Az-Zukhruf', 'الزخرف', 'The Ornaments of Gold', 89, true),
  Surah(44, 'Ad-Dukhan', 'الدخان', 'The Smoke', 59, true),
  Surah(45, 'Al-Jathiyah', 'الجاثية', 'The Crouching', 37, true),
  Surah(46, 'Al-Ahqaf', 'الأحقاف', 'The Wind-Curved Sandhills', 35, true),
  Surah(47, 'Muhammad', 'محمد', 'Muhammad', 38, false),
  Surah(48, 'Al-Fath', 'الفتح', 'The Victory', 29, false),
  Surah(49, 'Al-Hujurat', 'الحجرات', 'The Rooms', 18, false),
  Surah(50, 'Qaf', 'ق', 'The Letter Qaf', 45, true),
  Surah(51, 'Adh-Dhariyat', 'الذاريات', 'The Winnowing Winds', 60, true),
  Surah(52, 'At-Tur', 'الطور', 'The Mount', 49, true),
  Surah(53, 'An-Najm', 'النجم', 'The Star', 62, true),
  Surah(54, 'Al-Qamar', 'القمر', 'The Moon', 55, true),
  Surah(55, 'Ar-Rahman', 'الرحمن', 'The Most Merciful', 78, false),
  Surah(56, 'Al-Waqi\'ah', 'الواقعة', 'The Inevitable', 96, true),
  Surah(57, 'Al-Hadid', 'الحديد', 'The Iron', 29, false),
  Surah(58, 'Al-Mujadilah', 'المجادلة', 'The Pleading Woman', 22, false),
  Surah(59, 'Al-Hashr', 'الحشر', 'The Exile', 24, false),
  Surah(60, 'Al-Mumtahanah', 'الممتحنة', 'She Who Is Examined', 13, false),
  Surah(61, 'As-Saff', 'الصف', 'The Ranks', 14, false),
  Surah(62, 'Al-Jumu\'ah', 'الجمعة', 'Friday', 11, false),
  Surah(63, 'Al-Munafiqun', 'المنافقون', 'The Hypocrites', 11, false),
  Surah(64, 'At-Taghabun', 'التغابن', 'Mutual Loss and Gain', 18, false),
  Surah(65, 'At-Talaq', 'الطلاق', 'Divorce', 12, false),
  Surah(66, 'At-Tahrim', 'التحريم', 'The Prohibition', 12, false),
  Surah(67, 'Al-Mulk', 'الملك', 'The Sovereignty', 30, true),
  Surah(68, 'Al-Qalam', 'القلم', 'The Pen', 52, true),
  Surah(69, 'Al-Haqqah', 'الحاقة', 'The Reality', 52, true),
  Surah(70, 'Al-Ma\'arij', 'المعارج', 'The Ascending Stairways', 44, true),
  Surah(71, 'Nuh', 'نوح', 'Noah', 28, true),
  Surah(72, 'Al-Jinn', 'الجن', 'The Jinn', 28, true),
  Surah(73, 'Al-Muzzammil', 'المزمل', 'The Enshrouded One', 20, true),
  Surah(74, 'Al-Muddaththir', 'المدثر', 'The Cloaked One', 56, true),
  Surah(75, 'Al-Qiyamah', 'القيامة', 'The Resurrection', 40, true),
  Surah(76, 'Al-Insan', 'الإنسان', 'Man', 31, false),
  Surah(77, 'Al-Mursalat', 'المرسلات', 'The Emissaries', 50, true),
  Surah(78, 'An-Naba', 'النبأ', 'The Tidings', 40, true),
  Surah(79, 'An-Nazi\'at', 'النازعات', 'Those Who Pull Out', 46, true),
  Surah(80, '\'Abasa', 'عبس', 'He Frowned', 42, true),
  Surah(81, 'At-Takwir', 'التكوير', 'The Overthrowing', 29, true),
  Surah(82, 'Al-Infitar', 'الانفطار', 'The Cleaving', 19, true),
  Surah(83, 'Al-Mutaffifin', 'المطففين', 'The Defrauding', 36, true),
  Surah(84, 'Al-Inshiqaq', 'الانشقاق', 'The Splitting Open', 25, true),
  Surah(85, 'Al-Buruj', 'البروج', 'The Constellations', 22, true),
  Surah(86, 'At-Tariq', 'الطارق', 'The Night Visitor', 17, true),
  Surah(87, 'Al-A\'la', 'الأعلى', 'The Most High', 19, true),
  Surah(88, 'Al-Ghashiyah', 'الغاشية', 'The Overwhelming', 26, true),
  Surah(89, 'Al-Fajr', 'الفجر', 'The Dawn', 30, true),
  Surah(90, 'Al-Balad', 'البلد', 'The City', 20, true),
  Surah(91, 'Ash-Shams', 'الشمس', 'The Sun', 15, true),
  Surah(92, 'Al-Layl', 'الليل', 'The Night', 21, true),
  Surah(93, 'Ad-Duha', 'الضحى', 'The Morning Hours', 11, true),
  Surah(94, 'Ash-Sharh', 'الشرح', 'The Relief', 8, true),
  Surah(95, 'At-Tin', 'التين', 'The Fig', 8, true),
  Surah(96, 'Al-\'Alaq', 'العلق', 'The Clinging Clot', 19, true),
  Surah(97, 'Al-Qadr', 'القدر', 'The Night of Decree', 5, true),
  Surah(98, 'Al-Bayyinah', 'البينة', 'The Clear Proof', 8, false),
  Surah(99, 'Az-Zalzalah', 'الزلزلة', 'The Earthquake', 8, false),
  Surah(100, 'Al-\'Adiyat', 'العاديات', 'The Chargers', 11, true),
  Surah(101, 'Al-Qari\'ah', 'القارعة', 'The Striking Calamity', 11, true),
  Surah(102, 'At-Takathur', 'التكاثر', 'Competition in Increase', 8, true),
  Surah(103, 'Al-\'Asr', 'العصر', 'The Declining Day', 3, true),
  Surah(104, 'Al-Humazah', 'الهمزة', 'The Slanderer', 9, true),
  Surah(105, 'Al-Fil', 'الفيل', 'The Elephant', 5, true),
  Surah(106, 'Quraysh', 'قريش', 'Quraysh', 4, true),
  Surah(107, 'Al-Ma\'un', 'الماعون', 'Small Kindnesses', 7, true),
  Surah(108, 'Al-Kawthar', 'الكوثر', 'Abundance', 3, true),
  Surah(109, 'Al-Kafirun', 'الكافرون', 'The Disbelievers', 6, true),
  Surah(110, 'An-Nasr', 'النصر', 'The Help', 3, false),
  Surah(111, 'Al-Masad', 'المسد', 'The Palm Fibre', 5, true),
  Surah(112, 'Al-Ikhlas', 'الإخلاص', 'Sincerity', 4, true),
  Surah(113, 'Al-Falaq', 'الفلق', 'The Daybreak', 5, true),
  Surah(114, 'An-Nas', 'الناس', 'Mankind', 6, true),
];

class Dhikr {
  const Dhikr(this.arabic, this.translit, this.meaning, this.target);

  final String arabic;
  final String translit;

  /// English meaning; Arabic mode shows only [arabic].
  final String meaning;
  final int target;
}

/// After every obligatory prayer (Sahih Muslim 597).
const adhkar = [
  Dhikr('سُبْحَانَ ٱللَّٰهِ', 'Subhan Allah', 'Glory be to Allah', 33),
  Dhikr('ٱلْحَمْدُ لِلَّٰهِ', 'Alhamdulillah', 'All praise is for Allah', 33),
  Dhikr('ٱللَّٰهُ أَكْبَرُ', 'Allahu Akbar', 'Allah is the Greatest', 33),
  Dhikr(
    'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ ٱلْمُلْكُ '
        'وَلَهُ ٱلْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    'La ilaha illallahu wahdahu la sharika lah, lahul-mulku wa lahul-hamd, '
        'wa huwa \'ala kulli shay\'in qadir',
    'None has the right to be worshipped but Allah alone, without partner. '
        'His is the dominion and His is the praise, and He is able to do all '
        'things.',
    1,
  ),
];
