import 'dart:convert';

import 'package:flutter/foundation.dart' show compute, listEquals;

import 'package:http/http.dart' as http;

import '../data.dart';
import 'duas.dart';
import 'names.dart';
import 'nisab.dart';
import 'ruqyah.dart';

export 'duas.dart';
export 'names.dart';
export 'nisab.dart';
export 'ruqyah.dart';

class Place {
  const Place(
    this.lat,
    this.lon, {
    this.method = 5,
    this.school = 1,
    this.tz,
    this.offsets = noOffsets,
    this.hijriShift = 0,
  });

  static const noOffsets = [0, 0, 0, 0, 0, 0];

  final double lat;
  final double lon;

  /// See islamicapi.com docs: 5 = Egyptian General Authority of Survey.
  final int method;

  /// 1 = Shafi, 2 = Hanafi (affects Asr).
  final int school;

  /// IANA timezone, e.g. 'Africa/Cairo'; null = the device's.
  final String? tz;

  /// Minutes added to Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha.
  final List<int> offsets;

  /// Days added to the Hijri date for local moon sighting.
  final int hijriShift;

  @override
  bool operator ==(Object other) =>
      other is Place &&
      other.lat == lat &&
      other.lon == lon &&
      other.method == method &&
      other.school == school &&
      other.tz == tz &&
      listEquals(other.offsets, offsets) &&
      other.hijriShift == hijriShift;

  @override
  int get hashCode => Object.hash(
    lat,
    lon,
    method,
    school,
    tz,
    Object.hashAll(offsets),
    hijriShift,
  );
}

const cairo = Place(30.0444, 31.2357);

class PrayerDay {
  const PrayerDay({
    required this.prayers,
    this.following = const [],
    required this.city,
    required this.hijriDay,
    required this.hijriMonthAr,
    this.hijriMonthEn = '',
    required this.hijriYear,
    this.hijriMonth = 0,
    required this.qiblaDegrees,
    required this.qiblaKm,
    this.utcOffset,
  });

  final List<Prayer> prayers;

  /// Times for the days after today, when known.
  final List<List<Prayer>> following;

  /// 1–12; 0 when unknown.
  final int hijriMonth;
  final String city;
  final int hijriDay;
  final String hijriMonthAr;
  final String hijriMonthEn;
  final int hijriYear;
  final double qiblaDegrees;
  final double qiblaKm;

  /// Offset of the city's timezone; null = assume the device's.
  final Duration? utcOffset;

  PrayerDay withQibla(double degrees) => PrayerDay(
    prayers: prayers,
    following: following,
    city: city,
    hijriDay: hijriDay,
    hijriMonthAr: hijriMonthAr,
    hijriMonthEn: hijriMonthEn,
    hijriYear: hijriYear,
    hijriMonth: hijriMonth,
    qiblaDegrees: degrees,
    qiblaKm: qiblaKm,
    utcOffset: utcOffset,
  );

  String get hijriAr =>
      '${toArabicDigits(hijriDay)} $hijriMonthAr ${toArabicDigits(hijriYear)}';

  String get hijriEn => '$hijriDay $hijriMonthEn $hijriYear AH';

  /// Wall-clock time in the city, comparable with [Prayer.on].
  DateTime cityNow(DateTime now) {
    final offset = utcOffset;
    if (offset == null) return now;
    final u = now.toUtc().add(offset);
    return DateTime(u.year, u.month, u.day, u.hour, u.minute, u.second);
  }

  static Duration? _parseOffset(Object? raw) {
    final m = RegExp(r'^([+-])(\d{2}):(\d{2})$').firstMatch('${raw ?? ''}');
    if (m == null) return null;
    final d = Duration(
      hours: int.parse(m.group(2)!),
      minutes: int.parse(m.group(3)!),
    );
    return m.group(1) == '-' ? -d : d;
  }

  static const _order = {
    'Fajr': 'الفجر',
    'Sunrise': 'الشروق',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
  };

