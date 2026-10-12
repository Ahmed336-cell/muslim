import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim/bloc/onboarding_cubit.dart';
import 'package:muslim/bloc/reminders_cubit.dart';
import 'package:muslim/data.dart';
import 'package:muslim/main.dart';
import 'package:muslim/services/adhan.dart';
import 'package:muslim/services/islamic_api.dart';
import 'package:muslim/services/notifications.dart';

import 'helpers.dart';

PrayerDay _day({Duration? offset = Duration.zero}) => PrayerDay(
  prayers: const [
    Prayer('Fajr', 'الفجر', 5, 0),
    Prayer('Sunrise', 'الشروق', 6, 30),
    Prayer('Dhuhr', 'الظهر', 12, 0),
    Prayer('Asr', 'العصر', 15, 30),
    Prayer('Maghrib', 'المغرب', 18, 0),
    Prayer('Isha', 'العشاء', 19, 30),
  ],
  city: 'Cairo',
  hijriDay: 1,
  hijriMonthAr: 'رجب',
  hijriYear: 1448,
  qiblaDegrees: 136,
  qiblaKm: 1287,
  utcOffset: offset,
);

class _FakeNotifier extends PrayerNotifier {
  _FakeNotifier({this.grant = true});

  final bool grant;
  final scheduled = <List<String>>[];
  AdhanVoice? lastVoice;
  final titles = <String>[];
  var permissionRequests = 0;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grant;
  }

  @override
  Future<void> schedule(
    List<PrayerReminder> reminders, {
    required String Function(String prayer) title,
    required String body,
    AdhanVoice? voice,
  }) async {
    lastVoice = voice;
    scheduled.add([for (final r in reminders) r.prayer]);
    titles
      ..clear()
      ..addAll(reminders.map((r) => title(r.prayer)));
  }
}

class _OfflineApi extends IslamicApi {
  _OfflineApi() : super(apiKey: 'test');

  @override
  Future<PrayerDay> fetchToday(Place place) => Future.error('offline');
}

