class DuaCategory {
  const DuaCategory({required this.slug, required this.name});

  final String slug;
  final String name;

  factory DuaCategory.fromJson(Map<String, dynamic> j) =>
      DuaCategory(slug: '${j['url']}', name: '${j['name']}');
}

/// A sub-category: one heading inside a category, listing dua ids.
class DuaSection {
  const DuaSection({
    required this.id,
    required this.title,
    required this.category,
    required this.duaIds,
  });

  final int id;
  final String title;
  final String category;
  final List<int> duaIds;

  factory DuaSection.fromJson(Map<String, dynamic> j) => DuaSection(
    id: j['id'] as int,
    title: '${j['title']}',
    category: '${j['category']}',
    duaIds: [for (final i in (j['dua-ids'] as List? ?? const [])) i as int],
  );
}

/// The hadith / benefits / when / how blocks share this shape.
class DuaNote {
  const DuaNote({
    required this.title,
    this.description = '',
    this.arabic = '',
    this.items = const [],
  });

  final String title;
  final String description;
  final String arabic;
  final List<String> items;

  bool get isEmpty => description.isEmpty && arabic.isEmpty && items.isEmpty;

  static DuaNote? fromJson(Object? raw, {String text = 'description'}) {
    if (raw is! Map<String, dynamic>) return null;
    final list = raw['points'] ?? raw['steps'];
    final note = DuaNote(
      title: '${raw['title'] ?? ''}',
      description: '${raw[text] ?? ''}'.trim(),
      arabic: '${raw['arabic'] ?? ''}'.trim(),
      items: list is List ? [for (final p in list) '$p'] : const [],
    );
    return note.isEmpty ? null : note;
  }
}

class Dua {
  const Dua({
    required this.id,
    required this.title,
    required this.arabic,
    this.introduction = '',
    this.transliteration = '',
    this.translation = '',
    this.reference = '',
    this.audioUrl,
    this.hadith,
    this.benefits,
    this.whenToRecite,
    this.howToPerform,
  });

  final int id;
  final String title;
  final String introduction;
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;
  final Uri? audioUrl;
  final DuaNote? hadith;
  final DuaNote? benefits;
  final DuaNote? whenToRecite;
  final DuaNote? howToPerform;

  bool matches(String q) {
    if (q.isEmpty) return true;
    final s = q.toLowerCase();
    return title.toLowerCase().contains(s) ||
        translation.toLowerCase().contains(s) ||
        transliteration.toLowerCase().contains(s) ||
        reference.toLowerCase().contains(s) ||
        arabic.contains(q);
  }

  factory Dua.fromJson(Map<String, dynamic> j) {
    final audio = j['audio'] as String?;
    String s(String k) => '${j[k] ?? ''}'.trim();
    return Dua(
      id: j['dua_id'] as int,
      title: s('title'),
      introduction: s('introduction'),
      arabic: s('arabic'),
      transliteration: s('transliteration'),
      translation: s('translation'),
      reference: s('reference'),
      audioUrl: audio == null || audio.isEmpty
          ? null
          : Uri.parse('https://islamicapi.com').resolve(audio),
      hadith: DuaNote.fromJson(j['hadith'], text: 'translation'),
      benefits: DuaNote.fromJson(j['benefits']),
      whenToRecite: DuaNote.fromJson(j['when_to_recite']),
      howToPerform: DuaNote.fromJson(j['how_to_perform']),
    );
  }
}

class DuaLibrary {
  const DuaLibrary({
    required this.language,
    required this.categories,
    required this.sections,
    required this.duas,
  });

  final String language;
  final List<DuaCategory> categories;
  final List<DuaSection> sections;
  final Map<int, Dua> duas;

  List<DuaSection> sectionsOf(String category) =>
      sections.where((s) => s.category == category).toList();

  int duaCountOf(String category) =>
      sectionsOf(category).fold(0, (n, s) => n + s.duaIds.length);

  List<Dua> duasIn(DuaSection section) => [
    for (final id in section.duaIds)
      if (duas[id] != null) duas[id]!,
  ];

  List<Dua> search(String q) =>
      duas.values.where((d) => d.matches(q.trim())).toList();
}
