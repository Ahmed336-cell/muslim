import 'dart:math' as math;

import 'package:adhan/adhan.dart' as adhan;
import 'package:hijri/hijri_calendar.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data.dart';
import 'islamic_api.dart';

/// A calculation method; ids follow aladhan / islamicapi.com.
class CalcMethod {
  const CalcMethod(this.id, this.nameEn, this.nameAr);

  final int id;
  final String nameEn;
  final String nameAr;

  String name(bool arabic) => arabic ? nameAr : nameEn;
}

const calcMethods = [
  CalcMethod(3, 'Muslim World League', 'رابطة العالم الإسلامي'),
  CalcMethod(
    5,
    'Egyptian General Authority of Survey',
    'الهيئة المصرية العامة للمساحة',
  ),
  CalcMethod(4, 'Umm al-Qura, Makkah', 'أم القرى، مكة المكرمة'),
  CalcMethod(
    1,
    'University of Islamic Sciences, Karachi',
    'جامعة العلوم الإسلامية، كراتشي',
  ),
  CalcMethod(2, 'ISNA, North America', 'الجمعية الإسلامية لأمريكا الشمالية'),
  CalcMethod(15, 'Moonsighting Committee', 'لجنة رؤية الهلال'),
  CalcMethod(16, 'Dubai', 'دبي'),
  CalcMethod(9, 'Kuwait', 'الكويت'),
  CalcMethod(10, 'Qatar', 'قطر'),
  CalcMethod(23, 'Jordan', 'الأردن'),
  CalcMethod(21, 'Morocco', 'المغرب'),
  CalcMethod(13, 'Diyanet, Turkey', 'رئاسة الشؤون الدينية، تركيا'),
  CalcMethod(11, 'Singapore', 'سنغافورة'),
  CalcMethod(17, 'JAKIM, Malaysia', 'جاكيم، ماليزيا'),
  CalcMethod(20, 'Kemenag, Indonesia', 'وزارة الشؤون الدينية، إندونيسيا'),
  CalcMethod(7, 'Institute of Geophysics, Tehran', 'معهد الجيوفيزياء، طهران'),
];

CalcMethod calcMethodById(int id) =>
    calcMethods.firstWhere((m) => m.id == id, orElse: () => calcMethods.first);

const hijriMonthsEn = [
  'Muharram',
  'Safar',
  'Rabi al-Awwal',
  'Rabi al-Thani',
  'Jumada al-Ula',
  'Jumada al-Akhirah',
  'Rajab',
  "Sha'ban",
  'Ramadan',
  'Shawwal',
  "Dhu al-Qa'dah",
  'Dhu al-Hijjah',
];

const hijriMonthsAr = [
  'مُحَرَّم',
  'صَفَر',
  'رَبِيع الأَوَّل',
  'رَبِيع الآخِر',
  'جُمَادَى الأُولَى',
  'جُمَادَى الآخِرَة',
  'رَجَب',
  'شَعْبَان',
  'رَمَضَان',
  'شَوَّال',
  'ذُو القَعْدَة',
  'ذُو الحِجَّة',
];

/// A day of the Hijri (Umm al-Qura) calendar.
class HijriDate {
  const HijriDate(this.year, this.month, this.day);

  /// [shift] moves the date for places that follow local moon sighting.
  factory HijriDate.of(DateTime date, {int shift = 0}) {
    final h = HijriCalendar.fromDate(
      DateTime(date.year, date.month, date.day + shift),
    );
    return HijriDate(h.hYear, h.hMonth, h.hDay);
  }

  final int year;
  final int month;
  final int day;

  /// Days in this month by the Umm al-Qura tables.
  int get monthLength => HijriCalendar().getDaysInMonth(year, month);

  /// The civil date of this day; [shift] as in [HijriDate.of].
  DateTime toGregorian({int shift = 0}) {
    final g = HijriCalendar().hijriToGregorian(year, month, day);
    return DateTime(g.year, g.month, g.day - shift);
  }

  /// The first day of the month [months] after this one.
  HijriDate addMonths(int months) {
    final m = year * 12 + month - 1 + months;
    return HijriDate(m ~/ 12, m % 12 + 1, 1);
  }

  @override
  bool operator ==(Object other) =>
      other is HijriDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);
}

/// Prayer times computed on the device: no network, no quota.
class PrayerCalculator {
  const PrayerCalculator();

  static var _tzReady = false;

  static const _names = {
    'Fajr': 'الفجر',
    'Sunrise': 'الشروق',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
  };

