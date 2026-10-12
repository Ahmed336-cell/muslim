import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/bloc/audio_cubit.dart';
import 'package:muslim/bloc/azkar_cubit.dart';
import 'package:muslim/bloc/azkar_reminders_cubit.dart';
import 'package:muslim/bloc/hisn_cubit.dart';
import 'package:muslim/l10n/l10n.dart';
import 'package:muslim/screens/azkar_screen.dart';
import 'package:muslim/screens/hisn_screen.dart';
import 'package:muslim/services/adhan.dart';
import 'package:muslim/services/hisn.dart';
import 'package:muslim/services/notifications.dart';

import 'helpers.dart';

class _FakeNotifier extends PrayerNotifier {
  _FakeNotifier({this.grant = true});

  final bool grant;
  List<AzkarReminder> azkar = [];
  final titles = <String>[];
  String body = '';

  @override
  Future<bool> requestPermission() async => grant;

  @override
  Future<void> schedule(
    List<PrayerReminder> reminders, {
    required String Function(String prayer) title,
    required String body,
    AdhanVoice? voice,
  }) async {}

  @override
  Future<void> scheduleAzkar(
    List<AzkarReminder> reminders, {
    required String Function(AzkarSession session) title,
    required String body,
  }) async {
    azkar = reminders;
    this.body = body;
    titles
      ..clear()
      ..addAll(reminders.map((r) => title(r.session)));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('bundled book', () {
    late HisnBook book;
    setUpAll(() async => book = await HisnRepository().load());

    test('has every chapter and both sessions', () {
      expect(book.chapters, hasLength(132));
      expect(book.chapters.first.id, 1);
      expect(book.morning, hasLength(23));
      expect(book.evening, hasLength(20));
      expect(
        book.chapters.every((c) => c.items.isNotEmpty && c.arabic.isNotEmpty),
        isTrue,
      );
    });

    test('evening wording replaces the morning wording', () {
      Dhikr find(List<Dhikr> l, int id) => l.firstWhere((d) => d.id == id);
      expect(find(book.morning, 77).arabic, startsWith('أَصْبَحْنَا'));
      expect(find(book.evening, 77).arabic, startsWith('أَمْسَيْنَا'));
      expect(find(book.evening, 77).translation, contains('evening'));
      expect(find(book.evening, 80).arabic, contains('أَمْسَيْتُ'));
      expect(book.evening.map((d) => d.id), contains(97));
      expect(book.morning.map((d) => d.id), isNot(contains(97)));
      for (final d in [...book.morning, ...book.evening]) {
        expect(d.arabic, isNot(contains('((')));
        expect(d.arabic, isNot(contains('[')));
        expect(d.translation, isNotEmpty);
      }
    });

    test('counts match the sunnah', () {
      int n(int id) => book.morning.firstWhere((d) => d.id == id).repeat;
      expect(n(76), 3);
      expect(n(80), 4);
      expect(n(83), 7);
      expect(n(91), 100);
    });

    test('search ignores harakat and finds titles in both languages', () {
      expect(book.search('النوم').map((c) => c.id), contains(28));
      expect(book.search('sleeping').map((c) => c.id), contains(28));
      expect(book.search('سبحان الله وبحمده').map((c) => c.id), contains(27));
      expect(book.search('').length, 132);
    });
  });

  group('AzkarCubit', () {
    setUp(useMemoryStorage);
    const a = Dhikr(id: 1, arabic: 'a', repeat: 3);
    const b = Dhikr(id: 2, arabic: 'b');
    const items = [a, b];

    test('counts to the target, then the session', () {
      final c = AzkarCubit();
      const m = AzkarSession.morning;
      expect(c.tap(m, a, items), AzkarTap.counted);
      expect(c.tap(m, a, items), AzkarTap.counted);
      expect(c.tap(m, a, items), AzkarTap.itemDone);
      expect(c.tap(m, a, items), AzkarTap.itemDone, reason: 'stays done');
      expect(c.countOf(m, a), 3);
      expect(c.tap(m, b, items), AzkarTap.sessionDone);
      expect(c.doneIn(m, items), 2);
      expect(c.doneIn(AzkarSession.evening, items), 0);
    });

    test('a new day starts fresh; reset clears one session', () {
      var now = DateTime(2026, 10, 12, 8);
      final c = AzkarCubit(now: () => now);
      c
        ..tap(AzkarSession.morning, b, items)
        ..tap(AzkarSession.evening, b, items);
      c.reset(AzkarSession.morning);
      expect(c.countOf(AzkarSession.morning, b), 0);
      expect(c.countOf(AzkarSession.evening, b), 1);

      now = DateTime(2026, 10, 13, 8);
      expect(c.countOf(AzkarSession.evening, b), 0);
    });
  });

  group('adhkar reminders', () {
    setUp(useMemoryStorage);

    test('a rolling week at local times, skipping ones already past', () {
      final now = DateTime(2026, 10, 12, 9);
      final r = azkarRemindersFor({
        AzkarSession.morning: 7 * 60,
        AzkarSession.evening: 17 * 60 + 30,
      }, now);
      expect(r.first.session, AzkarSession.evening);
      expect(r.first.at.toLocal(), DateTime(2026, 10, 12, 17, 30));
      expect(r[1].at.toLocal(), DateTime(2026, 10, 13, 7));
      expect(r, hasLength(15));
      expect(r.map((x) => x.id).toSet(), hasLength(15));
      expect(r.every((x) => x.id >= azkarIdBase), isTrue);
      expect(r.first.payload, 'azkar:evening');
    });

    test('needs permission, schedules localized, survives restart', () async {
      final denied = _FakeNotifier(grant: false);
      final off = AzkarRemindersCubit(notifier: denied);
      await off.setEnabled(AzkarSession.morning, true);
      expect(off.state.on, isEmpty);
      expect(off.state.denied, isTrue);

      final n = _FakeNotifier();
      final c = AzkarRemindersCubit(
        notifier: n,
        now: () => DateTime(2026, 10, 12, 5),
      );
      await c.sync('ar');
      await c.setEnabled(AzkarSession.morning, true);
      await c.setTime(AzkarSession.morning, 6 * 60 + 15);
      expect(n.azkar.first.at.toLocal(), DateTime(2026, 10, 12, 6, 15));
      expect(n.titles.toSet(), {'أذكار الصباح'});

      await c.setEnabled(AzkarSession.morning, false);
      expect(n.azkar, isEmpty);

      final restored = AzkarRemindersCubit(notifier: n);
      expect(restored.state.timeOf(AzkarSession.morning), 6 * 60 + 15);
      expect(restored.state.timeOf(AzkarSession.evening), 17 * 60);
    });
  });

  group('screens', () {
    setUp(useMemoryStorage);

    Widget app(Widget home, {String lang = 'en'}) => MultiRepositoryProvider(
      providers: [RepositoryProvider(create: (_) => HisnRepository())],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (c) => HisnCubit(repository: c.read<HisnRepository>()),
          ),
          BlocProvider(create: (_) => AzkarCubit()),
          BlocProvider(create: (_) => AudioCubit()),
          BlocProvider(
            create: (_) => AzkarRemindersCubit(notifier: _FakeNotifier()),
          ),
        ],
        child: MaterialApp(
          locale: Locale(lang),
          supportedLocales: L10n.supportedLocales,
          localizationsDelegates: const [
            L10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: home,
        ),
      ),
    );

    testWidgets('tapping a card counts down to done', (tester) async {
      await tester.pumpWidget(
        app(const AzkarScreen(session: AzkarSession.evening)),
      );
      await tester.runAsync(() => HisnRepository().load());
      await tester.pumpAndSettle();

      expect(find.text('Evening adhkar'), findsOneWidget);
      expect(find.textContaining('0 of 20 done'), findsOneWidget);

      await tester.tap(find.textContaining('أَعُوذُ بِاللَّهِ').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('1 of 20 done'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('book lists chapters and opens one', (tester) async {
      await tester.pumpWidget(app(const HisnScreen(), lang: 'ar'));
      await tester.runAsync(() => HisnRepository().load());
      await tester.pumpAndSettle();

      expect(find.text('الصباح'), findsOneWidget);
      expect(find.text('المساء'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'الاستيقاظ');
      await tester.pumpAndSettle();
      await tester.tap(find.text('أذكار الاستيقاظ من النوم'));
      await tester.pumpAndSettle();
      expect(find.byType(HisnChapterScreen), findsOneWidget);
      expect(find.textContaining('الْحَمْدُ لِلَّهِ'), findsWidgets);
    });
  });
}
