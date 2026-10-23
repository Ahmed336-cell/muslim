import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muslim/bloc/prayer_times/prayer_times_bloc.dart';
import 'package:muslim/data.dart';
import 'package:muslim/services/islamic_api.dart';
import 'package:muslim/services/prayer_calc.dart';
import 'package:muslim/services/qibla_api.dart';

const _day = PrayerDay(
  prayers: [Prayer('Fajr', 'الفجر', 5, 28)],
  city: 'Cairo',
  hijriDay: 30,
  hijriMonthAr: 'ربيع الثاني',
  hijriYear: 1448,
  qiblaDegrees: 136.14,
  qiblaKm: 1287.22,
);

class _FakeCalc extends PrayerCalculator {
  const _FakeCalc();

  @override
  PrayerDay today(Place place, DateTime now, {int days = 7}) => _day;
}

void main() {
  test('reads direction from the Aladhan qibla endpoint', () async {
    late Uri called;
    final api = QiblaApi(
      client: MockClient((req) async {
        called = req.url;
        return http.Response(
          '{"code":200,"status":"OK","data":{"latitude":30.04,"longitude":31.24,"direction":141.2}}',
          200,
        );
      }),
    );

    expect(await api.direction(30.0444, 31.2357), 141.2);
    expect(called.host, 'api.aladhan.com');
    expect(called.path, '/v1/qibla/30.0444/31.2357');
  });

  test('returns null when the endpoint fails', () async {
    final api = QiblaApi(
      client: MockClient((_) async => http.Response('nope', 500)),
    );
    expect(await api.direction(30, 31), isNull);
  });

  blocTest<PrayerTimesBloc, PrayerTimesState>(
    'replaces the on-device bearing with the API direction',
    build: () => PrayerTimesBloc(
      calculator: const _FakeCalc(),
      qibla: QiblaApi(
        client: MockClient(
          (_) async => http.Response(
            '{"data":{"direction":141.2}}',
            200,
          ),
        ),
      ),
    ),
    act: (b) => b.add(const PrayerTimesRequested(place: cairo)),
    expect: () => [
      isA<PrayerTimesState>().having(
        (s) => s.day?.qiblaDegrees,
        'local',
        136.14,
      ),
      isA<PrayerTimesState>().having((s) => s.day?.qiblaDegrees, 'api', 141.2),
    ],
  );
}
