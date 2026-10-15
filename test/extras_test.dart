import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/bloc/extra_reminders_cubit.dart';
import 'package:muslim/bloc/friday_cubit.dart';
import 'package:muslim/bloc/ramadan_cubit.dart';
import 'package:muslim/screens/ramadan_screen.dart';
import 'package:muslim/services/daily_content.dart';
import 'package:muslim/services/notifications.dart';
import 'package:muslim/services/places.dart';
import 'package:muslim/services/prayer_calc.dart';

import 'helpers.dart';

class _FakeNotifier extends PrayerNotifier {
  List<ExtraReminder> scheduled = [];

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleExtras(List<ExtraReminder> reminders) async =>
      scheduled = reminders;
}

void main() {
  const calc = PrayerCalculator();
  final cairo = cityById('cairo').place;
  setUp(useMemoryStorage);

  test('daily ayah and hadith change by day and stay in range', () {
    final a = DateTime(2026, 10, 12);
    final b = DateTime(2026, 10, 13);
    expect(ayahOfDay(a), isNot(ayahOfDay(b)));
    expect(hadithOfDay(a), isNot(same(hadithOfDay(b))));
    expect(ayahOfDay(DateTime(2026, 10, 12 + dailyAyahs.length)), ayahOfDay(a));
    expect(dailyHadith.every((h) => h.ar.isNotEmpty && h.en.isNotEmpty), true);
  });

  test('Jumu\'ah mood is Maghrib Thursday to Maghrib Friday', () {
    final thu = DateTime(2026, 10, 15); // Thursday
    final fri = DateTime(2026, 10, 16);
    final day = calc.today(cairo, DateTime.utc(2026, 10, 15, 9));
    final maghrib = day.prayers.firstWhere((p) => p.name == 'Maghrib');
    final at = maghrib.on(thu);
    expect(
      isJumuahMood(at.subtract(const Duration(minutes: 1)), day: day),
      false,
    );
    expect(isJumuahMood(at, day: day), true);
    expect(
      isJumuahMood(DateTime(fri.year, fri.month, fri.day, 10), day: day),
      true,
    );
    final friMaghrib = maghrib.on(fri);
    expect(
      isJumuahMood(friMaghrib.subtract(const Duration(minutes: 1)), day: day),
      true,
    );
    expect(isJumuahMood(friMaghrib, day: day), false);
    expect(isJumuahMood(DateTime(2026, 10, 14, 20)), false);
  });

  test('Friday reminders: Kahf, salawat and last-hour dua', () async {
    // Thursday noon in Cairo.
    final now = DateTime.utc(2026, 10, 15, 9);
    final day = calc.today(cairo, now);
    final notifier = _FakeNotifier();
    final cubit = ExtraRemindersCubit(notifier: notifier, now: () => now);
    await cubit.sync(day, 'en');

    final kahf = notifier.scheduled.where((r) => r.payload == 'kahf').toList();
    expect(kahf, hasLength(1));
    expect(kahf.single.at.toLocal().weekday, DateTime.friday);
    expect(kahf.single.at.toLocal().hour, 10);

    final salawat = notifier.scheduled
        .where((r) => r.payload == 'friday' && r.id >= extraIdBase + 120)
        .single;
    expect(salawat.at.toLocal().weekday, DateTime.friday);
    expect(salawat.at.toLocal().hour, 11);
    expect(salawat.body, contains('مُحَمَّدٍ'));

    final hour = notifier.scheduled
        .where((r) => r.id >= extraIdBase + 40 && r.id < extraIdBase + 60)
        .single;
    final maghrib = day.following.first.firstWhere((p) => p.name == 'Maghrib');
    // Cairo is UTC+3 in October.
    expect(
      hour.at,
      DateTime.utc(
        2026,
        10,
        16,
        maghrib.hour - 3,
        maghrib.minute,
      ).subtract(const Duration(hours: 1)),
    );
    expect(hour.body, contains('رَبَّنَا آتِنَا'));
    expect(notifier.scheduled.map((r) => r.id).toSet(), hasLength(3));
  });

  Future<void> only(ExtraRemindersCubit cubit, Set<ExtraKind> kinds) async {
    for (final k in ExtraKind.values) {
      final want = kinds.contains(k);
      if (cubit.state.on.contains(k) != want) await cubit.setEnabled(k, want);
    }
  }

  test('suhoor reminders only in Ramadan', () async {
    final notifier = _FakeNotifier();
    var now = DateTime.utc(2026, 10, 12, 9);
    final cubit = ExtraRemindersCubit(notifier: notifier, now: () => now);
    await only(cubit, {ExtraKind.suhoor});
    await cubit.sync(calc.today(cairo, now), 'ar');
    expect(notifier.scheduled, isEmpty);

    now = DateTime.utc(2027, 2, 20, 9);
    final day = calc.today(cairo, now);
    expect(day.hijriMonth, 9);
    await cubit.sync(day, 'ar');
    expect(notifier.scheduled, isNotEmpty);
    expect(notifier.scheduled.first.title, 'السحور');
  });

  test('daily ayah reminder carries the text', () async {
    final notifier = _FakeNotifier();
    final now = DateTime(2026, 10, 12, 6);
    final cubit = ExtraRemindersCubit(notifier: notifier, now: () => now);
    await only(cubit, {ExtraKind.ayah});
    expect(notifier.scheduled, hasLength(8));
    final (s, a) = ayahOfDay(now);
    expect(notifier.scheduled.first.payload, 'ayah:$s:$a');
    expect(notifier.scheduled.first.at.toLocal().hour, 8);
  });

  test('Ramadan countdown switches between suhoor and iftar', () {
    final day = calc.today(cairo, DateTime.utc(2027, 2, 20, 9));
    final noon = ramadanCountdown(day, DateTime.utc(2027, 2, 20, 10))!;
    expect(noon.iftar, true);
    final night = ramadanCountdown(day, DateTime.utc(2027, 2, 20, 20))!;
    expect(night.iftar, false);
    expect(night.at.day, 21);
    expect(
      ramadanCountdown(
        calc.today(cairo, DateTime.utc(2026, 10, 12)),
        DateTime.utc(2026, 10, 12),
      ),
      isNull,
    );
  });

  test('Ramadan log is per year; Friday counter resets daily', () {
    final r = RamadanCubit()
      ..toggle(1448, 1, RamadanDeed.fast)
      ..toggle(1448, 2, RamadanDeed.fast);
    expect(r.of(1448).count(RamadanDeed.fast), 2);
    expect(r.of(1449).days, isEmpty);
    expect(RamadanCubit().state, r.state);

    var now = DateTime(2026, 10, 16, 9);
    final f = FridayCubit(clock: () => now)
      ..salawat()
      ..salawat()
      ..toggle(FridayDeed.kahf);
    expect(f.today.salawat, 2);
    expect(f.today.done, {FridayDeed.kahf});
    now = DateTime(2026, 10, 17, 9);
    expect(f.today.salawat, 0);
  });
}
