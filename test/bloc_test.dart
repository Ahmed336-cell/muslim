import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/bloc/prayer_log_cubit.dart';
import 'package:muslim/bloc/prayer_times/prayer_times_bloc.dart';
import 'package:muslim/bloc/settings_cubit.dart';
import 'package:muslim/bloc/tasbih_cubit.dart';
import 'package:muslim/data.dart';
import 'package:muslim/services/islamic_api.dart';

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

class _FakeRepo extends IslamicApi {
  _FakeRepo(this.result) : super(apiKey: 'test');

  final Object result;
  final places = <Place>[];

  @override
  Future<PrayerDay> fetchToday(Place place) async {
    places.add(place);
    if (result is PrayerDay) return result as PrayerDay;
    throw result;
  }
}

void main() {
  setUp(useMemoryStorage);

  group('PrayerTimesBloc', () {
    blocTest<PrayerTimesBloc, PrayerTimesState>(
      'loads the day',
      build: () => PrayerTimesBloc(repository: _FakeRepo(_day)),
      act: (b) => b.add(const PrayerTimesRequested()),
      expect: () => const [
        PrayerTimesState(status: PrayerTimesStatus.loading),
        PrayerTimesState(status: PrayerTimesStatus.success, day: _day),
      ],
    );

    blocTest<PrayerTimesBloc, PrayerTimesState>(
      'surfaces API errors',
      build: () => PrayerTimesBloc(
        repository: _FakeRepo(const ApiException('Invalid API key')),
      ),
      act: (b) => b.add(const PrayerTimesRequested()),
      expect: () => const [
        PrayerTimesState(status: PrayerTimesStatus.loading),
        PrayerTimesState(
          status: PrayerTimesStatus.failure,
          error: 'Invalid API key',
        ),
      ],
    );

    blocTest<PrayerTimesBloc, PrayerTimesState>(
      'keeps old data when refresh fails',
      build: () =>
          PrayerTimesBloc(repository: _FakeRepo(const ApiException('x'))),
      seed: () =>
          const PrayerTimesState(status: PrayerTimesStatus.success, day: _day),
      act: (b) => b.add(const PrayerTimesRefreshed()),
      expect: () => const [
        PrayerTimesState(status: PrayerTimesStatus.loading, day: _day),
        PrayerTimesState(
          status: PrayerTimesStatus.failure,
          day: _day,
          error: 'x',
        ),
      ],
    );

    final repo = _FakeRepo(_day);
    const makkah = Place(21.4225, 39.8262, method: 4);
    blocTest<PrayerTimesBloc, PrayerTimesState>(
      'drops the old city when switching place',
      build: () => PrayerTimesBloc(repository: repo),
      seed: () =>
          const PrayerTimesState(status: PrayerTimesStatus.success, day: _day),
      act: (b) => b.add(const PrayerTimesRequested(place: makkah)),
      expect: () => const [
        PrayerTimesState(status: PrayerTimesStatus.loading),
        PrayerTimesState(status: PrayerTimesStatus.success, day: _day),
      ],
      verify: (_) => expect(repo.places, [makkah]),
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
      expect(c.state, {'Fajr'});
      c.toggle('Fajr');
      expect(c.state, isEmpty);
    });

    test('starts empty on a new day', () {
      var now = DateTime(2026, 10, 11, 22);
      final c = PrayerLogCubit(clock: () => now)..toggle('Isha');
      expect(PrayerLogCubit(clock: () => now).today, {'Isha'});

      now = DateTime(2026, 10, 12, 5);
      expect(c.today, isEmpty);
      expect(PrayerLogCubit(clock: () => now).today, isEmpty);
      c.toggle('Fajr');
      expect(c.state, {'Fajr'});
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
  });
}
