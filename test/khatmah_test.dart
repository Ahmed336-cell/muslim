import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/bloc/quran/khatmah_cubit.dart';

import 'helpers.dart';

void main() {
  setUp(useMemoryStorage);

  test('daily target, schedule and streak', () {
    var now = DateTime(2026, 10, 1, 9);
    final c = KhatmahCubit(clock: () => now)..startPlan(30);
    expect(c.state.todayTarget(now), 21);
    expect(c.state.nextPage, 1);

    for (var p = 1; p <= 10; p++) {
      c.markRead(p);
    }
    c.markRead(5);
    expect(c.state.readOn(now), 10);
    expect(c.state.todayTarget(now), 21);
    expect(c.state.expectedBy(now) - c.state.read.length, 11);
    expect(c.state.streak(now), 1);

    now = DateTime(2026, 10, 2, 9);
    expect(c.state.streak(now), 1);
    expect(c.state.todayTarget(now), 21);
    c.markRead(11);
    expect(c.state.streak(now), 2);

    now = DateTime(2026, 10, 4, 9);
    expect(c.state.streak(now), 0);
    expect(c.state.dayOf(now), 4);
  });

  test('finishing counts a khatmah once; state survives restarts', () {
    final now = DateTime(2026, 10, 1);
    final c = KhatmahCubit(clock: () => now)..startPlan(7);
    c.readUpTo(603);
    expect(c.state.nextPage, 604);
    c.markRead(604);
    expect(c.state.done, isTrue);
    expect(c.state.completed, 1);
    c.markRead(604);
    expect(c.state.completed, 1);

    final restored = c.fromJson(c.toJson(c.state));
    expect(restored, c.state);

    c.stop();
    expect(c.state.active, isFalse);
    expect(c.state.completed, 1);
    c.markRead(1);
    expect(c.state.read, isEmpty);
  });
}
