import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/services/hisn.dart';

void main() {
  DateTime t(int d, int h, [int m = 0]) => DateTime(2026, 10, d, h, m);
  AzkarTime at(DateTime now) => AzkarTime.at(
    now,
    fajr: t(13, 4, 40),
    dhuhr: t(13, 11, 40),
    maghrib: t(13, 17, 30),
  );

  test('morning runs from Fajr until Dhuhr', () {
    expect(at(t(13, 4, 40)), AzkarTime.morning);
    expect(at(t(13, 11, 39)), AzkarTime.morning);
  });

  test('evening runs from Dhuhr until the middle of the night', () {
    // Middle of 17:30 → 04:40 is 23:05.
    expect(at(t(13, 11, 40)), AzkarTime.evening);
    expect(at(t(13, 23, 4)), AzkarTime.evening);
    expect(at(t(13, 23, 5)), AzkarTime.sleep);
  });

  test('after midnight it is sleep until Fajr', () {
    expect(at(t(13, 0, 30)), AzkarTime.sleep);
    expect(at(t(13, 4, 39)), AzkarTime.sleep);
  });

  test('sleep opens the evening session', () {
    expect(AzkarTime.sleep.session, AzkarSession.evening);
    expect(AzkarTime.morning.session, AzkarSession.morning);
  });
}
