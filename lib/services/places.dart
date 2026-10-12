import 'dart:math' as math;

import 'islamic_api.dart';

/// Cities offered in Settings. `method` follows islamicapi.com's
/// calculation-method ids; `school` 2 = Hanafi Asr.
class City {
  const City(
    this.id,
    this.nameEn,
    this.nameAr,
    this.lat,
    this.lon, {
    required this.method,
    this.school = 1,
    this.currency = 'USD',
    required this.tz,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final double lat;
  final double lon;
  final int method;
  final int school;

  /// IANA timezone.
  final String tz;

  /// Default currency for the Zakat calculator.
  final String currency;

  Place get place => Place(lat, lon, method: method, school: school, tz: tz);

  String name(bool arabic) => arabic ? nameAr : nameEn;
}

const cities = [
  City(
    'cairo',
    'Cairo',
    'القاهرة',
    30.0444,
    31.2357,
    method: 5,
    tz: 'Africa/Cairo',
    currency: 'EGP',
  ),
  City(
    'alexandria',
    'Alexandria',
    'الإسكندرية',
    31.2001,
    29.9187,
    method: 5,
    tz: 'Africa/Cairo',
    currency: 'EGP',
  ),
  City(
    'makkah',
    'Makkah',
    'مكة المكرمة',
    21.4225,
    39.8262,
    method: 4,
    tz: 'Asia/Riyadh',
    currency: 'SAR',
  ),
  City(
    'madinah',
    'Madinah',
    'المدينة المنورة',
    24.4672,
    39.6111,
    method: 4,
    tz: 'Asia/Riyadh',
    currency: 'SAR',
  ),
  City(
    'riyadh',
    'Riyadh',
    'الرياض',
    24.7136,
    46.6753,
    method: 4,
    tz: 'Asia/Riyadh',
    currency: 'SAR',
  ),
  City(
    'dubai',
    'Dubai',
    'دبي',
    25.2048,
    55.2708,
    method: 16,
    tz: 'Asia/Dubai',
    currency: 'AED',
  ),
  City(
    'kuwait',
    'Kuwait City',
    'مدينة الكويت',
    29.3759,
    47.9774,
    method: 9,
    tz: 'Asia/Kuwait',
    currency: 'KWD',
  ),
  City(
    'doha',
    'Doha',
    'الدوحة',
    25.2854,
    51.5310,
    method: 10,
    tz: 'Asia/Qatar',
    currency: 'QAR',
  ),
  City(
    'amman',
    'Amman',
    'عمّان',
    31.9454,
    35.9284,
    method: 23,
    tz: 'Asia/Amman',
    currency: 'JOD',
  ),
  City(
    'casablanca',
    'Casablanca',
    'الدار البيضاء',
    33.5731,
    -7.5898,
    method: 21,
    tz: 'Africa/Casablanca',
    currency: 'MAD',
  ),
  City(
    'istanbul',
    'Istanbul',
    'إسطنبول',
    41.0082,
    28.9784,
    method: 13,
    tz: 'Europe/Istanbul',
    currency: 'TRY',
  ),
  City(
    'karachi',
    'Karachi',
    'كراتشي',
    24.8607,
    67.0011,
    method: 1,
    school: 2,
    tz: 'Asia/Karachi',
    currency: 'PKR',
  ),
  City(
    'jakarta',
    'Jakarta',
    'جاكرتا',
    -6.2088,
    106.8456,
    method: 20,
    tz: 'Asia/Jakarta',
    currency: 'IDR',
  ),
  City(
    'kuala-lumpur',
    'Kuala Lumpur',
    'كوالالمبور',
    3.1390,
    101.6869,
    method: 17,
    tz: 'Asia/Kuala_Lumpur',
    currency: 'MYR',
  ),
  City(
    'london',
    'London',
    'لندن',
    51.5074,
    -0.1278,
    method: 15,
    tz: 'Europe/London',
    currency: 'GBP',
  ),
  City(
    'new-york',
    'New York',
    'نيويورك',
    40.7128,
    -74.0060,
    method: 2,
    tz: 'America/New_York',
    currency: 'USD',
  ),
];

City cityById(String id) =>
    cities.firstWhere((c) => c.id == id, orElse: () => cities.first);

/// Closest listed city, whose calculation method and currency stand in
/// for an arbitrary position.
City nearestCity(double lat, double lon) {
  double dist(City c) {
    final dLat = c.lat - lat;
    final dLon = (c.lon - lon) * math.cos(lat * math.pi / 180);
    return dLat * dLat + dLon * dLon;
  }

  return cities.reduce((a, b) => dist(a) <= dist(b) ? a : b);
}
