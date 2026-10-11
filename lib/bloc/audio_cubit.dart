import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Key of the clip currently playing (e.g. "name:1", "dua:3"), or null.
/// One player for the whole app so two clips never overlap.
class AudioCubit extends Cubit<String?> {
  AudioCubit({AudioPlayer? player})
    : _player = player ?? AudioPlayer(),
      super(null) {
    _done = _player.onPlayerComplete.listen((_) => emit(null));
  }

  final AudioPlayer _player;
  late final StreamSubscription<void> _done;

  Future<void> toggle(String key, Uri url) async {
    if (state == key) {
      await _player.stop();
      emit(null);
      return;
    }
    emit(key);
    try {
      await _player.stop();
      await _player.play(UrlSource(url.toString()));
    } catch (_) {
      if (state == key) emit(null);
    }
  }

  Future<void> stop() async {
    await _player.stop();
    emit(null);
  }

  @override
  Future<void> close() async {
    await _done.cancel();
    await _player.dispose();
    return super.close();
  }
}
