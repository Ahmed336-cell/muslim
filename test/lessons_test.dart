import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim/bloc/lessons_cubit.dart';
import 'package:muslim/l10n/l10n.dart';
import 'package:muslim/screens/lesson_screen.dart';
import 'package:muslim/services/kids_content.dart';
import 'package:muslim/services/lessons.dart';
import 'package:muslim/services/tajweed_lessons.dart';

import 'helpers.dart';

final _all = [
  wuduLesson,
  salahLesson,
  kidsDuas,
  lettersLesson(),
  ...tajweedLessons,
];

void main() {
  setUp(() {
    useMemoryStorage();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('lesson content is well formed', () {
    expect({for (final l in _all) l.id}.length, _all.length);
    for (final lesson in _all) {
      expect(lesson.steps, isNotEmpty, reason: lesson.id);
      for (final q in lesson.quiz) {
        expect(q.answer, inInclusiveRange(0, q.options.length - 1));
        expect({for (final o in q.options) o.en}.length, q.options.length);
      }
    }
    expect(arabicLetters, hasLength(28));
  });

  test('stars keep the best result', () {
    final c = LessonsCubit()
      ..finish('a', 2)
      ..finish('a', 1)
      ..toggleSurah(112);
    expect(c.state.stars['a'], 2);
    expect(c.state.totalStars, 5);
    expect(LessonsCubit.starsFor(9, 10), 3);
    expect(LessonsCubit.starsFor(1, 3), 1);
  });

  testWidgets('walk through a lesson and its quiz', (tester) async {
    final cubit = LessonsCubit();
    final lesson = tajweedLessons[1];
    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          localizationsDelegates: const [
            L10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: L10n.supportedLocales,
          home: LessonScreen(lesson: lesson),
        ),
      ),
    );
    await tester.pump();
    for (var i = 0; i < lesson.steps.length; i++) {
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
    }
    for (final q in lesson.quiz) {
      final next = find.byType(FilledButton);
      expect(tester.widget<FilledButton>(next).onPressed, isNull);
      await tester.tap(find.text(q.options[q.answer].en).last);
      await tester.pump();
      expect(find.text('Correct!'), findsOneWidget);
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(find.text('Lesson complete'), findsOneWidget);
    expect(cubit.state.stars[lesson.id], 3);
    expect(tester.takeException(), isNull);
  });
}
