import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim/bloc/settings_cubit.dart';
import 'package:muslim/data.dart';
import 'package:muslim/l10n/l10n.dart';
import 'package:muslim/main.dart';
import 'package:muslim/services/islamic_api.dart';

import 'helpers.dart';

Map<String, dynamic> _payload({String offset = '+03:00'}) => {
  'times': {
    'Fajr': '05:28',
    'Sunrise': '06:54',
    'Dhuhr': '12:42',
    'Asr': '16:01',
    'Maghrib': '18:29',
    'Isha': '19:46',
  },
  'date': {
    'hijri': {
      'day': '30',
      'year': '1448',
      'month': {'en': 'Rabi al-Thani', 'ar': 'رَبِيع ٱلثَّانِي'},
    },
  },
  'qibla': {
    'direction': {'degrees': 136.14},
    'distance': {'value': 1287.22},
  },
  'timezone': {'name': 'Africa/Cairo', 'utc_offset': offset},
};

/// Never resolves, so screens stay in their loading state without network.
class _OfflineApi extends IslamicApi {
  _OfflineApi() : super(apiKey: 'test');

  @override
  Future<PrayerDay> fetchToday(Place place) async =>
      PrayerDay.fromJson(_payload());

  @override
  Future<FastingDay> fetchFasting(Place place, {DateTime? today}) =>
      Future.error(const ApiException(ApiException.network));

  @override
  Future<Nisab> fetchNisab({
    required NisabStandard standard,
    required String currency,
  }) => Future.error(const ApiException(ApiException.network));

  @override
  Future<NamesBook> fetchNames(String language) =>
      Future.error(const ApiException(ApiException.network));

  @override
  Future<Dua> fetchDua(String lang, {int? id}) =>
      Future.error(const ApiException(ApiException.network));
}

void main() {
  test('parses 24h and 12h API times', () {
    final a = Prayer.parse('Asr', 'العصر', '16:01');
    expect([a.hour, a.minute, a.time, a.period], [16, 1, '4:01', 'pm']);

    final b = Prayer.parse('Fajr', 'الفجر', '4:55 AM');
    expect([b.hour, b.minute], [4, 55]);

    final c = Prayer.parse('Dhuhr', 'الظهر', '12:13 PM');
    expect(c.hour, 12);
  });

  test('parses API day payload', () {
    final day = PrayerDay.fromJson(_payload());

    expect(day.prayers.map((p) => p.name), [
      'Fajr',
      'Sunrise',
      'Dhuhr',
      'Asr',
      'Maghrib',
      'Isha',
    ]);
    expect(day.city, 'Cairo');
    expect(day.hijriAr, '٣٠ رَبِيع ٱلثَّانِي ١٤٤٨');
    expect(day.hijriEn, '30 Rabi al-Thani 1448 AH');
    expect(day.qiblaDegrees, 136.14);
    expect(day.utcOffset, const Duration(hours: 3));
  });

  test('city clock uses the API offset, not the device zone', () {
    final day = PrayerDay.fromJson(_payload(offset: '-04:30'));
    final now = DateTime.utc(2026, 10, 11, 12);
    expect(day.cityNow(now), DateTime(2026, 10, 11, 7, 30));
  });

  test('upcoming prayer wraps to tomorrow after Isha', () {
    final prayers = PrayerDay.fromJson(_payload()).prayers;

    final midday = upcoming(prayers, DateTime(2026, 10, 11, 13));
    expect(midday.next.name, 'Asr');
    expect(midday.since, DateTime(2026, 10, 11, 12, 42));

    final night = upcoming(prayers, DateTime(2026, 10, 11, 23));
    expect(night.next.name, 'Fajr');
    expect(night.at, DateTime(2026, 10, 12, 5, 28));
    expect(night.since, DateTime(2026, 10, 11, 19, 46));
  });

  test('Arabic digits keep number separators', () {
    expect(arabicDigits('12,345.50 EGP'), '١٢٬٣٤٥٫٥٠ EGP');
    expect(arabicDigits('Fajr, then 5.'), 'Fajr, then ٥.');
  });

  test('surah index is complete', () {
    expect(surahs.length, 114);
    expect(
      [for (final s in surahs) s.number],
      [for (var i = 1; i <= 114; i++) i],
    );
    expect(surahs.fold<int>(0, (n, s) => n + s.ayahs), 6236);
  });

  group('app', () {
    setUp(() {
      GoogleFonts.config.allowRuntimeFetching = false;
    });

    Future<void> pumpApp(WidgetTester tester, String lang) async {
      useMemoryStorage();
      SettingsCubit().setLanguage(lang);
      await tester.pumpWidget(MuslimApp(api: _OfflineApi()));
      await tester.pump();
      await tester.pump();
    }

    testWidgets('English UI is left-to-right with English labels', (
      tester,
    ) async {
      await pumpApp(tester, 'en');
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Qibla'), findsWidgets);
      expect(find.text('الرئيسية'), findsNothing);
      final dir = Directionality.of(tester.element(find.byType(Shell)));
      expect(dir, TextDirection.ltr);
    });

    testWidgets('Arabic UI is right-to-left with no English labels', (
      tester,
    ) async {
      await pumpApp(tester, 'ar');
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
      expect(find.text('Next prayer'), findsNothing);
      final dir = Directionality.of(tester.element(find.byType(Shell)));
      expect(dir, TextDirection.rtl);
    });
  });
}
