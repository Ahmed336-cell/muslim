import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/bloc/fasting/fasting_bloc.dart';
import 'package:muslim/services/islamic_api.dart';

Map<String, dynamic> _payload({
  String sahur = '05:28',
  String iftar = '18:29',
  String hijri = '1448-04-30',
  Map<String, String> white = const {
    '13th': '2026-09-24',
    '14th': '2026-09-25',
    '15th': '2026-09-26',
  },
}) => {
  'fasting': [
    {
      'date': '2026-10-11',
      'hijri': hijri,
      'time': {'sahur': sahur, 'iftar': iftar},
    },
  ],
  'white_days': {'status': 'next_month', 'days': white},
};

class _FakeRepo extends IslamicApi {
  _FakeRepo(this.result) : super(apiKey: 'test');

  final Object result;

  @override
  Future<FastingDay> fetchFasting(Place place, {DateTime? today}) async {
    if (result is FastingDay) return result as FastingDay;
    throw result;
  }
}

void main() {
  final today = DateTime(2026, 10, 11);

  test('parses times and duration', () {
    final f = FastingDay.fromJson(_payload(), today: today);
    expect([f.sahur.hour, f.sahur.minute], [5, 28]);
    expect([f.iftar.hour, f.iftar.minute], [18, 29]);
    expect(f.duration, const Duration(hours: 13, minutes: 1));
  });

  test('accepts 12h times', () {
    final f = FastingDay.fromJson(
      _payload(sahur: '4:04 AM', iftar: '6:53 PM'),
      today: today,
    );
    expect(f.duration, const Duration(hours: 14, minutes: 49));
  });

  test('uses upcoming API white days as-is', () {
    final f = FastingDay.fromJson(
      _payload(
        white: const {
          '13th': '2026-10-24',
          '14th': '2026-10-25',
          '15th': '2026-10-26',
        },
      ),
      today: today,
    );
    expect(f.whiteDaysEstimated, isFalse);
    expect(f.whiteDays.first, DateTime(2026, 10, 24));
  });

  test('estimates white days when API returns past dates', () {
    final f = FastingDay.fromJson(_payload(), today: today);
    expect(f.whiteDaysEstimated, isTrue);
    // 30th of the month → 13th of next is 13 days away.
    expect(f.whiteDays, [
      DateTime(2026, 10, 24),
      DateTime(2026, 10, 25),
      DateTime(2026, 10, 26),
    ]);
  });

  test('mid white days keeps the current set', () {
    final f = FastingDay.fromJson(_payload(hijri: '1448-05-14'), today: today);
    expect(f.whiteDays.first, DateTime(2026, 10, 10));
  });

  blocTest<FastingBloc, FastingState>(
    'emits failure with API message',
    build: () => FastingBloc(
      repository: _FakeRepo(const ApiException('Unable to fetch fasting time')),
    ),
    act: (b) => b.add(const FastingRequested()),
    expect: () => const [
      FastingState(status: FastingStatus.loading),
      FastingState(
        status: FastingStatus.failure,
        error: 'Unable to fetch fasting time',
      ),
    ],
  );
}
