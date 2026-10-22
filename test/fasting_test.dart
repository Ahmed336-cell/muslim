import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/bloc/fasting/fasting_bloc.dart';
import 'package:muslim/services/islamic_api.dart';
import 'package:muslim/services/islamic_events.dart';
import 'package:muslim/services/places.dart';
import 'package:muslim/services/prayer_calc.dart';

Map<String, dynamic> _payload({
  String sahur = '05:28',
  String iftar = '18:29',
  String hijri = '1448-04-30',
  Map<String, String> white = const {
    '13th': '2026-09-24',
    '14th': '2026-09-25',
    '15th': '2026-09-26',
  },
}) => {
  'fasting': [
    {
      'date': '2026-10-11',
      'hijri': hijri,
      'time': {'sahur': sahur, 'iftar': iftar},
    },
  ],
  'white_days': {'status': 'next_month', 'days': white},
};

void main() {
  final today = DateTime(2026, 10, 11);
  const calc = PrayerCalculator();
  final cairo = cityById('cairo').place;

  test('parses times and duration', () {
    final f = FastingDay.fromJson(_payload(), today: today);
    expect([f.sahur.hour, f.sahur.minute], [5, 28]);
    expect([f.iftar.hour, f.iftar.minute], [18, 29]);
    expect(f.duration, const Duration(hours: 13, minutes: 1));
  });

  test('accepts 12h times', () {
    final f = FastingDay.fromJson(
      _payload(sahur: '4:04 AM', iftar: '6:53 PM'),
      today: today,
    );
    expect(f.duration, const Duration(hours: 14, minutes: 49));
  });

  test('uses upcoming API white days as-is', () {
    final f = FastingDay.fromJson(
      _payload(
        white: const {
          '13th': '2026-10-24',
          '14th': '2026-10-25',
          '15th': '2026-10-26',
        },
      ),
      today: today,
    );
    expect(f.whiteDaysEstimated, isFalse);
    expect(f.whiteDays.first, DateTime(2026, 10, 24));
  });

  test('estimates white days when API returns past dates', () {
    final f = FastingDay.fromJson(_payload(), today: today);
    expect(f.whiteDaysEstimated, isTrue);
    // 30th of the month → 13th of next is 13 days away.
    expect(f.whiteDays, [
      DateTime(2026, 10, 24),
      DateTime(2026, 10, 25),
      DateTime(2026, 10, 26),
    ]);
  });

  test('mid white days keeps the current set', () {
    final f = FastingDay.fromJson(_payload(hijri: '1448-05-14'), today: today);
    expect(f.whiteDays.first, DateTime(2026, 10, 10));
  });

  test('local white days match Umm al-Qura 13–15', () {
    final days = upcomingWhiteDays(DateTime(2026, 10, 11));
    expect(days, hasLength(3));
    expect(days[1].difference(days[0]).inDays, 1);
    expect(days[2].difference(days[1]).inDays, 1);
    for (final d in days) {
      expect(HijriDate.of(d).day, inInclusiveRange(13, 15));
    }
  });

  test('local fasting matches Fajr / Maghrib', () {
    final now = DateTime.utc(2026, 10, 15, 9);
    final prayer = calc.today(cairo, now);
    final fajr = prayer.prayers.firstWhere((p) => p.name == 'Fajr');
    final maghrib = prayer.prayers.firstWhere((p) => p.name == 'Maghrib');
    final f = FastingDay.local(
      fajr: fajr,
      maghrib: maghrib,
      whiteDays: upcomingWhiteDays(prayer.cityNow(now)),
    );
    expect(f.sahur.hour, fajr.hour);
    expect(f.sahur.minute, fajr.minute);
    expect(f.iftar.hour, maghrib.hour);
    expect(f.iftar.minute, maghrib.minute);
    expect(f.whiteDays, hasLength(3));
  });

  blocTest<FastingBloc, FastingState>(
    'loads from on-device prayer times',
    build: () => FastingBloc(
      place: cairo,
      clock: () => DateTime.utc(2026, 10, 15, 9),
    ),
    act: (b) => b.add(const FastingRequested()),
    verify: (b) {
      expect(b.state.status, FastingStatus.success);
      expect(b.state.day, isNotNull);
      expect(b.state.day!.sahur.name, 'Sahur');
      expect(b.state.day!.iftar.name, 'Iftar');
      expect(b.state.day!.whiteDays, hasLength(3));
    },
  );
}
