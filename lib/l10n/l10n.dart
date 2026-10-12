import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../data.dart';
import '../services/islamic_api.dart';
import '../services/quran.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

const supportedLanguages = {'en': 'English', 'ar': 'العربية'};

extension L10nX on BuildContext {
  L10n get l => L10n.of(this);

  String get lang => Localizations.localeOf(this).languageCode;

  bool get isAr => lang == 'ar';

  /// Number (or text containing numbers) in the UI's digits.
  String n(Object v) => isAr ? arabicDigits('$v') : '$v';

  String prayerName(String key, {DateTime? day}) => switch (key) {
    'Fajr' => l.fajr,
    'Sunrise' => l.sunrise,
    'Dhuhr' when day?.weekday == DateTime.friday => l.jumuah,
    'Dhuhr' => l.dhuhr,
    'Asr' => l.asr,
    'Maghrib' => l.maghrib,
    'Isha' => l.isha,
    'Sahur' => l.sahurEnds,
    'Iftar' => l.iftar,
    _ => key,
  };

  String clock(Prayer p) => n(p.time);

  String period(Prayer p) => p.hour < 12 ? l.am : l.pm;

  String duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return h > 0
        ? l.hoursMinutes(n(h), n(m))
        : l.minutesOnly(n(m == 0 && d > Duration.zero ? 1 : m));
  }

  String error(String? code) => switch (code) {
    ApiException.missingKey => l.errMissingKey,
    ApiException.network => l.errNetwork,
    null || '' || ApiException.badResponse => l.errGeneric,
    // Server messages are English-only.
    final message => isAr ? l.errGeneric : message,
  };

  String date(DateTime d, String pattern) =>
      n(DateFormat(pattern, lang).format(d));

  String hijri(PrayerDay day) => isAr
      ? '${day.hijriAr} ${l.hijriSuffix}'
      : day.hijriMonthEn.isEmpty
      ? ''
      : day.hijriEn;

  String mushafName(Mushaf m) => switch (m) {
    Mushaf.uthmani => l.mushafUthmani,
    Mushaf.tajweed => l.mushafTajweed,
    Mushaf.simple => l.mushafSimple,
    Mushaf.plain => l.mushafPlain,
  };

  String mushafDetail(Mushaf m) => switch (m) {
    Mushaf.uthmani => l.mushafUthmaniSub,
    Mushaf.tajweed => l.mushafTajweedSub,
    Mushaf.simple => l.mushafSimpleSub,
    Mushaf.plain => l.mushafPlainSub,
  };

  String tafsirName(TafsirSource s) => switch (s) {
    TafsirSource.muyassar => l.tafsirMuyassar,
    TafsirSource.jalalayn => l.tafsirJalalayn,
    TafsirSource.baghawi => l.tafsirBaghawi,
    TafsirSource.qurtubi => l.tafsirQurtubi,
    TafsirSource.waseet => l.tafsirWaseet,
    TafsirSource.ibnKathir => l.tafsirIbnKathir,
    TafsirSource.saheeh => l.tafsirSaheeh,
  };

  String surahName(Surah s) => isAr ? 'سورة ${s.arabic}' : s.name;

  String currencyName(String code) => switch (code) {
    'EGP' => l.curEGP,
    'SAR' => l.curSAR,
    'AED' => l.curAED,
    'KWD' => l.curKWD,
    'QAR' => l.curQAR,
    'JOD' => l.curJOD,
    'MAD' => l.curMAD,
    'TRY' => l.curTRY,
    'PKR' => l.curPKR,
    'INR' => l.curINR,
    'BDT' => l.curBDT,
    'IDR' => l.curIDR,
    'MYR' => l.curMYR,
    'USD' => l.curUSD,
    'EUR' => l.curEUR,
    'GBP' => l.curGBP,
    'CAD' => l.curCAD,
    'AUD' => l.curAUD,
    _ => code,
  };
}

/// Western → Arabic-Indic digits, with Arabic separators inside numbers.
String arabicDigits(String s) => s
    .replaceAllMapped(
      RegExp(r'(?<=\d)[.,](?=\d)'),
      (m) => m[0] == '.' ? '٫' : '٬',
    )
    .replaceAllMapped(
      RegExp(r'\d'),
      (m) => String.fromCharCode(0x0660 + m[0]!.codeUnitAt(0) - 48),
    );
