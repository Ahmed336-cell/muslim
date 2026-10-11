class DivineName {
  const DivineName({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.meaning,
    this.audioUrl,
  });

  final int number;
  final String arabic;
  final String transliteration;
  final String translation;
  final String meaning;
  final Uri? audioUrl;

  factory DivineName.fromJson(Map<String, dynamic> j) {
    final audio = j['audio'] as String?;
    return DivineName(
      number: j['number'] as int,
      arabic: '${j['name'] ?? ''}',
      transliteration: '${j['transliteration'] ?? ''}',
      translation: '${j['translation'] ?? ''}',
      meaning: '${j['meaning'] ?? ''}',
      audioUrl: audio == null || audio.isEmpty
          ? null
          : Uri.parse('https://islamicapi.com').resolve(audio),
    );
  }

  bool matches(String q) {
    if (q.isEmpty) return true;
    final s = q.toLowerCase();
    return '$number' == s ||
        transliteration.toLowerCase().contains(s) ||
        translation.toLowerCase().contains(s) ||
        arabic.contains(q);
  }
}

class NamesBook {
  const NamesBook({
    required this.language,
    required this.names,
    required this.title,
    required this.hadith,
  });

  final String language;
  final List<DivineName> names;
  final String title;
  final String hadith;

  /// Same name for everyone on a given day; cycles through all 99.
  DivineName forDay(DateTime d) {
    final dayOfYear = DateTime.utc(
      d.year,
      d.month,
      d.day,
    ).difference(DateTime.utc(d.year)).inDays;
    return names[(d.year * 366 + dayOfYear) % names.length];
  }

  factory NamesBook.fromJson(Map<String, dynamic> data) {
    final names =
        (data['names'] as List)
            .map((e) => DivineName.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.number.compareTo(b.number));
    return NamesBook(
      language: '${data['language_code'] ?? 'en'}',
      names: names,
      title: '${data['title'] ?? 'The Beautiful Names of Allah'}',
      hadith: '${data['hadith'] ?? ''}',
    );
  }
}