void main() {
  group('remindersFor', () {
    test('only the chosen prayers still ahead today, never sunrise', () {
      final now = DateTime.utc(2026, 10, 12, 13);
      final r = remindersFor(_day(), {...reminderPrayers, 'Sunrise'}, now);
      expect(r.map((e) => e.prayer), ['Asr', 'Maghrib', 'Isha']);
      expect(r.first.at, DateTime.utc(2026, 10, 12, 15, 30));
    });

    test("uses the city's offset, not the device zone", () {
      final now = DateTime.utc(2026, 10, 12, 8);
      final r = remindersFor(_day(offset: const Duration(hours: 3)), {
        'Dhuhr',
      }, now);
      expect(r.single.at, DateTime.utc(2026, 10, 12, 9));
    });

    test('city offset that has already passed the prayer drops it', () {
      final now = DateTime.utc(2026, 10, 12, 10);
      final r = remindersFor(_day(offset: const Duration(hours: 3)), {
        'Dhuhr',
        'Asr',
      }, now);
      expect(r.map((e) => e.prayer), ['Asr']);
      expect(r.single.at, DateTime.utc(2026, 10, 12, 12, 30));
    });
  });

  group('RemindersCubit', () {
    setUp(useMemoryStorage);

    test('turns on only when permission is granted', () async {
      final denied = _FakeNotifier(grant: false);
      final c = RemindersCubit(notifier: denied);
      await c.enable();
      expect(c.state.enabled, isFalse);
      expect(c.state.denied, isTrue);
      expect(denied.scheduled, isEmpty);

      final ok = RemindersCubit(notifier: _FakeNotifier());
      await ok.enable();
      expect(ok.state.enabled, isTrue);
      expect(ok.state.denied, isFalse);
    });

    test('schedules localized reminders, clears them when off', () async {
      final n = _FakeNotifier();
      final c = RemindersCubit(notifier: n);
      await c.sync(_day(offset: null), 'ar');
      expect(n.scheduled, isEmpty, reason: 'off by default');

      await c.enable();
      final upcoming = remindersFor(_day(offset: null), {
        ...reminderPrayers,
      }, DateTime.now());
      expect(n.scheduled.last, upcoming.map((r) => r.prayer));
      if (upcoming.isNotEmpty) {
        expect(n.titles.first, startsWith('حان الآن وقت صلاة'));
      }

      await c.toggle('Isha');
      expect(c.state.prayers, isNot(contains('Isha')));
      expect(n.scheduled.last, isNot(contains('Isha')));

      await c.disable();
      if (upcoming.isNotEmpty) expect(n.scheduled.last, isEmpty);
    });

    test('schedules with the chosen adhan voice', () async {
      final n = _FakeNotifier();
      final c = RemindersCubit(notifier: n);
      expect(c.state.voice, AdhanVoice.makkah);
      await c.enable();
      await c.sync(_day(offset: null), 'en');
      expect(n.lastVoice, AdhanVoice.makkah);

      await c.setVoice(AdhanVoice.alafasy);
      expect(n.lastVoice, AdhanVoice.alafasy);
      await c.toggle('Fajr');
      expect(c.state.voice, AdhanVoice.alafasy, reason: 'kept on toggle');

      await c.setVoice(null);
      expect(n.lastVoice, isNull);
      expect(RemindersCubit(notifier: n).state.voice, isNull);
    });

    test('older saved reminders default to the Makkah adhan', () {
      final c = RemindersCubit(notifier: _FakeNotifier());
      expect(
        c.fromJson({
          'enabled': true,
          'prayers': ['Fajr'],
        })!.voice,
        AdhanVoice.makkah,
      );
      expect(AdhanVoice.zahrani.sound, 'adhan_zahrani');
    });

    test('persists choices', () async {
      final c = RemindersCubit(notifier: _FakeNotifier());
      await c.enable();
      await c.toggle('Fajr');
      final again = RemindersCubit(notifier: _FakeNotifier());
      expect(again.state.enabled, isTrue);
      expect(again.state.prayers, {'Dhuhr', 'Asr', 'Maghrib', 'Isha'});
    });
  });

  group('OnboardingCubit', () {
    setUp(useMemoryStorage);

    test('remembers the step and completion', () {
      OnboardingCubit().goTo(9);
      expect(OnboardingCubit().state.step, OnboardingCubit.steps - 1);
      OnboardingCubit().complete();
      expect(OnboardingCubit().state.done, isTrue);
      OnboardingCubit().restart();
      expect(OnboardingCubit().state, const Onboarding());
    });
  });

  group('first launch', () {
    setUp(() {
      useMemoryStorage();
      GoogleFonts.config.allowRuntimeFetching = false;
    });

    testWidgets('walks through every step, then lands on the app', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final notifier = _FakeNotifier();
      await tester.pumpWidget(
        MuslimApp(api: _OfflineApi(), notifier: notifier),
      );
      await tester.pump();

      expect(find.text('Welcome'), findsOneWidget);
      Future<void> next() async {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      await next();
      expect(find.text('Where do you pray?'), findsOneWidget);
      await next();
      expect(find.text('Never miss a prayer'), findsOneWidget);
      await tester.tap(find.text('Allow notifications'));
      await tester.pumpAndSettle();
      expect(notifier.permissionRequests, 1);
      await next();
      expect(find.text('Your mushaf'), findsOneWidget);
      await next();
      expect(find.text('All set'), findsOneWidget);

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome'), findsNothing);
      expect(OnboardingCubit().state.done, isTrue);
    });

    testWidgets('skip goes straight to the app', (tester) async {
      await tester.pumpWidget(
        MuslimApp(api: _OfflineApi(), notifier: _FakeNotifier()),
      );
      await tester.pump();
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome'), findsNothing);
    });
  });
}
