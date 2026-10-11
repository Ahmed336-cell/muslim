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
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final double lat;
  final double lon;
  final int method;
  final int school;

  /// Default currency for the Zakat calculator.
  final String currency;

  Place get place => Place(lat, lon, method: method, school: school);

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
    currency: 'EGP',
  ),
  City(
    'alexandria',
    'Alexandria',
    'الإسكندرية',
    31.2001,
    29.9187,
    method: 5,
    currency: 'EGP',
  ),
  City(
    'makkah',
    'Makkah',
    'مكة المكرمة',
    21.4225,
    39.8262,
    method: 4,
    currency: 'SAR',
  ),
  City(
    'madinah',
    'Madinah',
    'المدينة المنورة',
    24.4672,
    39.6111,
    method: 4,
    currency: 'SAR',
  ),
  City(
    'riyadh',
    'Riyadh',
    'الرياض',
    24.7136,
    46.6753,
    method: 4,
    currency: 'SAR',
  ),
  City('dubai', 'Dubai', 'دبي', 25.2048, 55.2708, method: 16, currency: 'AED'),
  City(
    'kuwait',
    'Kuwait City',
    'مدينة الكويت',
    29.3759,
    47.9774,
    method: 9,
    currency: 'KWD',
  ),
  City('doha', 'Doha', 'الدوحة', 25.2854, 51.5310, method: 10, currency: 'QAR'),
  City(
    'amman',
    'Amman',
    'عمّان',
    31.9454,
    35.9284,
    method: 23,
    currency: 'JOD',
  ),
  City(
    'casablanca',
    'Casablanca',
    'الدار البيضاء',
    33.5731,
    -7.5898,
    method: 21,
    currency: 'MAD',
  ),
  City(
    'istanbul',
    'Istanbul',
    'إسطنبول',
    41.0082,
    28.9784,
    method: 13,
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
    currency: 'PKR',
  ),
  City(
    'jakarta',
    'Jakarta',
    'جاكرتا',
    -6.2088,
    106.8456,
    method: 20,
    currency: 'IDR',
  ),
  City(
    'kuala-lumpur',
    'Kuala Lumpur',
    'كوالالمبور',
    3.1390,
    101.6869,
    method: 17,
    currency: 'MYR',
  ),
  City(
    'london',
    'London',
    'لندن',
    51.5074,
    -0.1278,
    method: 15,
    currency: 'GBP',
  ),
  City(
    'new-york',
    'New York',
    'نيويورك',
    40.7128,
    -74.0060,
    method: 2,
    currency: 'USD',
  ),
];

City cityById(String id) =>
    cities.firstWhere((c) => c.id == id, orElse: () => cities.first);
