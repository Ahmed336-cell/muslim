import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/data.dart';
import 'package:muslim/services/hisn.dart';
import 'package:muslim/services/home_widgets.dart';
import 'package:muslim/services/islamic_api.dart';
import 'package:muslim/services/quran_text.dart';

class _MemoryStore implements WidgetStore {
  final saved = <String, String>{};
  var refreshes = 0;

  @override
  Future<void> save(String key, String json) async => saved[key] = json;

  @override
  Future<void> refresh() async => refreshes++;
}

PrayerDay _day({Duration? offset}) => PrayerDay(
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
  hijriMonthAr: '',
  hijriMonthEn: '',
  hijriYear: 1448,
  qiblaDegrees: 0,
  qiblaKm: 0,
  utcOffset: offset,
);

final PrayerFormat _format = (
  name: (p, d) => p.name,
  clock: (p) => p.time,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('prayer data', () {
    test('a week of absolute times in the city timezone', () {
      // 10:00 UTC is 13:00 in a UTC+3 city.
      final now = DateTime.utc(2026, 10, 12, 10);
      final data = prayerWidgetData(
        _day(offset: const Duration(hours: 3)),
        now,
        _format,
      );
      final times = data['times']! as List;
      expect(times, hasLength(42));
      expect(data['perDay'], 6);
      final asr = times[3] as Map;
      expect(asr['n'], 'Asr');
      expect(asr['c'], '3:30');
      expect(
        DateTime.fromMillisecondsSinceEpoch(asr['t'] as int, isUtc: true),
        DateTime.utc(2026, 10, 12, 12, 30),
      );
      final tomorrowFajr = times[6] as Map;
      expect(
        DateTime.fromMillisecondsSinceEpoch(tomorrowFajr['t'] as int, isUtc: true),
        DateTime.utc(2026, 10, 13, 2),
      );
    });

    test('without an offset uses device time', () {
      final now = DateTime(2026, 10, 12, 8);
      final times = prayerWidgetData(_day(), now, _format)['times']! as List;
      expect(
        (times[2] as Map)['t'],
        DateTime(2026, 10, 12, 12).millisecondsSinceEpoch,
      );
    });
  });

  test('ayahs are short, clean and referenced', () async {
    final ayahs = await ayahWidgetData(
      QuranText(),
      lang: 'en',
      digits: (n) => '$n',
      random: Random(1),
      count: 20,
    );
    expect(ayahs, hasLength(20));
    for (final a in ayahs) {
      expect(a['t']!.length, inInclusiveRange(20, 150));
      expect(a['t'], isNot(contains('۞')));
      expect(a['r'], matches(RegExp(r'^.+ · \d+$')));
    }
  });

  test('duas and names', () async {
    final book = await HisnRepository().load();
    final duas = duaWidgetData(book, lang: 'en', random: Random(2));
    expect(duas, hasLength(48));
    expect(duas.every((d) => !d['t']!.startsWith('(')), isTrue);
    expect(duas.every((d) => !d['t']!.contains('[')), isTrue);
    expect(duaWidgetData(book, lang: 'ar').every((d) => d['s'] == null), isTrue);

    final names = nameWidgetData(
      const NamesBook(
        language: 'ar',
        title: '',
        hadith: '',
        names: [
          DivineName(
            number: 1,
            arabic: 'الرَّحْمَنُ',
            transliteration: 'الرحمن',
            translation: 'الرحمن',
            meaning: 'كثير الرحمة. وهو اسم مختص بالله',
          ),
        ],
      ),
    );
    expect(names.single['s'], 'كثير الرحمة');
  });

  test('only changed data is written', () async {
    final store = _MemoryStore();
    final widgets = HomeWidgets(store: store);
    await widgets.update({
      'a': {'x': 1},
      'b': null,
    });
    expect(store.saved.keys, ['a']);
    expect(jsonDecode(store.saved['a']!), {'x': 1});
    expect(store.refreshes, 1);
    await widgets.update({
      'a': {'x': 1},
    });
    expect(store.refreshes, 1);
    await widgets.update({
      'a': {'x': 2},
    });
    expect(store.refreshes, 2);
  });
}
