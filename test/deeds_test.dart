import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/bloc/qada_cubit.dart';
import 'package:muslim/bloc/quran/khatmah_cubit.dart';
import 'package:muslim/bloc/sadaqah_cubit.dart';
import 'package:muslim/bloc/travel_cubit.dart';

import 'helpers.dart';

void main() {
  setUp(useMemoryStorage);

  test('khatmah portion and marking it read', () {
    final now = DateTime(2026, 10, 1, 9);
    final c = KhatmahCubit(clock: () => now)..startPlan(30);
    expect(c.state.portion(now), (1, 21));
    c.markRead(1);
    expect(c.state.portion(now), (2, 21));
    c.readPortion();
    expect(c.state.readOn(now), 21);
    expect(c.state.portion(now), isNull);
  });

  test('qada owed, made up and Ramadan import', () {
    var now = DateTime(2026, 10, 1);
    final c = QadaCubit(clock: () => now)
      ..setOwed(3)
      ..toggleToday();
    expect(c.state.remaining, 2);
    c.setOwed(0);
    expect(c.state.owed, 1);
    c.importRamadan(1447, 4);
    c.importRamadan(1447, 4);
    expect(c.state.owed, 5);
    now = DateTime(2026, 10, 2);
    c.toggleToday();
    expect(c.state.remaining, 3);
  });

  test('kaffarah streak breaks on a missed day', () {
    var now = DateTime(2026, 10, 1, 12);
    final c = QadaCubit(clock: () => now)
      ..startKaffarah()
      ..toggleKaffarahToday();
    now = DateTime(2026, 10, 2, 12);
    expect(c.state.kaffarahBroken(now), isFalse);
    c.toggleKaffarahToday();
    expect(c.state.kaffarahStreak(now), 2);
    now = DateTime(2026, 10, 4, 12);
    expect(c.state.kaffarahBroken(now), isTrue);
    expect(c.state.kaffarahStreak(now), 2);
  });

  test('sadaqah totals, goal and weekly streak', () {
    var now = DateTime(2026, 10, 1);
    final c = SadaqahCubit(clock: () => now)
      ..add(SadaqahKind.money, amount: 50)
      ..add(SadaqahKind.help, note: 'Helped a neighbour')
      ..setGoal(200);
    expect(c.state.totalIn(now), 50);
    expect(c.state.inMonth(now).length, 2);
    now = DateTime(2026, 10, 8);
    c.add(SadaqahKind.food, amount: 20.5);
    expect(c.state.weekStreak(now), 2);
    expect(c.state.weekStreak(DateTime(2026, 10, 22)), 0);
    final restored = c.fromJson(c.toJson(c.state));
    expect(restored, c.state);
  });

  test('travel: first place is home, far away turns it on', () {
    final now = DateTime(2026, 10, 1);
    final c = TravelCubit(clock: () => now)..observe(30.04, 31.24);
    expect(c.state.travelling, isFalse);
    c.observe(31.2, 29.92);
    expect(c.state.away, isTrue);
    expect(c.state.kmFromHome, closeTo(180, 15));
    expect(c.state.dayOf(DateTime(2026, 10, 3)), 3);
    c.setManual(false);
    expect(c.state.travelling, isFalse);
    c.setManual(null);
    c.setHomeHere();
    expect(c.state.travelling, isFalse);
    expect(c.fromJson(c.toJson(c.state)), c.state);
  });
}
