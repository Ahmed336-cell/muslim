enum RuqyahProgram {
  brief('brief-ruqya', 'Brief', 'total_brief_ruqyah'),
  medium('a-medium-ruqya', 'Medium', 'total_med_ruqyah'),
  long('a-long-ruqya', 'Long', 'total_long_ruqyah');

  const RuqyahProgram(this.slug, this.label, this._audioFile);

  final String slug;
  final String label;
  final String _audioFile;

  /// The whole program recited in one file.
  Uri get audioUrl =>
      Uri.parse('https://islamicapi.com/audio/ruqyah/$_audioFile.mp3');
}

enum RuqyahSource {
  quran('from-quran', 'Quran'),
  sunnah('from-sunnah', 'Sunnah');

  const RuqyahSource(this.slug, this.label);

  final String slug;
  final String label;
}

class RuqyahEntry {
  const RuqyahEntry({
    required this.id,
    required this.title,
    required this.arabic,
    this.introduction = '',
    this.transliteration = '',
    this.translation = '',
    this.reference = '',
  });

  final int id;
  final String title;
  final String introduction;
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;

  factory RuqyahEntry.fromJson(Map<String, dynamic> j) {
    String s(String k) => '${j[k] ?? ''}'.trim();
    return RuqyahEntry(
      id: int.parse('${j['id']}'),
      title: s('title'),
      introduction: s('introduction'),
      arabic: s('arabic'),
      transliteration: s('transliteration'),
      translation: s('translation'),
      reference: s('reference'),
    );
  }
}

class RuqyahTopic {
  const RuqyahTopic({
    required this.slug,
    required this.title,
    required this.count,
  });

  final String slug;
  final String title;
  final int count;

  /// One topic-category can hold several sub-categories; each is a topic.
  static List<RuqyahTopic> listFromJson(List<dynamic> data) => [
    for (final cat in data.cast<Map<String, dynamic>>())
      for (final sub
          in (cat['subcategories'] as List? ?? const [])
              .cast<Map<String, dynamic>>())
        RuqyahTopic(
          slug: '${sub['subcategory-slug']}',
          title: '${sub['subcategory'] ?? cat['title']}',
          count: (sub['ruqyah'] as List? ?? const []).length,
        ),
  ];
}

enum BlockType { text, arabic, translation, transliteration, header }

class ArticleBlock {
  const ArticleBlock(this.type, this.content);

  final BlockType type;
  final String content;
}

class RuqyahArticle {
  const RuqyahArticle({
    required this.id,
    required this.title,
    required this.sectionTitle,
    required this.blocks,
  });

  final int id;
  final String title;
  final String sectionTitle;
  final List<ArticleBlock> blocks;

  factory RuqyahArticle.fromJson(Map<String, dynamic> j) => RuqyahArticle(
    id: int.parse('${j['id'] ?? j['sub_id']}'),
    title: '${j['title'] ?? ''}'.trim(),
    sectionTitle: '${j['section_title'] ?? ''}'.trim(),
    blocks: [
      for (final b
          in (j['content'] as List? ?? const []).cast<Map<String, dynamic>>())
        if ('${b['content'] ?? ''}'.trim().isNotEmpty)
          ArticleBlock(
            BlockType.values.asNameMap()['${b['type']}'] ?? BlockType.text,
            '${b['content']}'.trim(),
          ),
    ],
  );
}
