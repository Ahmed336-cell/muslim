import 'dart:async';

import 'package:audio_session/audio_session.dart';
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
    this.start,
  });

  final String id;
  final Uri uri;
  final String title;
  final String artist;
  final int surah;

  /// Where playback of this file begins. Used to open a full surah at an ayah.
  final Duration? start;

  /// Bundled photo of the reciter, if there is one.
  final String? art;

  /// Set when the track is a single ayah.
  final (int surah, int ayah)? ayah;
}

/// Media playback session: plays through the speaker even with the silent
/// switch on. Recording leaves the session in record mode, so it is
/// restored afterwards.
Future<void> usePlaybackSession() async {
  try {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  } catch (_) {
    // No audio session on this platform.
  }
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

  Future<void> load(List<Track> tracks, int index, {bool live = false});
  Future<void> append(List<Track> tracks);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> skipTo(int index);

  /// Loops the current track.
  Future<void> setRepeat(bool repeat);

  /// 0–1, for fading out at bedtime.
  Future<void> setVolume(double volume);
  Future<void> stop();
  Future<void> dispose();

  /// Loops silence so a download or on-device check keeps running when the
  /// app is backgrounded. No-op when this player is not the real one.
  Future<void> holdInBackground(String title) async {}

  /// Stops a hold started by [holdInBackground]. Leaves real playback alone.
  Future<void> releaseBackgroundHold() async {}
}

/// Background playback with lock-screen controls via just_audio_background.
class JustAudioEngine implements AudioEngine {
  final _states = StreamController<EngineState>.broadcast();
  final _subs = <StreamSubscription<Object?>>[];
  AudioPlayer? _p;
  var _holding = false;
  String? _holdTitle;

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

  static AudioSource _source(Track t) {
    final tag = MediaItem(id: t.id, title: t.title, artist: t.artist);
    final file = AudioSource.uri(t.uri);
    final start = t.start;
    if (start == null || start <= Duration.zero) {
      return AudioSource.uri(t.uri, tag: tag);
    }
    return ClippingAudioSource(child: file, start: start, tag: tag);
  }

  @override
  Stream<EngineState> get states => _states.stream;

  @override
  Stream<Duration> get position => _player.positionStream;

  @override
  Stream<Duration?> get duration => _player.durationStream;

  @override
  Future<void> load(List<Track> tracks, int index, {bool live = false}) async {
    _holding = false;
    _holdTitle = null;
    await usePlaybackSession();
    await _player.setVolume(1);
    if (live) {
      // A live mount never reports a duration. Waiting for one leaves the
      // player spinning with no sound.
      await _player.setAudioSource(_source(tracks[index]), preload: false);
      await _player.play();
      return;
    }
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
  Future<void> setVolume(double volume) async => _p?.setVolume(volume);

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

  @override
  Future<void> holdInBackground(String title) async {
    if (_holding && _holdTitle == title) return;
    _holding = true;
    _holdTitle = title;
    try {
      await usePlaybackSession();
      await _player.setVolume(1);
      await _player.setLoopMode(LoopMode.one);
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse('asset:///assets/sounds/silence.wav'),
          tag: MediaItem(id: 'recite-work', title: title, artist: 'Sabeelak'),
        ),
      );
      await _player.play();
    } catch (_) {
      _holding = false;
    }
  }

  @override
  Future<void> releaseBackgroundHold() async {
    if (!_holding) return;
    _holding = false;
    _holdTitle = null;
    try {
      await _player.stop();
      await _player.setLoopMode(LoopMode.off);
    } catch (_) {}
  }
}
