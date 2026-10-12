import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/data.dart';
import 'package:muslim/services/islamic_api.dart';
import 'package:muslim/services/islamic_events.dart';
import 'package:muslim/services/places.dart';
import 'package:muslim/services/prayer_calc.dart';

int _minutes(Prayer p) => p.hour * 60 + p.minute;

void main() {
  const calc = PrayerCalculator();
  final noonUtc = DateTime.utc(2026, 10, 12, 10);

  test('Cairo times in city wall-clock, with a week ahead', () {
    final day = calc.today(cityById('cairo').place, noonUtc);
    expect(day.prayers.map((p) => p.name), [
      'Fajr',
      'Sunrise',
      'Dhuhr',
      'Asr',
      'Maghrib',
      'Isha',
    ]);
    final [fajr, sunrise, dhuhr, asr, maghrib, isha] = day.prayers;
    // Egypt keeps daylight saving time until late October.
    expect(fajr.hour, 5);
    expect(sunrise.hour, 6);
    expect(dhuhr.hour, 12);
    expect(asr.hour, 15);
    expect(maghrib.hour, 18);
    expect(isha.hour, 19);
    expect(day.following, hasLength(6));
    expect(day.utcOffset, const Duration(hours: 3));
    expect(day.qiblaDegrees, closeTo(136.1, .3));
    expect(day.qiblaKm, closeTo(1287, 5));
  });

  test('Hanafi Asr is later; offsets shift times', () {
    const shafi = Place(30.0444, 31.2357, tz: 'Africa/Cairo');
    const hanafi = Place(30.0444, 31.2357, school: 2, tz: 'Africa/Cairo');
    const shifted = Place(
      30.0444,
      31.2357,
      tz: 'Africa/Cairo',
      offsets: [2, 0, 0, 0, -3, 0],
    );
    final a = calc.today(shafi, noonUtc).prayers;
    final b = calc.today(hanafi, noonUtc).prayers;
    final c = calc.today(shifted, noonUtc).prayers;
    expect(_minutes(b[3]) - _minutes(a[3]), greaterThan(30));
    expect(_minutes(c[0]) - _minutes(a[0]), 2);
    expect(_minutes(c[4]) - _minutes(a[4]), -3);
  });

  test('Umm al-Qura Isha is 90 min after Maghrib, 120 in Ramadan', () {
    final place = cityById('makkah').place;
    final normal = calc.times(place, DateTime(2026, 10, 12));
    expect(_minutes(normal[5]) - _minutes(normal[4]), 90);
    // 1 Ramadan 1448 ≈ 9 Feb 2027.
    final ramadan = calc.times(place, DateTime(2027, 2, 15));
    expect(_minutes(ramadan[5]) - _minutes(ramadan[4]), 120);
  });

  test('Hijri date follows Umm al-Qura and the user shift', () {
    final day = calc.today(cityById('cairo').place, noonUtc);
    final h = HijriDate.of(DateTime(2026, 10, 12));
    expect(
      (day.hijriYear, day.hijriMonth, day.hijriDay),
      (h.year, h.month, h.day),
    );
    expect(day.hijriYear, 1448);
    expect(day.hijriMonthEn, hijriMonthsEn[day.hijriMonth - 1]);

    const shifted = Place(30.0444, 31.2357, tz: 'Africa/Cairo', hijriShift: 1);
    final next = calc.today(shifted, noonUtc);
    expect(next.hijriDay == day.hijriDay + 1 || next.hijriDay == 1, isTrue);
  });

  test('every method gives ordered times', () {
    for (final m in calcMethods) {
      final place = Place(30.0444, 31.2357, method: m.id, tz: 'Africa/Cairo');
      final list = calc
          .times(place, DateTime(2026, 10, 12))
          .map(_minutes)
          .toList();
      for (var i = 1; i < list.length; i++) {
        expect(list[i], greaterThan(list[i - 1]), reason: m.nameEn);
      }
    }
  });

  test('Hijri round-trips and upcoming events are in order', () {
    final h = HijriDate.of(DateTime(2026, 10, 12));
    expect(h.toGregorian(), DateTime(2026, 10, 12));
    expect(
      HijriDate.of(DateTime(2026, 10, 12), shift: 1).toGregorian(shift: 1),
      DateTime(2026, 10, 12),
    );
    expect(h.addMonths(12 - h.month + 1), HijriDate(h.year + 1, 1, 1));

    final next = upcomingEvents(DateTime(2026, 10, 12));
    expect(next, isNotEmpty);
    for (var i = 1; i < next.length; i++) {
      expect(next[i].$3.isBefore(next[i - 1].$3), isFalse);
    }
    final ramadan = next.firstWhere((e) => e.$1 == IslamicEvent.ramadan);
    expect(HijriDate.of(ramadan.$3), HijriDate(ramadan.$2.year, 9, 1));
  });
}
