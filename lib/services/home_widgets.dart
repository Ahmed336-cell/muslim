import 'dart:convert';
import 'dart:math';

import 'package:home_widget/home_widget.dart';

import '../data.dart';
import 'hisn.dart';
import 'islamic_api.dart' show PrayerDay;
import 'names.dart';
import 'quran.dart';
import 'quran_text.dart';

/// Keys shared with the native widgets in ios/MuslimWidgets and
/// android/app/src/main/kotlin/com/example/muslim/widgets.
abstract final class WidgetKeys {
  static const appGroup = 'group.com.example.muslim';
  static const prayer = 'prayer';
  static const ayahs = 'ayahs';
  static const duas = 'duas';
  static const names = 'names';
  static const labels = 'labels';

  /// iOS widget kinds and Android provider classes share these names.
  static const kinds = ['PrayerWidget', 'AyahWidget', 'DuaWidget', 'NameWidget'];
}

/// How the app formats a prayer for display.
typedef PrayerFormat = ({
  String Function(Prayer p, DateTime day) name,
  String Function(Prayer p) clock,
});

/// Prayer times as absolute instants, so the widgets can count down and roll
/// over to the next prayer while the app is closed. Later days repeat today's
/// times; they drift by a minute or two until the app refreshes them.
Map<String, Object?> prayerWidgetData(
  PrayerDay day,
  DateTime now,
  PrayerFormat format, {
  int days = 7,
}) {
  final offset = day.utcOffset;
  final today = day.cityNow(now);
  return {
    'city': day.city,
    'perDay': day.prayers.length,
    'times': [
      for (var d = 0; d < days; d++)
        for (final p in day.prayers)
          () {
            final date = DateTime(today.year, today.month, today.day + d);
            final at = offset == null
                ? p.on(date)
                : DateTime.utc(
                    date.year,
                    date.month,
                    date.day,
                    p.hour,
                    p.minute,
                  ).subtract(offset);
            return {
              'n': format.name(p, date),
              'c': format.clock(p),
              't': at.millisecondsSinceEpoch,
            };
          }(),
    ],
  };
}

/// Short ayahs that fit a widget, in the plain script system fonts render.
Future<List<Map<String, String>>> ayahWidgetData(
  QuranText text, {
  required String lang,
  required String Function(int) digits,
  Random? random,
  int count = 48,
}) async {
  final rnd = random ?? Random();
  final picked = <Map<String, String>>[];
  final seen = <(int, int)>{};
  for (var tries = 0; picked.length < count && tries < count * 20; tries++) {
    final surah = surahs[rnd.nextInt(surahs.length)];
    final n = 1 + rnd.nextInt(surah.ayahs);
    if (!seen.add((surah.number, n))) continue;
    final ayah = await text.ayah(surah.number, n, Mushaf.simple);
    if (ayah.text.length < 25 || ayah.text.length > 150) continue;
    final name = lang == 'ar' ? surah.arabic : surah.name;
    picked.add({'t': _clean(ayah.text), 'r': '$name · ${digits(n)}'});
  }
  return picked;
}

/// Short duas from Hisn al-Muslim, with the translation in English.
List<Map<String, String>> duaWidgetData(
  HisnBook book, {
  required String lang,
  Random? random,
  int count = 48,
}) {
  final all = [
    for (final c in book.chapters)
      for (final d in c.items)
        if (d.arabic.length <= 170)
          {
            't': _clean(d.arabic),
            if (lang != 'ar' &&
                d.translation.isNotEmpty &&
                d.translation.length <= 160)
              's': d.translation,
            'r': c.title(lang),
          },
  ]..shuffle(random ?? Random());
  return all.take(count).toList();
}

List<Map<String, String>> nameWidgetData(NamesBook book, {Random? random}) => [
  for (final n in book.names)
    {'t': n.arabic, 'n': n.transliteration, 's': _nameGloss(n)},
]..shuffle(random ?? Random());

/// The Arabic book gives the bare name as its translation; fall back to the
/// first sentence of the meaning there.
String _nameGloss(DivineName n) {
  final bare = normalizeArabic(n.arabic);
  if (n.translation.isNotEmpty && normalizeArabic(n.translation) != bare) {
    return n.translation;
  }
  final first = n.meaning.split(RegExp(r'[.،؛\n]')).first.trim();
  return first.length <= 90 && normalizeArabic(first) != bare ? first : '';
}

/// Drops marks that only make sense on a mushaf page, and wrapping brackets.
String _clean(String s) {
  var t = s.replaceAll(RegExp('[۞۩\\[\\]]'), '').trim();
  if (t.startsWith('(') && t.endsWith(').')) t = t.substring(1, t.length - 2);
  if (t.startsWith('(') && t.endsWith(')')) t = t.substring(1, t.length - 1);
  return t.trim();
}

/// Where widget data is written; faked in tests.
abstract class WidgetStore {
  Future<void> save(String key, String json);
  Future<void> refresh();
}

class HomeWidgetStore implements WidgetStore {
  HomeWidgetStore() {
    HomeWidget.setAppGroupId(WidgetKeys.appGroup).catchError((_) => null);
  }

  @override
  Future<void> save(String key, String json) async {
    try {
      await HomeWidget.saveWidgetData<String>(key, json);
    } catch (_) {
      // No widget support on this platform.
    }
  }

  @override
  Future<void> refresh() async {
    for (final kind in WidgetKeys.kinds) {
      try {
        await HomeWidget.updateWidget(
          iOSName: kind,
          qualifiedAndroidName: 'com.example.muslim.widgets.$kind',
        );
      } catch (_) {}
    }
  }
}

/// Writes only what changed, then asks the widgets to redraw.
class HomeWidgets {
  HomeWidgets({WidgetStore? store}) : _store = store ?? HomeWidgetStore();

  final WidgetStore _store;
  final _last = <String, String>{};

  Future<void> update(Map<String, Object?> values) async {
    var changed = false;
    for (final MapEntry(:key, :value) in values.entries) {
      if (value == null) continue;
      final json = jsonEncode(value);
      if (_last[key] == json) continue;
      _last[key] = json;
      await _store.save(key, json);
      changed = true;
    }
    if (changed) await _store.refresh();
  }
}
