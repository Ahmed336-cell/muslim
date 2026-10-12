import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class Track {
  const Track({
    required this.id,
    required this.uri,
    required this.title,
    required this.artist,
    required this.surah,
    this.ayah,
    this.art,
  });

  final String id;
  final Uri uri;
  final String title;
  final String artist;
  final int surah;

  /// Bundled photo of the reciter, if there is one.
  final String? art;

  /// Set when the track is a single ayah.
  final (int surah, int ayah)? ayah;
}

class EngineState {
  const EngineState({
    this.index,
    this.playing = false,
    this.buffering = false,
    this.completed = false,
  });

  final int? index;
  final bool playing;
  final bool buffering;

  /// The end of the queue was reached.
  final bool completed;
}

/// Plays a queue of tracks; [JustAudioEngine] on devices, a fake in tests.
abstract class AudioEngine {
  Stream<EngineState> get states;
  Stream<Duration> get position;
  Stream<Duration?> get duration;

  Future<void> load(List<Track> tracks, int index);
  Future<void> append(List<Track> tracks);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> skipTo(int index);

  /// Loops the current track.
  Future<void> setRepeat(bool repeat);
  Future<void> stop();
  Future<void> dispose();
}

/// Background playback with lock-screen controls via just_audio_background.
class JustAudioEngine implements AudioEngine {
  final _states = StreamController<EngineState>.broadcast();
  final _subs = <StreamSubscription<Object?>>[];
  AudioPlayer? _p;

  // Created on first use so screens that never play don't touch the
  // platform player.
  AudioPlayer get _player => _p ??= _create();

  AudioPlayer _create() {
    final p = AudioPlayer();
    void push([_]) {
      final s = p.processingState;
      _states.add(
        EngineState(
          index: p.currentIndex,
          playing: p.playing,
          buffering:
              s == ProcessingState.loading || s == ProcessingState.buffering,
          completed: s == ProcessingState.completed,
        ),
      );
    }

    _subs
      ..add(p.playerStateStream.listen(push))
      ..add(p.currentIndexStream.listen(push))
      ..add(
        p.playbackEventStream.listen(
          (_) {},
          onError: (Object e, StackTrace _) => _states.addError(e),
        ),
      );
    return p;
  }

  static AudioSource _source(Track t) => AudioSource.uri(
    t.uri,
    tag: MediaItem(id: t.id, title: t.title, artist: t.artist),
  );

  @override
  Stream<EngineState> get states => _states.stream;

  @override
  Stream<Duration> get position => _player.positionStream;

  @override
  Stream<Duration?> get duration => _player.durationStream;

  @override
  Future<void> load(List<Track> tracks, int index) async {
    await _player.setAudioSources([
      for (final t in tracks) _source(t),
    ], initialIndex: index);
    unawaited(_player.play());
  }

  @override
  Future<void> append(List<Track> tracks) =>
      _player.addAudioSources([for (final t in tracks) _source(t)]);

  @override
  Future<void> play() async {
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero, index: _player.currentIndex);
    }
    unawaited(_player.play());
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipTo(int index) async {
    await _player.seek(Duration.zero, index: index);
    unawaited(_player.play());
  }

  @override
  Future<void> setRepeat(bool repeat) =>
      _player.setLoopMode(repeat ? LoopMode.one : LoopMode.off);

  @override
  Future<void> stop() async {
    await _p?.stop();
    await _p?.clearAudioSources();
  }

  @override
  Future<void> dispose() async {
    for (final s in _subs) {
      await s.cancel();
    }
    await _p?.dispose();
    await _states.close();
  }
}
