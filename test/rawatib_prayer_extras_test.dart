import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/bloc/extra_reminders_cubit.dart';
import 'package:muslim/bloc/quran/quran_prefs_cubit.dart';
import 'package:muslim/services/notifications.dart';
import 'package:muslim/services/places.dart';
import 'package:muslim/services/prayer_calc.dart';
import 'package:muslim/services/rawatib.dart';
import 'package:muslim/services/tawashih.dart';

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

  test('rawatib map covers the five prayers', () {
    expect(rawatibFor('Fajr')!.before, 2);
    expect(rawatibFor('Dhuhr')!.before, 4);
    expect(rawatibFor('Dhuhr')!.after, 2);
    expect(rawatibFor('Asr')!.isEmpty, true);
    expect(rawatibFor('Maghrib')!.after, 2);
    expect(rawatibFor('Isha')!.after, 2);
  });

  test('tawashih catalogue has playable archive urls', () {
    expect(tawashihMunshids, isNotEmpty);
    expect(tawashihTracks, isNotEmpty);
    final url = tawashihById('classic')!.urlFor(tawashihTracks.first);
    expect(url.host, 'archive.org');
  });

  test('comfort font is large Arabic reading size', () {
    expect(QuranPrefs.comfortFontSize, greaterThan(QuranPrefs.defaultFontSize));
    expect(QuranPrefs.comfortFontSize, lessThanOrEqualTo(QuranPrefs.maxFontSize));
  });

  Future<void> only(ExtraRemindersCubit cubit, Set<ExtraKind> kinds) async {
    for (final k in ExtraKind.values) {
      final want = kinds.contains(k);
      if (cubit.state.on.contains(k) != want) await cubit.setEnabled(k, want);
    }
  }

  test('tahajjud is last third of Maghrib→Fajr; duha after sunrise', () async {
    final now = DateTime.utc(2026, 10, 15, 9);
    final day = calc.today(cairo, now);
    final notifier = _FakeNotifier();
    final cubit = ExtraRemindersCubit(notifier: notifier, now: () => now);
    await only(cubit, {ExtraKind.tahajjud, ExtraKind.duha});
    await cubit.sync(day, 'en');

    final duha = notifier.scheduled
        .where((r) => r.id >= extraIdBase + 140 && r.id < extraIdBase + 160)
        .toList();
    expect(duha, isNotEmpty);
    // Noon Cairo: today's sunrise already passed → first duha is tomorrow.
    final sunrise = day.following.first.firstWhere((p) => p.name == 'Sunrise');
    // Cairo is UTC+3 in October.
    final expectedDuha = DateTime.utc(
      2026,
      10,
      16,
      sunrise.hour - 3,
      sunrise.minute,
    ).add(ExtraRemindersCubit.duhaAfterSunrise);
    expect(duha.first.at, expectedDuha);
    expect(duha.first.payload, 'prayer');

    final tahajjud = notifier.scheduled
        .where((r) => r.id >= extraIdBase + 160 && r.id < extraIdBase + 180)
        .toList();
    expect(tahajjud, isNotEmpty);
    final maghrib = day.prayers.firstWhere((p) => p.name == 'Maghrib');
    final fajr = day.following.first.firstWhere((p) => p.name == 'Fajr');
    final maghribAt = DateTime.utc(
      2026,
      10,
      15,
      maghrib.hour - 3,
      maghrib.minute,
    );
    final fajrAt = DateTime.utc(
      2026,
      10,
      16,
      fajr.hour - 3,
      fajr.minute,
    );
    final night = fajrAt.difference(maghribAt);
    final expected = maghribAt.add(
      Duration(seconds: (night.inSeconds * 2 / 3).round()),
    );
    expect(tahajjud.first.at, expected);
    expect(tahajjud.first.payload, startsWith('ayah:'));
  });
}
