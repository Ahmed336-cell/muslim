import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/services/quran.dart';
import 'package:muslim/services/recite_check.dart';

void main() {
  const fatiha = [
    Ayah(
      surah: 1,
      number: 2,
      text: 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
      page: 1,
      juz: 1,
    ),
    Ayah(surah: 1, number: 3, text: 'ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', page: 1, juz: 1),
    Ayah(surah: 1, number: 4, text: 'مَٰلِكِ يَوْمِ ٱلدِّينِ', page: 1, juz: 1),
  ];

  List<WordMark> check(String heard) =>
      ReciteResult.of(fatiha, heard).marks.values.toList();

  test('folds Uthmani marks and skips waqf signs', () {
    expect(reciteFold('ٱلْعَٰلَمِينَ'), 'العلمين');
    expect(reciteFold('ۚ'), '');
    expect(
      expectedWords([
        const Ayah(
          surah: 2,
          number: 2,
          text: 'لَا رَيْبَ ۛ فِيهِ',
          page: 1,
          juz: 1,
        ),
      ]).map((w) => w.index),
      [0, 1, 3],
    );
  });

  test('plain spelling matches Uthmani', () {
    expect(sameWord('العلمين', 'العالمين'), isTrue);
    expect(sameWord('الصلوه', 'الصلاه'), isTrue);
    expect(sameWord('من', 'ما'), isFalse);
  });

  test('perfect recitation', () {
    expect(
      check('الحمد لله رب العالمين الرحمن الرحيم مالك يوم الدين'),
      everyElement(WordMark.correct),
    );
  });

  test('wrong and skipped words', () {
    final marks = check('الحمد لله رب العالمين الرحيم ملك يوم الدين');
    expect(marks[4], WordMark.missing);
    expect(marks[5], WordMark.correct);
    expect(marks[6], WordMark.correct);
    final swapped = check('الحمد لله رب الناس الرحمن الرحيم');
    expect(swapped[3], WordMark.wrong);
  });

  test('feedback: score, heard words, perfect ayahs', () {
    final result = ReciteResult.of(
      fatiha,
      'الحمد لله رب الناس الرحمن الرحيم مالك يوم الدين',
    );
    expect(result.score, closeTo(8 / 9, 1e-9));
    expect(result.mistakes.map((w) => w.folded), ['العلمين']);
    expect(result.heardAs[(2, 3)], 'الناس');
    expect(result.perfectAyahs, [3, 4]);
  });

  test('stopping early leaves the rest unreached', () {
    final result = ReciteResult.of(fatiha, 'الحمد لله رب العالمين');
    expect(result.count(WordMark.correct), 4);
    expect(result.count(WordMark.unreached), 5);
    expect(result.reached, 4);
  });

  test('a wrong last word is not matched against the end of the range', () {
    final result = ReciteResult.of(fatiha, 'الحمد لله رب الناس');
    expect(result.count(WordMark.wrong), 1);
    expect(result.heardAs[(2, 3)], 'الناس');
    expect(result.reached, 4);
  });
}
