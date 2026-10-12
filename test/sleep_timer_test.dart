import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/bloc/quran/recitation_cubit.dart';
import 'package:muslim/services/recitation.dart';

import 'fake_audio.dart';

const _recording = Recording(
  id: 50,
  name: 'Hafs',
  server: 'https://server.test/r5/',
  surahs: [1, 2, 112],
);
const _reciter = Reciter(id: 5, name: 'R', recordings: [_recording]);

void main() {
  test('timer fades out, pauses and restores volume', () {
    fakeAsync((async) {
      final engine = FakeEngine();
      final c = RecitationCubit(engine: engine);
      c.playSurahs(_reciter, _recording, 1, 'en');
      async.flushMicrotasks();
      expect(c.state.playing, isTrue);

      c.setSleepTimer(const Duration(minutes: 15));
      expect(c.state.sleepOn, isTrue);
      async.elapse(const Duration(minutes: 15, seconds: 9));
      expect(engine.volume, lessThan(1));
      expect(c.state.playing, isTrue);

      async.elapse(RecitationCubit.fadeStep * 10);
      expect(c.state.playing, isFalse);
      expect(c.state.sleepOn, isFalse);
      expect(engine.volume, 1);
    });
  });

  test('turning the timer off mid-fade restores volume', () {
    fakeAsync((async) {
      final engine = FakeEngine();
      final c = RecitationCubit(engine: engine);
      c.playSurahs(_reciter, _recording, 1, 'en');
      c.setSleepTimer(const Duration(minutes: 5));
      async.elapse(const Duration(minutes: 5, seconds: 6));
      c.setSleepTimer(null);
      async.elapse(RecitationCubit.fadeStep * 10);
      expect(c.state.playing, isTrue);
      expect(engine.volume, 1);
    });
  });

  test('end of surah pauses when the next surah starts', () {
    fakeAsync((async) {
      final engine = FakeEngine();
      final c = RecitationCubit(engine: engine);
      c.playSurahs(_reciter, _recording, 1, 'en');
      async.flushMicrotasks();
      c.sleepAfterThisSurah();
      engine
        ..index = 1
        ..emitState();
      async.flushMicrotasks();
      expect(c.state.playing, isFalse);
      expect(c.state.sleepAfterSurah, isFalse);
      expect(engine.playing, isFalse);
    });
  });
}
