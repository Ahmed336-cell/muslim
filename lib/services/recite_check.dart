import 'dart:math';

import 'quran.dart';
import 'quran_text.dart';

enum WordMark { correct, wrong, missing, unreached }

/// A word of the expected text: where it sits on the page and its folded
/// form for comparison.
typedef ExpectedWord = ({int ayah, int index, String word, String folded});

final _nonLetters = RegExp('[^\u0621-\u064A]');

/// Folded letters only; waqf signs and other marks fold to ''.
String reciteFold(String word) => foldArabic(word).replaceAll(_nonLetters, '');

/// Words of [ayahs] as they appear on the page (split like the page does),
/// skipping stand-alone marks.
List<ExpectedWord> expectedWords(List<Ayah> ayahs) => [
  for (final a in ayahs)
    for (final (i, w) in stripTajweed(a.text).split(' ').indexed)
      if (reciteFold(w) case final f when f.isNotEmpty)
        (ayah: a.number, index: i, word: w, folded: f),
];

List<String> heardWords(String transcript) => [
  for (final w in transcript.split(RegExp(r'\s+')))
    if (reciteFold(w) case final f when f.isNotEmpty) f,
];

/// Close enough to count as the same word: Uthmani and plain spellings
/// differ mostly in alifs (الصلوة / الصلاة, إبرٰهيم / إبراهيم).
bool sameWord(String a, String b) {
  if (a == b) return true;
  final bareA = a.replaceAll('ا', ''), bareB = b.replaceAll('ا', '');
  if (bareA == bareB && bareA.isNotEmpty) return true;
  return max(a.length, b.length) >= 5 && _distance(a, b) <= 1;
}

int _distance(String a, String b) {
  var prev = List<int>.generate(b.length + 1, (j) => j);
  for (var i = 1; i <= a.length; i++) {
    final row = [i, ...List.filled(b.length, 0)];
    for (var j = 1; j <= b.length; j++) {
      row[j] = min(
        min(prev[j] + 1, row[j - 1] + 1),
        prev[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1),
      );
    }
    prev = row;
  }
  return prev[b.length];
}

/// Word-level alignment of [heard] against [expected] (both folded). Each
/// expected word gets a mark, and wrong words what was heard instead; words
/// after the last one recited are [WordMark.unreached] rather than missing,
/// so stopping early isn't a mistake.
({List<WordMark> marks, List<String?> heardAs}) alignRecitation(
  List<String> expected,
  List<String> heard,
) {
  final n = expected.length, m = heard.length;
  final cost = List.generate(n + 1, (_) => List.filled(m + 1, 0));
  for (var i = 0; i <= n; i++) {
    cost[i][0] = i;
  }
  for (var j = 0; j <= m; j++) {
    cost[0][j] = j;
  }
  for (var i = 1; i <= n; i++) {
    for (var j = 1; j <= m; j++) {
      final diag =
          cost[i - 1][j - 1] +
          (sameWord(expected[i - 1], heard[j - 1]) ? 0 : 1);
      cost[i][j] = min(diag, min(cost[i - 1][j] + 1, cost[i][j - 1] + 1));
    }
  }

  // The reciter may stop anywhere: end where the recitation fits best, and
  // on a tie credit the furthest point.
  var end = 0;
  for (var i = 1; i <= n; i++) {
    if (cost[i][m] <= cost[end][m]) end = i;
  }

  final marks = List.filled(n, WordMark.missing);
  final heardAs = List<String?>.filled(n, null);
  var i = end, j = m;
  while (i > 0 && j > 0) {
    final same = sameWord(expected[i - 1], heard[j - 1]);
    if (cost[i][j] == cost[i - 1][j - 1] + (same ? 0 : 1)) {
      marks[i - 1] = same ? WordMark.correct : WordMark.wrong;
      if (!same) heardAs[i - 1] = heard[j - 1];
      i--;
      j--;
    } else if (cost[i][j] == cost[i - 1][j] + 1) {
      i--;
    } else {
      j--;
    }
  }

  final last = marks
      .take(end)
      .toList()
      .lastIndexWhere((k) => k != WordMark.missing);
  for (var k = last + 1; k < n; k++) {
    marks[k] = WordMark.unreached;
  }
  return (marks: marks, heardAs: heardAs);
}

/// Marks for the page, keyed by (ayah, word index).
final class ReciteResult {
  const ReciteResult({
    required this.words,
    required this.marks,
    required this.heardAs,
    required this.heard,
  });

  factory ReciteResult.of(List<Ayah> ayahs, String transcript) {
    final expected = expectedWords(ayahs);
    final aligned = alignRecitation([
      for (final w in expected) w.folded,
    ], heardWords(transcript));
    return ReciteResult(
      words: [for (final w in expected) w],
      marks: {
        for (final (k, w) in expected.indexed)
          (w.ayah, w.index): aligned.marks[k],
      },
      heardAs: {
        for (final (k, w) in expected.indexed)
          (w.ayah, w.index): ?aligned.heardAs[k],
      },
      heard: transcript.trim(),
    );
  }

  final List<ExpectedWord> words;
  final Map<(int, int), WordMark> marks;

  /// What was heard in place of each wrong word.
  final Map<(int, int), String> heardAs;
  final String heard;

  int count(WordMark mark) => marks.values.where((m) => m == mark).length;

  /// Words up to where the reciter stopped.
  int get reached => marks.length - count(WordMark.unreached);

  /// Matched share of the words reached, 0…1.
  double get score => reached == 0 ? 0 : count(WordMark.correct) / reached;

  WordMark markOf(ExpectedWord w) => marks[(w.ayah, w.index)]!;

  /// Words to review, in page order.
  List<ExpectedWord> get mistakes => [
    for (final w in words)
      if (markOf(w) case WordMark.wrong || WordMark.missing) w,
  ];

  /// Ayahs recited in full without a possible mistake.
  List<int> get perfectAyahs => [
    for (final a in {for (final w in words) w.ayah})
      if (words
          .where((w) => w.ayah == a)
          .every((w) => markOf(w) == WordMark.correct))
        a,
  ];
}
