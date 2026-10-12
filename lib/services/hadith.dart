import 'dart:convert';
import 'dart:io' show gzip;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'quran_text.dart';

/// Hadith collections bundled for offline reading.
enum HadithBook {
  nawawi,
  qudsi,
  riyad;

  String get asset => 'assets/hadith/$name.json.gz';
}

class Hadith {
  const Hadith({
    required this.book,
    required this.number,
    required this.chapter,
    required this.arabic,
    required this.narrator,
    required this.english,
  });

  final HadithBook book;
  final int number;
  final int chapter;
  final String arabic;
  final String narrator;
  final String english;

  String get key => '${book.name}:$number';
}

class HadithChapter {
  const HadithChapter({
    required this.id,
    required this.arabic,
    required this.english,
  });

  final int id;
  final String arabic;
  final String english;

  String title(String language) =>
      language == 'ar' || english.isEmpty ? arabic : english;
}

class HadithCollection {
  const HadithCollection({
    required this.book,
    required this.titleAr,
    required this.titleEn,
    required this.authorAr,
    required this.authorEn,
    required this.chapters,
    required this.hadiths,
  });

  factory HadithCollection._fromJson(HadithBook book, Map<String, dynamic> j) {
    final title = j['title'] as Map<String, dynamic>;
    final author = j['author'] as Map<String, dynamic>;
    return HadithCollection(
      book: book,
      titleAr: title['ar'] as String,
      titleEn: title['en'] as String,
      authorAr: author['ar'] as String,
      authorEn: author['en'] as String,
      chapters: [
        for (final c in j['chapters'] as List)
          HadithChapter(
            id: c['id'] as int,
            arabic: c['ar'] as String,
            english: c['en'] as String,
          ),
      ],
      hadiths: [
        for (final h in j['hadiths'] as List)
          Hadith(
            book: book,
            number: h['n'] as int,
            chapter: h['c'] as int,
            arabic: h['ar'] as String,
            narrator: h['by'] as String,
            english: h['en'] as String,
          ),
      ],
    );
  }

  final HadithBook book;
  final String titleAr;
  final String titleEn;
  final String authorAr;
  final String authorEn;
  final List<HadithChapter> chapters;
  final List<Hadith> hadiths;

  String title(String language) => language == 'ar' ? titleAr : titleEn;
  String author(String language) => language == 'ar' ? authorAr : authorEn;

  List<Hadith> inChapter(int chapter) => [
    for (final h in hadiths)
      if (h.chapter == chapter) h,
  ];
}

/// Loads collections once and searches them in Arabic or English.
class HadithRepository {
  final _loaded = <HadithBook, Future<HadithCollection>>{};
  final _folded = <HadithBook, List<String>>{};

  Future<HadithCollection> load(HadithBook book) =>
      _loaded[book] ??= _read(book);

  Future<HadithCollection> _read(HadithBook book) async {
    final bytes = await rootBundle.load(book.asset);
    final json = await compute(_decode, bytes.buffer.asUint8List());
    return HadithCollection._fromJson(book, json);
  }

  static Map<String, dynamic> _decode(Uint8List bytes) =>
      jsonDecode(utf8.decode(gzip.decode(bytes))) as Map<String, dynamic>;

  /// Hadiths whose Arabic (ignoring diacritics) or English contains [query].
  Future<List<Hadith>> search(String query, {int limit = 100}) async {
    final q = query.trim();
    if (q.length < 2) return const [];
    final arabic = RegExp('[\u0600-\u06FF]').hasMatch(q);
    final needle = arabic ? foldArabic(q) : q.toLowerCase();
    final found = <Hadith>[];
    for (final book in HadithBook.values) {
      final c = await load(book);
      final texts = _folded[book] ??= [
        for (final h in c.hadiths) foldArabic(h.arabic),
      ];
      for (var i = 0; i < c.hadiths.length; i++) {
        final h = c.hadiths[i];
        final hit = arabic
            ? texts[i].contains(needle)
            : '${h.narrator} ${h.english}'.toLowerCase().contains(needle);
        if (hit) {
          found.add(h);
          if (found.length >= limit) return found;
        }
      }
    }
    return found;
  }
}
