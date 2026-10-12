import 'dart:convert';
import 'dart:io' show gzip;

import 'package:flutter/services.dart';

import 'quran.dart';

/// The whole Quran in every [Mushaf] script, bundled with the app so reading
/// never waits on the network.
class QuranText {
  QuranText({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const _dir = 'assets/quran';

  final AssetBundle _bundle;
  Future<_Meta>? _meta;
  final _texts = <Mushaf, Future<List<String>>>{};
  final _ready = <Mushaf, _Edition>{};

  /// Loads [mushaf] ahead of time; later calls return at once.
  Future<void> preload(Mushaf mushaf) => _edition(mushaf);

  /// [page] if [mushaf] is already in memory, without waiting a frame.
  MushafPage? pageNow(int page, Mushaf mushaf) => _ready[mushaf]?.page(page);

  Future<MushafPage> page(int page, Mushaf mushaf) async =>
      (await _edition(mushaf)).page(page);

  Future<Ayah> ayah(int surah, int ayah, Mushaf mushaf) async =>
      (await _edition(mushaf)).ayah(surah, ayah);

  /// Ayahs whose plain text contains [query], ignoring diacritics and the
  /// common spelling variants of alef, ya and ta marbuta. Ayahs come back in
  /// the plain script so [QuranMatch.start] indexes into [Ayah.text].
  Future<QuranSearch> search(String query, {int limit = 100}) async {
    final q = foldArabic(query).trim().replaceAll(RegExp(r'\s+'), ' ');
    if (q.length < 2) return const QuranSearch(0, []);
    final edition = await _edition(Mushaf.plain);
    final folded = edition.folded ??= [
      for (var i = 0; i < edition.texts.length; i++)
        foldArabic(edition._ayah(i).text),
    ];
    var total = 0;
    final matches = <QuranMatch>[];
    for (var i = 0; i < folded.length; i++) {
      final at = folded[i].indexOf(q);
      if (at < 0) continue;
      total++;
      if (matches.length < limit) {
        matches.add(QuranMatch(edition._ayah(i), at, q.length));
      }
    }
    return QuranSearch(total, matches);
  }

  Future<_Edition> _edition(Mushaf mushaf) async {
    final ready = _ready[mushaf];
    if (ready != null) return ready;
    try {
      final meta = await (_meta ??= _loadMeta());
      final texts = await (_texts[mushaf] ??= _loadTexts(mushaf));
      return _ready[mushaf] ??= _Edition(mushaf, meta, texts);
    } catch (_) {
      _meta = null;
      _texts.remove(mushaf);
      rethrow;
    }
  }

  Future<_Meta> _loadMeta() async =>
      _Meta(jsonDecode(await _bundle.loadString('$_dir/meta.json')) as Map);

  Future<List<String>> _loadTexts(Mushaf mushaf) async {
    final data = await _bundle.load('$_dir/${mushaf.edition}.txt.gz');
    final bytes = gzip.decode(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    final texts = utf8.decode(bytes).split('\n');
    if (texts.length != _Meta.ayahCount) throw const FormatException();
    return texts;
  }
}

class QuranMatch {
  const QuranMatch(this.ayah, this.start, this.length);

  final Ayah ayah;
  final int start;
  final int length;
}

class QuranSearch {
  const QuranSearch(this.total, this.matches);

  /// Every matching ayah, even beyond [matches].
  final int total;
  final List<QuranMatch> matches;
}

final _diacritics = RegExp(
  '[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640]',
);

const _folds = {
  'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ٱ': 'ا', 'ى': 'ي', 'ئ': 'ي', 'ة': 'ه', //
  'ؤ': 'و',
};

/// Arabic folded for matching. Only drops marks, so text without them keeps
/// its length and offsets.
String foldArabic(String s) => s
    .replaceAll(_diacritics, '')
    .replaceAllMapped(RegExp('[أإآٱىئةؤ]'), (m) => _folds[m[0]]!);

class _Meta {
  _Meta(Map json)
    : page = List<int>.from(json['page'] as List),
      juz = List<int>.from(json['juz'] as List),
      sajda = Set<int>.from(json['sajda'] as List) {
    final counts = List<int>.from(json['counts'] as List);
    var at = 0;
    for (var s = 0; s < counts.length; s++) {
      surahStart.add(at);
      for (var n = 1; n <= counts[s]; n++) {
        surahOf.add(s + 1);
        numberOf.add(n);
      }
      at += counts[s];
    }
    for (var i = 0; i < page.length; i++) {
      if (i == 0 || page[i] != page[i - 1]) pageStart.add(i);
    }
    pageStart.add(page.length);
    if (page.length != ayahCount || surahOf.length != ayahCount) {
      throw const FormatException();
    }
  }

  static const ayahCount = 6236;

  final List<int> page;
  final List<int> juz;
  final Set<int> sajda;
  final surahStart = <int>[];
  final surahOf = <int>[];
  final numberOf = <int>[];

  /// Index of the first ayah of each page, plus the end.
  final pageStart = <int>[];
}

class _Edition {
  _Edition(this.mushaf, this.meta, this.texts);

  final Mushaf mushaf;
  final _Meta meta;
  final List<String> texts;
  final _pages = <int, MushafPage>{};

  /// [texts] folded by [foldArabic], built on the first search.
  List<String>? folded;

  MushafPage page(int number) => _pages[number] ??= MushafPage(
    number: number,
    mushaf: mushaf,
    ayahs: [
      for (var i = meta.pageStart[number - 1]; i < meta.pageStart[number]; i++)
        _ayah(i),
    ],
  );

  Ayah ayah(int surah, int number) =>
      _ayah(meta.surahStart[surah - 1] + number - 1);

  Ayah _ayah(int i) {
    final surah = meta.surahOf[i];
    final n = meta.numberOf[i];
    var text = texts[i].replaceAll('\ufeff', '').trim();
    if (n == 1 && surah != 1 && surah != 9) text = stripBismillah(text);
    return Ayah(
      surah: surah,
      number: n,
      text: text,
      page: meta.page[i],
      juz: meta.juz[i],
      sajda: meta.sajda.contains(i),
    );
  }
}
