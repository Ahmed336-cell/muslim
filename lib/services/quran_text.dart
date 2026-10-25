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

  /// The ayah a spoken transcript is reading, or null when the words are
  /// too short or fit more than one place equally.
  Future<Ayah?> locate(String transcript) async =>
      (await locateSpan(transcript))?.start;

  /// Where [transcript] sits. [VerseSpan.end] is a later ayah when the
  /// clip crosses a verse boundary. A phrase that occurs in several
  /// places (the basmalah, the refrain of ar-Rahman) stays null.
  Future<VerseSpan?> locateSpan(String transcript) async {
    final edition = await _edition(Mushaf.plain);
    final stream = edition.stream ??= _WordStream.of(edition);
    final hit = stream.align(_spokenWords(transcript));
    if (hit == null) return null;
    return VerseSpan(edition._ayah(hit.$1), edition._ayah(hit.$2));
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

final _nonArabic = RegExp(r'[^\u0621-\u064A\s]');

const _bismillahWords = ['بسم', 'الله', 'الرحمن', 'الرحيم'];

/// Start and end ayah of one recited passage. They are the same ayah when
/// the clip stays inside a single verse.
class VerseSpan {
  const VerseSpan(this.start, this.end);

  final Ayah start;
  final Ayah end;
}

List<String> _tokens(String text) {
  final spoken = foldArabic(text)
      .replaceAll(_nonArabic, ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return [
    for (final w in spoken.split(' '))
      if (w.length >= 2) w,
  ];
}

List<String> _spokenWords(String transcript) {
  final words = _tokens(transcript);
  if (words.length >= 7 &&
      words[0] == _bismillahWords[0] &&
      words[1] == _bismillahWords[1] &&
      words[2] == _bismillahWords[2] &&
      words[3] == _bismillahWords[3]) {
    return words.sublist(4);
  }
  return words;
}

class _WordStream {
  _WordStream(this.words, this.ayahOf, this._grams);

  final List<String> words;
  final List<int> ayahOf;
  final Map<int, Map<String, List<int>>> _grams;

  static _WordStream of(_Edition edition) {
    final words = <String>[];
    final ayahOf = <int>[];
    for (var i = 0; i < edition.texts.length; i++) {
      for (final word in _tokens(edition._ayah(i).text)) {
        words.add(word);
        ayahOf.add(i);
      }
    }
    final grams = <int, Map<String, List<int>>>{};
    for (final n in const [3, 4, 5]) {
      final table = <String, List<int>>{};
      for (var i = 0; i + n <= words.length; i++) {
        final key = words.sublist(i, i + n).join(' ');
        (table[key] ??= []).add(i);
      }
      grams[n] = table;
    }
    return _WordStream(words, ayahOf, grams);
  }

  /// Ayah indexes `(start, end)` into the edition, or null on a tie.
  (int, int)? align(List<String> query) {
    if (query.length < 3) return null;
    final width = query.length >= 8 ? 5 : query.length >= 5 ? 4 : 3;
    final votes = <int, int>{};
    var grams = 0;
    for (var q = 0; q + width <= query.length; q++) {
      final hits = _grams[width]![query.sublist(q, q + width).join(' ')];
      if (hits == null) continue;
      grams++;
      for (final pos in hits) {
        votes[pos - q] = (votes[pos - q] ?? 0) + 1;
      }
    }
    if (grams == 0 || votes.isEmpty) return null;
    final possible = query.length - width + 1;
    var start = 0;
    var best = 0;
    var second = 0;
    votes.forEach((at, score) {
      if (score > best) {
        second = best;
        best = score;
        start = at;
      } else if (score == best) {
        second = score;
      } else if (score > second) {
        second = score;
      }
    });
    if (best < 1 || best == second) return null;
    // A clean clip matches most grams. One exact stretch in a misheard
    // transcript stays under 0.34, but still counts when it leads by 2x.
    final margin = best >= 3 && best >= second * 2;
    if (best / possible < 0.34 && !margin) return null;
    if (start < 0 || start >= words.length) return null;
    final end = start + query.length - 1;
    final last = end < words.length ? end : words.length - 1;
    return (ayahOf[start], ayahOf[last]);
  }
}

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

  /// Word stream for [QuranText.locateSpan], built on the first locate.
  _WordStream? stream;

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
