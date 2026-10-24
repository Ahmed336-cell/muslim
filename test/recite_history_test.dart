import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/bloc/quran/recite_history_cubit.dart';
import 'package:muslim/services/quran.dart';
import 'package:muslim/services/recite_check.dart';

void main() {
  test('a saved check keeps its score and mistakes', () {
    const ayah = Ayah(surah: 1, number: 2, text: 'الحمد لله', page: 1, juz: 1);
    final result = ReciteResult.of([ayah], 'الحمد الله');
    final attempt = ReciteAttempt(
      at: DateTime.utc(2026, 10, 24, 12),
      surah: 1,
      from: 2,
      to: 2,
      result: result,
    );

    final back = ReciteAttempt.fromJson(attempt.toJson());

    expect(back, isNotNull);
    expect(back!.surah, 1);
    expect(back.from, 2);
    expect(back.result.heard, result.heard);
    expect(back.result.count(WordMark.correct), result.count(WordMark.correct));
    expect(back.result.count(WordMark.wrong), result.count(WordMark.wrong));
    expect(
      back.result.mistakes.map((w) => w.word),
      result.mistakes.map((w) => w.word),
    );
  });
}