  factory PrayerDay.fromJson(Map<String, dynamic> data) {
    final times = data['times'] as Map<String, dynamic>;
    final hijri = data['date']['hijri'] as Map<String, dynamic>;
    final qibla = data['qibla'] as Map<String, dynamic>;
    final tz = (data['timezone']?['name'] as String?) ?? '';

    return PrayerDay(
      prayers: [
        for (final e in _order.entries)
          Prayer.parse(e.key, e.value, times[e.key] as String),
      ],
      city: tz.split('/').last.replaceAll('_', ' '),
      hijriDay: int.parse(hijri['day'] as String),
      hijriMonthAr: hijri['month']['ar'] as String,
      hijriMonthEn: (hijri['month']['en'] as String?) ?? '',
      hijriYear: int.parse(hijri['year'] as String),
      hijriMonth: (hijri['month']['number'] as num?)?.toInt() ?? 0,
      qiblaDegrees: (qibla['direction']['degrees'] as num).toDouble(),
      qiblaKm: (qibla['distance']['value'] as num).toDouble(),
      utcOffset: _parseOffset(data['timezone']?['utc_offset']),
    );
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  /// Codes the UI translates; any other message comes from the server.
  static const missingKey = 'missing_key';
  static const network = 'network';
  static const badResponse = 'bad_response';

  final String message;

  @override
  String toString() => message;
}

class IslamicApi {
  IslamicApi({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _key = apiKey ?? const String.fromEnvironment('ISLAMIC_API_KEY');

  final http.Client _client;
  final String _key;

  Future<PrayerDay> fetchToday(Place place) async {
    final data = await _get('prayer-time', {
      'lat': '${place.lat}',
      'lon': '${place.lon}',
      'method': '${place.method}',
      'school': '${place.school}',
    });
    return PrayerDay.fromJson(data as Map<String, dynamic>);
  }

  Future<FastingDay> fetchFasting(Place place, {DateTime? today}) async {
    final data = await _get('fasting', {
      'lat': '${place.lat}',
      'lon': '${place.lon}',
      'method': '${place.method}',
    });
    return FastingDay.fromJson(
      data as Map<String, dynamic>,
      today: today ?? DateTime.now(),
    );
  }

  Future<Nisab> fetchNisab({
    required NisabStandard standard,
    required String currency,
  }) async {
    final body = await _get('zakat-nisab', {
      'standard': standard.name,
      'currency': currency.toLowerCase(),
      'unit': 'g',
    }, unwrap: false);
    return Nisab.fromJson(body as Map<String, dynamic>);
  }

  Future<NamesBook> fetchNames(String language) async {
    final data = await _get('asma-ul-husna', {'language': language});
    return NamesBook.fromJson(data as Map<String, dynamic>);
  }

  /// Categories, sections and all ~1000 duas (~3 MB) in one go.
  Future<DuaLibrary> fetchDuaLibrary(String lang) async {
    final [cats, secs, duas] = await Future.wait([
      _get('dua', {'type': 'category', 'lang': lang}),
      _get('dua', {'type': 'sub-category', 'lang': lang}),
      _get(
        'dua',
        {'type': 'translation', 'lang': lang},
        timeout: const Duration(seconds: 45),
        parse: _parseDuas,
      ),
    ], eagerError: true);

    return DuaLibrary(
      language: lang,
      categories: [
        for (final c in cats as List)
          DuaCategory.fromJson(c as Map<String, dynamic>),
      ],
      sections: [
        for (final s in secs as List)
          DuaSection.fromJson(s as Map<String, dynamic>),
      ],
      duas: {for (final d in duas as List<Dua>) d.id: d},
    );
  }

  Future<Dua> fetchDua(String lang, {int? id}) async {
    final data = await _get('dua', {
      'type': 'translation',
      'lang': lang,
      if (id != null) 'dua_id': '$id' else 'random': 'true',
    });
    return Dua.fromJson(data as Map<String, dynamic>);
  }

  Future<List<RuqyahEntry>> fetchRuqyah(
    RuqyahProgram program,
    RuqyahSource source,
    String lang,
  ) async {
    final data = await _get(
      'ruqyah',
      {
        'type': 'instant',
        'lang': lang,
        'program': program.slug,
        'source': source.slug,
      },
      timeout: const Duration(seconds: 25),
      parse: _parseRuqyah,
    );
    return data as List<RuqyahEntry>;
  }

  Future<List<RuqyahTopic>> fetchRuqyahTopics(String lang) async {
    final data = await _get('ruqyah', {'type': 'topic-category', 'lang': lang});
    return RuqyahTopic.listFromJson(data as List);
  }

  Future<List<RuqyahArticle>> fetchRuqyahArticles(
    String topic,
    String lang,
  ) async {
    final data = await _get(
      'ruqyah',
      {'type': 'topic', 'lang': lang, 'topic': topic},
      timeout: const Duration(seconds: 25),
      parse: _parseArticles,
    );
    return data as List<RuqyahArticle>;
  }

  /// [parse] runs on a background isolate together with JSON decoding,
  /// so big payloads don't jank the UI.
  Future<Object?> _get(
    String endpoint,
    Map<String, String> params, {
    bool unwrap = true,
    Duration timeout = const Duration(seconds: 12),
    Object? Function(Object? data)? parse,
  }) async {
    if (_key.isEmpty) {
      throw const ApiException(ApiException.missingKey);
    }
    final uri = Uri.https('islamicapi.com', '/api/v1/$endpoint/', {
      ...params,
      'api_key': _key,
    });

    final http.Response res;
    try {
      res = await _client.get(uri).timeout(timeout);
    } catch (_) {
      throw const ApiException(ApiException.network);
    }

    if (parse != null) {
      return compute(_decodeAndParse, (res.body, res.statusCode, parse));
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    _check(body, res.statusCode);
    return unwrap ? body['data'] : body;
  }

  static List<Dua> _parseDuas(Object? data) => [
    for (final d in data as List) Dua.fromJson(d as Map<String, dynamic>),
  ];

  static List<RuqyahEntry> _parseRuqyah(Object? data) => [
    for (final e in data as List)
      RuqyahEntry.fromJson(e as Map<String, dynamic>),
  ];

  static List<RuqyahArticle> _parseArticles(Object? data) => [
    for (final a in data as List)
      RuqyahArticle.fromJson(a as Map<String, dynamic>),
  ];

  static Object? _decodeAndParse(
    (String, int, Object? Function(Object?)) args,
  ) {
    final (text, status, parse) = args;
    final body = jsonDecode(text) as Map<String, dynamic>;
    _check(body, status);
    return parse(body['data']);
  }

  static void _check(Map<String, dynamic> body, int status) {
    if (status != 200 || body['status'] != 'success') {
      throw ApiException(
        (body['message'] as String?) ?? 'Request failed ($status)',
      );
    }
  }
}

class FastingDay {
  const FastingDay({
    required this.sahur,
    required this.iftar,
    required this.whiteDays,
    required this.whiteDaysEstimated,
  });

  final Prayer sahur;
  final Prayer iftar;

  /// The 13th–15th of the current or next Hijri month, whichever is ahead.
  final List<DateTime> whiteDays;
  final bool whiteDaysEstimated;

  Duration get duration => Duration(
    minutes:
        (iftar.hour * 60 + iftar.minute) - (sahur.hour * 60 + sahur.minute),
  );

  /// Sahur = Fajr, iftar = Maghrib — same source as on-device prayer times.
  factory FastingDay.local({
    required Prayer fajr,
    required Prayer maghrib,
    required List<DateTime> whiteDays,
    bool whiteDaysEstimated = false,
  }) => FastingDay(
    sahur: Prayer('Sahur', 'السحور', fajr.hour, fajr.minute),
    iftar: Prayer('Iftar', 'الإفطار', maghrib.hour, maghrib.minute),
    whiteDays: whiteDays,
    whiteDaysEstimated: whiteDaysEstimated,
  );

  factory FastingDay.fromJson(
    Map<String, dynamic> data, {
    required DateTime today,
  }) {
    final day = (data['fasting'] as List).first as Map<String, dynamic>;
    final time = day['time'] as Map<String, dynamic>;
    final date = DateTime(today.year, today.month, today.day);

    final apiDays =
        ((data['white_days']?['days'] as Map<String, dynamic>?) ?? {}).values
            .map((v) => DateTime.tryParse('$v'))
            .whereType<DateTime>()
            .toList()
          ..sort();

    // The API sometimes labels last month's white days as "next_month".
    var whiteDays = apiDays;
    var estimated = false;
    if (apiDays.isEmpty || apiDays.last.isBefore(date)) {
      final hijriDay = int.tryParse(
        '${day['hijri']}'.split('-').last,
      ); // "1448-04-30"
      if (hijriDay != null) {
        final toThirteenth = hijriDay <= 15
            ? 13 - hijriDay
            : 30 - hijriDay + 13;
        final first = date.add(Duration(days: toThirteenth));
        whiteDays = [for (var i = 0; i < 3; i++) first.add(Duration(days: i))];
        estimated = true;
      }
    }

    return FastingDay(
      sahur: Prayer.parse('Sahur', 'السحور', time['sahur'] as String),
      iftar: Prayer.parse('Iftar', 'الإفطار', time['iftar'] as String),
      whiteDays: whiteDays,
      whiteDaysEstimated: estimated,
    );
  }
}

String toArabicDigits(int n) => '$n'
    .split('')
    .map((c) => String.fromCharCode(0x0660 + int.parse(c)))
    .join();
