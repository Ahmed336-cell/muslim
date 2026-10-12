import 'dart:async';

import 'package:muslim/services/ambient.dart';
import 'package:muslim/services/player.dart';
import 'package:muslim/services/recitation.dart';

class FakeEngine implements AudioEngine {
  final _states = StreamController<EngineState>.broadcast();
  var queue = <Track>[];
  var index = 0;
  var playing = false;
  var failLoad = false;
  var loads = 0;
  var repeat = false;
  var volume = 1.0;

  void emitState({bool completed = false}) => _states.add(
    EngineState(index: index, playing: playing, completed: completed),
  );

  @override
  Stream<EngineState> get states => _states.stream;

  @override
  Stream<Duration> get position => Stream.value(Duration.zero);

  @override
  Stream<Duration?> get duration => Stream.value(null);

  @override
  Future<void> load(List<Track> tracks, int index) async {
    loads++;
    if (failLoad) throw Exception('no network');
    queue = [...tracks];
    this.index = index;
    playing = true;
    emitState();
  }

  @override
  Future<void> append(List<Track> tracks) async => queue.addAll(tracks);

  @override
  Future<void> play() async {
    playing = true;
    emitState();
  }

  @override
  Future<void> pause() async {
    playing = false;
    emitState();
  }

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> skipTo(int index) async {
    this.index = index;
    playing = true;
    emitState();
  }

  @override
  Future<void> setRepeat(bool repeat) async => this.repeat = repeat;

  @override
  Future<void> setVolume(double volume) async => this.volume = volume;

  @override
  Future<void> stop() async {
    queue = [];
    playing = false;
  }

  @override
  Future<void> dispose() => _states.close();
}

class FakeStore implements AudioStore {
  final files = <(int, int)>{};
  var fail = false;

  @override
  Future<Set<(int, int)>> saved() async => {...files};

  @override
  Future<Uri?> local(int recording, int surah) async =>
      files.contains((recording, surah))
      ? Uri.file('/audio/$recording/$surah.mp3')
      : null;

  @override
  Future<void> download(
    int recording,
    int surah,
    Uri url, {
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(.5);
    if (fail) throw Exception('offline');
    onProgress?.call(1);
    files.add((recording, surah));
  }

  @override
  Future<void> delete(int recording, int surah) async =>
      files.remove((recording, surah));
}

class FakeAmbient implements AmbientEngine {
  /// Sound → volume for every loop currently audible.
  final playing = <Ambient, double>{};
  final loaded = <Ambient>{};

  @override
  Future<void> start(Ambient sound, double volume) async {
    loaded.add(sound);
    playing[sound] = volume;
  }

  @override
  Future<void> setVolume(Ambient sound, double volume) async {
    if (playing.containsKey(sound)) playing[sound] = volume;
  }

  @override
  Future<void> stop(Ambient sound) async {
    loaded.remove(sound);
    playing.remove(sound);
  }

  @override
  Future<void> pauseAll() async => playing.clear();

  @override
  Future<void> dispose() async {}
}
