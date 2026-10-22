import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// One clip in the shared [AudioCubit] player.
final class AudioSession extends Equatable {
  const AudioSession({
    required this.key,
    required this.url,
    this.playing = true,
  });

  final String key;
  final Uri url;

  /// False while paused; null session means stopped.
  final bool playing;

  AudioSession copyWith({bool? playing}) =>
      AudioSession(key: key, url: url, playing: playing ?? this.playing);

  @override
  List<Object?> get props => [key, url, playing];
}

/// Key of the clip currently loaded (e.g. "name:1", "tawashih:…"), or null.
/// One player for the whole app so two clips never overlap.
class AudioCubit extends Cubit<AudioSession?> {
  AudioCubit({AudioPlayer? player})
    : _player = player ?? AudioPlayer(),
      super(null) {
    _done = _player.onPlayerComplete.listen((_) => emit(null));
    _states = _player.onPlayerStateChanged.listen((s) {
      final cur = state;
      if (cur == null) return;
      if (s == PlayerState.playing && !cur.playing) {
        emit(cur.copyWith(playing: true));
      } else if (s == PlayerState.paused && cur.playing) {
        emit(cur.copyWith(playing: false));
      }
    });
  }

  final AudioPlayer _player;
  late final StreamSubscription<void> _done;
  late final StreamSubscription<PlayerState> _states;

  String? get activeKey => state?.key;

  bool isActive(String key) => state?.key == key;

  bool isPlaying(String key) => state?.key == key && (state?.playing ?? false);

  Future<void> toggle(String key, Uri url) async {
    final cur = state;
    if (cur?.key == key) {
      if (cur!.playing) {
        await pause();
      } else {
        await resume();
      }
      return;
    }
    emit(AudioSession(key: key, url: url));
    try {
      await _player.stop();
      await _player.play(UrlSource(url.toString()));
    } catch (_) {
      if (state?.key == key) emit(null);
    }
  }

  Future<void> pause() async {
    await _player.pause();
    final cur = state;
    if (cur != null && cur.playing) emit(cur.copyWith(playing: false));
  }

  Future<void> resume() async {
    final cur = state;
    if (cur == null) return;
    try {
      await _player.resume();
      emit(cur.copyWith(playing: true));
    } catch (_) {
      try {
        await _player.play(UrlSource(cur.url.toString()));
        emit(cur.copyWith(playing: true));
      } catch (_) {
        emit(null);
      }
    }
  }

  Future<void> stop() async {
    await _player.stop();
    emit(null);
  }

  @override
  Future<void> close() async {
    await _done.cancel();
    await _states.cancel();
    await _player.dispose();
    return super.close();
  }
}
