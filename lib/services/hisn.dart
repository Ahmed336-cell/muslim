import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

/// Morning adhkar run from Fajr until midday; evening ones after that.
enum AzkarSession {
  morning,
  evening;

  static AzkarSession forHour(int hour) =>
      hour >= 3 && hour < 14 ? morning : evening;
}

class Dhikr extends Equatable {
  const Dhikr({
    required this.id,
    required this.arabic,
    this.translation = '',
    this.translit = '',
    this.repeat = 1,
  });

  factory Dhikr.fromJson(Map<String, dynamic> j) => Dhikr(
    id: j['id'] as int,
    arabic: j['ar'] as String,
    translation: j['en'] as String? ?? '',
    translit: j['tr'] as String? ?? '',
    repeat: j['n'] as int? ?? 1,
  );

  final int id;
  final String arabic;
  final String translation;
  final String translit;
  final int repeat;

  Uri get audio => Uri.https('www.hisnmuslim.com', '/audio/ar/$id.mp3');

  @override
  List<Object?> get props => [id, arabic, repeat];
}

class HisnChapter extends Equatable {
  const HisnChapter({
    required this.id,
    required this.arabic,
    required this.english,
    required this.items,
  });

  factory HisnChapter.fromJson(Map<String, dynamic> j) => HisnChapter(
    id: j['id'] as int,
    arabic: j['ar'] as String,
    english: j['en'] as String? ?? '',
    items: [
      for (final i in j['items'] as List)
        Dhikr.fromJson(i as Map<String, dynamic>),
    ],
  );

  final int id;
  final String arabic;
  final String english;
  final List<Dhikr> items;

  String title(String language) =>
      language == 'ar' || english.isEmpty ? arabic : english;

  @override
  List<Object?> get props => [id];
}

class HisnBook {
  const HisnBook({
    required this.chapters,
    required this.morning,
    required this.evening,
  });

  factory HisnBook.fromJson(Map<String, dynamic> j) {
    List<Dhikr> list(String key) => [
      for (final i in j[key] as List) Dhikr.fromJson(i as Map<String, dynamic>),
    ];
    return HisnBook(
      chapters: [
        for (final c in j['chapters'] as List)
          HisnChapter.fromJson(c as Map<String, dynamic>),
      ],
      morning: list('morning'),
      evening: list('evening'),
    );
  }

  final List<HisnChapter> chapters;
  final List<Dhikr> morning;
  final List<Dhikr> evening;

  List<Dhikr> session(AzkarSession s) => switch (s) {
    AzkarSession.morning => morning,
    AzkarSession.evening => evening,
  };

  /// Chapters whose title (either language) or text matches [query];
  /// Arabic is compared without diacritics.
  List<HisnChapter> search(String query) {
    final q = normalizeArabic(query.trim().toLowerCase());
    if (q.isEmpty) return chapters;
    bool hit(String s) => normalizeArabic(s.toLowerCase()).contains(q);
    final byTitle = [
      for (final c in chapters)
        if (hit(c.arabic) || hit(c.english)) c,
    ];
    return [
      ...byTitle,
      for (final c in chapters)
        if (!byTitle.contains(c) && c.items.any((d) => hit(d.arabic))) c,
    ];
  }
}

final _marks = RegExp('[\u064B-\u065F\u0670\u0640\u06D6-\u06ED]');

/// Strips harakat and tatweel and unifies alef / ya / ta marbuta forms.
String normalizeArabic(String s) => s
    .replaceAll(_marks, '')
    .replaceAll(RegExp('[أإآٱ]'), 'ا')
    .replaceAll('ى', 'ي')
    .replaceAll('ة', 'ه');

/// Hisn al-Muslim, bundled so it works offline.
class HisnRepository {
  HisnRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const asset = 'assets/hisn/hisn.json';

  final AssetBundle _bundle;
  Future<HisnBook>? _book;

  Future<HisnBook> load() => _book ??= _read().catchError((Object e) {
    _book = null;
    throw e;
  });

  Future<HisnBook> _read() async {
    final raw = await _bundle.loadString(asset);
    return HisnBook.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
