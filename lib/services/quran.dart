import 'dart:convert';

import 'package:flutter/foundation.dart' show compute;
import 'package:http/http.dart' as http;

import 'islamic_api.dart' show ApiException;
import 'quran_text.dart';

/// Page look: paper, ink, and ornaments. Separate from the script [Mushaf].
enum MushafStyle { classic, madinah, night, sepia, ottoman, emerald, royal, rose, ink }

/// Script the mushaf is printed in. Texts come from api.alquran.cloud.

enum Mushaf {
  uthmani('quran-uthmani', 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ'),
  tajweed(
    'quran-tajweed',
    'بِسْمِ [h:1[ٱ]للَّهِ [h:2[ٱ][l[ل]رَّحْمَ[n[ـٰ]نِ [h:3[ٱ][l[ل]رَّح[p[ِي]مِ',
  ),
  simple('quran-simple', 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'),
  plain('quran-simple-clean', 'بسم الله الرحمن الرحيم');

  const Mushaf(this.edition, this.bismillah);

  final String edition;
  final String bismillah;
}

enum TafsirSource {
  muyassar('ar', 'ar.muyassar'),
  jalalayn('ar', 'ar.jalalayn'),
  baghawi('ar', 'ar.baghawi'),
  qurtubi('ar', 'ar.qurtubi'),
  waseet('ar', 'ar.waseet'),

  /// Served by api.quran.com as HTML.
  ibnKathir('en', '169'),

  /// A translation of the meanings rather than a tafsir proper.
  saheeh('en', 'en.sahih');

  const TafsirSource(this.language, this.id);

  final String language;
  final String id;

  static TafsirSource defaultFor(String language) =>
      language == 'ar' ? muyassar : ibnKathir;
}

class Ayah {
  const Ayah({
    required this.surah,
    required this.number,
    required this.text,
    required this.page,
    required this.juz,
    this.sajda = false,
  });

  final int surah;

  /// Number within the surah.
  final int number;

  /// May contain tajweed markup, see [tajweedRuns].
  final String text;
  final int page;
  final int juz;
  final bool sajda;

  /// Starts a surah that gets a bismillah header; al-Fatihah has it as
  /// ayah 1 and at-Tawbah has none.
  bool get opensWithBismillah => number == 1 && surah != 1 && surah != 9;

  factory Ayah.fromJson(Map<String, dynamic> m) {
    final surah = (m['surah'] as Map<String, dynamic>)['number'] as int;
    final n = m['numberInSurah'] as int;
    var text = (m['text'] as String).replaceAll('\ufeff', '').trim();
    if (n == 1 && surah != 1 && surah != 9) text = stripBismillah(text);
    return Ayah(
      surah: surah,
      number: n,
      text: text,
      page: m['page'] as int,
      juz: m['juz'] as int,
      sajda: m['sajda'] != false,
    );
  }
}

/// One page of the Madinah mushaf; may hold the end of one surah and the
/// start of the next.
class MushafPage {
  const MushafPage({
    required this.number,
    required this.mushaf,
    required this.ayahs,
  });

  final int number;
  final Mushaf mushaf;
  final List<Ayah> ayahs;

  factory MushafPage.fromJson(Map<String, dynamic> data, Mushaf mushaf) =>
      MushafPage(
        number: data['number'] as int,
        mushaf: mushaf,
        ayahs: [
          for (final a in data['ayahs'] as List)
            Ayah.fromJson(a as Map<String, dynamic>),
        ],
      );
}

final _tajweedMark = RegExp(r'\[([a-z])(?::\d+)?\[([^\]]*)\]');
final _harakat = RegExp(
  '[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640]',
);

/// Splits tajweed markup like `[h:1[ٱ]` into (text, rule) runs.
List<(String, String?)> tajweedRuns(String text) {
  final runs = <(String, String?)>[];
  var at = 0;
  for (final m in _tajweedMark.allMatches(text)) {
    if (m.start > at) runs.add((text.substring(at, m.start), null));
    runs.add((m[2]!, m[1]));
    at = m.end;
  }
  if (at < text.length) runs.add((text.substring(at), null));
  return runs;
}

String stripTajweed(String text) =>
    text.replaceAllMapped(_tajweedMark, (m) => m[2]!);

/// Most editions prefix ayah 1 of every surah with the bismillah; the
/// diacritics differ between them, so compare bare letters.
String stripBismillah(String text) {
  final words = text.split(' ');
  if (words.length <= 4) return text;
  final bare = stripTajweed(
    words.take(4).join(' '),
  ).replaceAll(_harakat, '').replaceAll('ٱ', 'ا');
  return bare == 'بسم الله الرحمن الرحيم' ? words.skip(4).join(' ') : text;
}

/// Turns tafsir HTML into paragraphs of plain text.
String htmlToText(String html) => html
    .replaceAll(
      RegExp(r'<br\s*/?>|</p>|</h\d>|</li>', caseSensitive: false),
      '\n\n',
    )
    .replaceAll(RegExp(r'<[^>]+>'), '')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&amp;', '&')
    .replaceAll(RegExp(r'[ \t]+\n'), '\n')
    .replaceAll(RegExp(r'\n{3,}'), '\n\n')
    .trim();

class QuranApi {
  QuranApi({http.Client? client, this._text})
    : _client = client ?? http.Client();

  final http.Client _client;

  /// Bundled texts; the network is only used if these fail to load.
  final QuranText? _text;
  final _pages = <(int, Mushaf), MushafPage>{};
  final _ayahs = <(int, int, Mushaf), Ayah>{};
  final _tafsirs = <(TafsirSource, int, int), String>{};

  Future<void> preload(Mushaf mushaf) async {
    try {
      await _text?.preload(mushaf);
    } catch (_) {}
  }

  /// [page] when it can be shown without waiting.
  MushafPage? pageNow(int page, Mushaf mushaf) =>
      _pages[(page, mushaf)] ?? _text?.pageNow(page, mushaf);

  Future<MushafPage> fetchPage(int page, Mushaf mushaf) async {
    final cached = pageNow(page, mushaf);
    if (cached != null) return cached;
    if (_text case final text?) {
      try {
        return await text.page(page, mushaf);
      } catch (_) {}
    }
    final body = await _get(
      Uri.https('api.alquran.cloud', '/v1/page/$page/${mushaf.edition}'),
    );
    final result = await compute(_parsePage, (body, mushaf));
    for (final a in result.ayahs) {
      _ayahs[(a.surah, a.number, mushaf)] = a;
    }
    return _pages[(page, mushaf)] = result;
  }

  Future<Ayah> fetchAyah(int surah, int ayah, Mushaf mushaf) async {
    final cached = _ayahs[(surah, ayah, mushaf)];
    if (cached != null) return cached;
    if (_text case final text?) {
      try {
        return await text.ayah(surah, ayah, mushaf);
      } catch (_) {}
    }
    final body = await _get(
      Uri.https('api.alquran.cloud', '/v1/ayah/$surah:$ayah/${mushaf.edition}'),
    );
    return _ayahs[(surah, ayah, mushaf)] = Ayah.fromJson(_alquranData(body));
  }

  Future<String> fetchTafsir(TafsirSource source, int surah, int ayah) async {
    final key = (source, surah, ayah);
    final cached = _tafsirs[key];
    if (cached != null) return cached;

    final String text;
    if (source == TafsirSource.ibnKathir) {
      final body = await _get(
        Uri.https(
          'api.quran.com',
          '/api/v4/tafsirs/${source.id}/by_ayah/$surah:$ayah',
        ),
      );
      final json = _decode(body);
      text = htmlToText('${json['tafsir']?['text'] ?? ''}');
    } else {
      final body = await _get(
        Uri.https('api.alquran.cloud', '/v1/ayah/$surah:$ayah/${source.id}'),
      );
      text = '${_alquranData(body)['text'] ?? ''}'.trim();
    }
    return _tafsirs[key] = text;
  }

  Future<String> _get(Uri uri, {Duration? timeout}) async {
    final http.Response res;
    try {
      res = await _client
          .get(uri)
          .timeout(timeout ?? const Duration(seconds: 15));
    } catch (_) {
      throw const ApiException(ApiException.network);
    }
    if (res.statusCode != 200) {
      throw const ApiException(ApiException.badResponse);
    }
    return utf8.decode(res.bodyBytes);
  }

  static Map<String, dynamic> _decode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      throw const ApiException(ApiException.badResponse);
    }
  }

  static Map<String, dynamic> _alquranData(String body) {
    final json = _decode(body);
    if (json['code'] != 200 || json['data'] is! Map) {
      throw const ApiException(ApiException.badResponse);
    }
    return json['data'] as Map<String, dynamic>;
  }

  static MushafPage _parsePage((String, Mushaf) args) =>
      MushafPage.fromJson(_alquranData(args.$1), args.$2);
}