  /// Today's times at [place], plus the following week for widgets and
  /// reminders.
  PrayerDay today(Place place, DateTime now, {int days = 7}) {
    final location = _location(place.tz);
    final utcOffset = location?.timeZone(now.millisecondsSinceEpoch).offset;
    final today = _wallClock(now, location);
    final hijri = HijriDate.of(today, shift: place.hijriShift);

    List<Prayer> on(int d) => times(
      place,
      DateTime(today.year, today.month, today.day + d),
      location,
    );

    return PrayerDay(
      prayers: on(0),
      following: [for (var d = 1; d < days; d++) on(d)],
      city: '',
      hijriDay: hijri.day,
      hijriMonthAr: hijriMonthsAr[hijri.month - 1],
      hijriMonthEn: hijriMonthsEn[hijri.month - 1],
      hijriYear: hijri.year,
      hijriMonth: hijri.month,
      qiblaDegrees: adhan.Qibla(
        adhan.Coordinates(place.lat, place.lon),
      ).direction,
      qiblaKm: distanceToKaabaKm(place.lat, place.lon),
      utcOffset: utcOffset,
    );
  }

  /// Wall-clock times on [date] in the place's timezone (or the device's).
  List<Prayer> times(Place place, DateTime date, [tz.Location? location]) {
    location ??= _location(place.tz);
    final params = _params(place, date);
    final t = adhan.PrayerTimes.utc(
      adhan.Coordinates(place.lat, place.lon),
      adhan.DateComponents(date.year, date.month, date.day),
      params,
    );
    final all = [t.fajr, t.sunrise, t.dhuhr, t.asr, t.maghrib, t.isha];
    return [
      for (final (i, name) in _names.keys.indexed)
        () {
          final local = _wallClock(all[i], location);
          return Prayer(name, _names[name]!, local.hour, local.minute);
        }(),
    ];
  }

  adhan.CalculationParameters _params(Place place, DateTime date) {
    final params = switch (place.method) {
      1 => adhan.CalculationMethod.karachi.getParameters(),
      2 => adhan.CalculationMethod.north_america.getParameters(),
      4 => adhan.CalculationMethod.umm_al_qura.getParameters(),
      5 => adhan.CalculationMethod.egyptian.getParameters(),
      7 => adhan.CalculationMethod.tehran.getParameters(),
      9 => adhan.CalculationMethod.kuwait.getParameters(),
      10 => adhan.CalculationMethod.qatar.getParameters(),
      11 || 17 || 20 => adhan.CalculationMethod.singapore.getParameters(),
      13 => adhan.CalculationMethod.turkey.getParameters(),
      15 => adhan.CalculationMethod.moon_sighting_committee.getParameters(),
      16 => adhan.CalculationMethod.dubai.getParameters(),
      21 => adhan.CalculationParameters(
        fajrAngle: 19,
        ishaAngle: 17,
      )..methodAdjustments = adhan.PrayerAdjustments(maghrib: 5),
      23 => adhan.CalculationParameters(
        fajrAngle: 18,
        ishaAngle: 18,
      )..methodAdjustments = adhan.PrayerAdjustments(maghrib: 5),
      _ => adhan.CalculationMethod.muslim_world_league.getParameters(),
    };
    // Umm al-Qura gives Isha two hours after Maghrib in Ramadan.
    if (place.method == 4 &&
        HijriDate.of(date, shift: place.hijriShift).month == 9) {
      params.ishaInterval = 120;
    }
    params.madhab = place.school == 2
        ? adhan.Madhab.hanafi
        : adhan.Madhab.shafi;
    params.highLatitudeRule = place.lat.abs() > 48
        ? adhan.HighLatitudeRule.seventh_of_the_night
        : adhan.HighLatitudeRule.middle_of_the_night;
    final o = place.offsets;
    params.adjustments = adhan.PrayerAdjustments(
      fajr: o[0],
      sunrise: o[1],
      dhuhr: o[2],
      asr: o[3],
      maghrib: o[4],
      isha: o[5],
    );
    return params;
  }

  static tz.Location? _location(String? name) {
    if (name == null) return null;
    if (!_tzReady) {
      tzdata.initializeTimeZones();
      _tzReady = true;
    }
    try {
      return tz.getLocation(name);
    } catch (_) {
      return null;
    }
  }

  static DateTime _wallClock(DateTime instant, tz.Location? location) {
    if (location == null) return instant.toLocal();
    final t = tz.TZDateTime.from(instant, location);
    return DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second);
  }
}

double distanceToKaabaKm(double lat, double lon) {
  const kaaba = (21.4225241, 39.8261818);
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(kaaba.$1 - lat), dLon = rad(kaaba.$2 - lon);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat)) *
          math.cos(rad(kaaba.$1)) *
          math.pow(math.sin(dLon / 2), 2);
  return 6371 * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}
