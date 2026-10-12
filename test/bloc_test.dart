import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/bloc/location_cubit.dart';
import 'package:muslim/bloc/prayer_log_cubit.dart';
import 'package:muslim/bloc/prayer_times/prayer_times_bloc.dart';
import 'package:muslim/bloc/settings_cubit.dart';
import 'package:muslim/bloc/tasbih_cubit.dart';
import 'package:muslim/data.dart';
import 'package:muslim/services/islamic_api.dart';
import 'package:muslim/services/location.dart';
import 'package:muslim/services/prayer_calc.dart';

import 'helpers.dart';

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
  _FakeCalc(this.result);

  final Object result;
  final places = <Place>[];

  @override
  PrayerDay today(Place place, DateTime now, {int days = 7}) {
    places.add(place);
    if (result is PrayerDay) return result as PrayerDay;
    throw result;
  }
}

void main() {
  setUp(useMemoryStorage);

  group('PrayerTimesBloc', () {
    blocTest<PrayerTimesBloc, PrayerTimesState>(
      'computes the day',
      build: () => PrayerTimesBloc(calculator: _FakeCalc(_day)),
      act: (b) => b.add(const PrayerTimesRequested()),
      expect: () => const [
        PrayerTimesState(status: PrayerTimesStatus.success, day: _day),
      ],
    );

    blocTest<PrayerTimesBloc, PrayerTimesState>(
      'keeps old data when a calculation fails',
      build: () => PrayerTimesBloc(calculator: _FakeCalc(StateError('x'))),
      seed: () =>
          const PrayerTimesState(status: PrayerTimesStatus.success, day: _day),
      act: (b) => b.add(const PrayerTimesRefreshed()),
      expect: () => const [
        PrayerTimesState(
          status: PrayerTimesStatus.failure,
          day: _day,
          error: ApiException.badResponse,
        ),
      ],
    );

    final calc = _FakeCalc(_day);
    const makkah = Place(21.4225, 39.8262, method: 4);
    blocTest<PrayerTimesBloc, PrayerTimesState>(
      'switches place',
      build: () => PrayerTimesBloc(calculator: calc),
      act: (b) => b.add(const PrayerTimesRequested(place: makkah)),
      expect: () => const [
        PrayerTimesState(status: PrayerTimesStatus.success, day: _day),
      ],
      verify: (_) => expect(calc.places, [makkah]),
    );
  });

  group('TasbihCubit', () {
    test('moves to next dhikr at target and reports the full set', () {
      final c = TasbihCubit();
      for (var i = 0; i < 32; i++) {
        expect(c.tap(), TasbihTap.counted);
      }
      expect(c.tap(), TasbihTap.dhikrDone);
      expect(c.state, const TasbihState(index: 1, count: 0, total: 33));

      for (var i = 0; i < 33 * 2; i++) {
        c.tap();
      }
      expect(c.state.index, 3);
      expect(c.tap(), TasbihTap.setDone);
      expect(c.state.index, 0);
    });

    test('restores today but not yesterday', () {
      var now = DateTime(2026, 10, 11, 9);
      TasbihCubit(clock: () => now)
        ..tap()
        ..tap();
      expect(TasbihCubit(clock: () => now).state.total, 2);

      now = DateTime(2026, 10, 12, 9);
      expect(TasbihCubit(clock: () => now).state, const TasbihState());
    });
  });

  group('PrayerLogCubit', () {
    test('toggles', () {
      final c = PrayerLogCubit()..toggle('Fajr');
      expect(c.today, {'Fajr'});
      c.toggle('Fajr');
      expect(c.today, isEmpty);
    });

    test('keeps history, streak, rate and qada', () {
      var now = DateTime(2026, 10, 10, 22);
      final c = PrayerLogCubit(clock: () => now);
      for (final p in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        c.toggle(p);
      }
      now = DateTime(2026, 10, 11, 22);
      for (final p in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        c.toggle(p);
      }
      now = DateTime(2026, 10, 12, 9);
      c.toggle('Fajr');
      expect(c.state.streak(now), 2);
      expect(c.state.rate(now, 7), 11 / 15);
      expect(c.state.rate(now, 7, prayer: 'Fajr'), 1);
      c.toggleOn(DateTime(2026, 10, 11), 'Asr');
      expect(c.state.streak(now), 0);

      c
        ..addQada('Fajr', 3)
        ..addQada('Fajr', -1)
        ..addQada('Isha', -4);
      expect(c.state.qada, {'Fajr': 2, 'Isha': 0});
      expect(PrayerLogCubit(clock: () => now).state, c.state);
    });

    test('reads the old one-day format', () {
      final now = DateTime(2026, 10, 12, 9);
      final c = PrayerLogCubit(clock: () => now);
      expect(
        c
            .fromJson({
              'day': '2026-10-12',
              'prayed': ['Fajr'],
            })!
            .on(now),
        {'Fajr'},
      );
    });

    test('starts empty on a new day', () {
      var now = DateTime(2026, 10, 11, 22);
      final c = PrayerLogCubit(clock: () => now)..toggle('Isha');
      expect(PrayerLogCubit(clock: () => now).today, {'Isha'});

      now = DateTime(2026, 10, 12, 5);
      expect(c.today, isEmpty);
      expect(PrayerLogCubit(clock: () => now).today, isEmpty);
      c.toggle('Fajr');
      expect(c.today, {'Fajr'});
    });
  });

  group('SettingsCubit', () {
    test('persists language and city', () {
      SettingsCubit()
        ..setLanguage('ar')
        ..setCity('makkah');
      final s = SettingsCubit().state;
      expect(s.language, 'ar');
      expect(s.city.nameEn, 'Makkah');
      expect(s.place.method, 4);
    });

    test('Hanafi Asr follows the city, and can be overridden', () {
      final c = SettingsCubit()..setCity('karachi');
      expect(c.state.place.school, 2);
      c.setHanafiAsr(false);
      expect(c.state.place.school, 1);
    });

    test('only en and ar are used as UI languages', () {
      expect(SettingsCubit(initialLanguage: 'fr').state.language, 'en');
      useMemoryStorage();
      expect(SettingsCubit(initialLanguage: 'ar').state.language, 'ar');
    });

    test('my location uses the GPS fix with the nearest city\'s method', () {
      SettingsCubit().setLocation(24.71364, 46.67532); // Riyadh
      final s = SettingsCubit().state;
      expect(s.usesLocation, isTrue);
      expect(s.location, (24.714, 46.675));
      expect(s.place.lat, 24.714);
      expect(s.city.id, 'riyadh');
      expect(s.place.method, s.city.method);

      final c = SettingsCubit()..setCity('cairo');
      expect(c.state.usesLocation, isFalse);
      expect(c.state.place.lat, 30.0444);
    });
  });

  group('LocationCubit', () {
    setUp(useMemoryStorage);

    test('stores the position, or reports why it failed', () async {
      final settings = SettingsCubit();
      final ok = LocationCubit(
        service: _FakeLocation(() async => (21.42, 39.83)),
        settings: settings,
      );
      await ok.locate();
      expect(ok.state, const LocateState());
      expect(settings.state.location, (21.42, 39.83));

      final denied = LocationCubit(
        service: _FakeLocation(
          () => throw const LocationException(LocationException.blocked),
        ),
        settings: settings,
      );
      await denied.locate();
      expect(denied.state.error, LocationException.blocked);
      await denied.locate(silent: true);
      expect(denied.state.error, isNull);
    });

    test('refreshes on launch only when reading by location', () async {
      var calls = 0;
      final settings = SettingsCubit();
      final service = _FakeLocation(() async {
        calls++;
        return (30.0, 31.0);
      });
      LocationCubit(service: service, settings: settings).refresh();
      expect(calls, 0);
      settings.setLocation(30, 31);
      LocationCubit(service: service, settings: settings).refresh();
      expect(calls, 1);
    });
  });
}

class _FakeLocation extends LocationService {
  _FakeLocation(this._current);

  final Future<(double, double)> Function() _current;

  @override
  Future<(double, double)> current() => _current();
}
