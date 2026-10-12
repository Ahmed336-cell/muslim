import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim/bloc/onboarding_cubit.dart';
import 'package:muslim/bloc/settings_cubit.dart';
import 'package:muslim/main.dart';
import 'package:muslim/screens/calendar_screen.dart';
import 'package:muslim/screens/credits_screen.dart';
import 'package:muslim/screens/friday_screen.dart';
import 'package:muslim/screens/hadith_screen.dart';
import 'package:muslim/screens/hifz_screen.dart';
import 'package:muslim/screens/khatmah_screen.dart';
import 'package:muslim/screens/kids_screen.dart';
import 'package:muslim/screens/lesson_screen.dart';
import 'package:muslim/services/tajweed_lessons.dart';
import 'package:muslim/screens/qada_screen.dart';
import 'package:muslim/screens/ramadan_screen.dart';
import 'package:muslim/screens/sadaqah_screen.dart';
import 'package:muslim/screens/sleep_screen.dart';
import 'package:muslim/screens/travel_screen.dart';
import 'package:muslim/screens/tracker_screen.dart';
import 'package:muslim/services/islamic_api.dart';
import 'package:muslim/theme.dart';

import 'helpers.dart';

class _OfflineApi extends IslamicApi {
  _OfflineApi() : super(apiKey: 'test');
}

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(() => Palette.dark = false);

  for (final lang in ['en', 'ar']) {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      testWidgets('new screens lay out ($lang, ${theme.name})', (tester) async {
        tester.view
          ..physicalSize = const Size(1170, 2532)
          ..devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        useMemoryStorage();
        OnboardingCubit().complete();
        SettingsCubit()
          ..setLanguage(lang)
          ..setTheme(theme);
        await tester.pumpWidget(MuslimApp(api: _OfflineApi()));
        await tester.pump();
        expect(Palette.dark, theme == AppTheme.dark);

        final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
        Future<void> visit(Route<void> route) async {
          nav.push(route);
          await tester.pump(const Duration(milliseconds: 400));
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull);
        }

        await visit(CalendarScreen.route());
        await visit(KhatmahScreen.route());
        await tester.tap(find.byType(FilledButton).first);
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.byType(CircularProgressIndicator), findsWidgets);
        await visit(HifzScreen.route());
        await visit(CreditsScreen.route());
        await visit(PrivacyScreen.route());
        await visit(TrackerScreen.route());
        await tester.tap(find.byIcon(Icons.add_circle_outline_rounded).first);
        await tester.pump();
        expect(tester.takeException(), isNull);
        await visit(FridayScreen.route());
        await visit(RamadanScreen.route());
        await visit(HadithScreen.route());
        await visit(QadaScreen.route());
        await tester.tap(find.byIcon(Icons.add_rounded).first);
        await tester.pump();
        expect(tester.takeException(), isNull);
        await visit(KidsScreen.route());
        await visit(LessonScreen.route(tajweedLessons.first));
        await visit(SleepScreen.route());
        await visit(TravelScreen.route());
        await tester.tap(find.text(lang == 'ar' ? 'مسافر' : 'Travelling'));
        await tester.pump();
        expect(tester.takeException(), isNull);
        await visit(SadaqahScreen.route());
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull);
        await tester.pump(const Duration(seconds: 16));
      });
    }
  }
}
