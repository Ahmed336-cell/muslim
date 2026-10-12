import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart' show IconData, Icons;

/// Looping background sounds, bundled under assets/sounds (from the Google
/// sound library, CC BY 4.0).
enum Ambient {
  rain(Icons.water_drop_outlined),
  storm(Icons.thunderstorm_outlined),
  fire(Icons.local_fire_department_outlined),
  waves(Icons.waves_rounded),
  birds(Icons.forest_outlined),
  night(Icons.nightlight_outlined),
  wind(Icons.air_rounded);

  const Ambient(this.icon);

  final IconData icon;

  String get asset => 'sounds/$name.m4a';
}

/// Mixes ambient loops under the recitation; faked in tests.
abstract class AmbientEngine {
  /// Starts [sound], or resumes it at [volume] if already loaded.
  Future<void> start(Ambient sound, double volume);
  Future<void> setVolume(Ambient sound, double volume);
  Future<void> stop(Ambient sound);
  Future<void> pauseAll();
  Future<void> dispose();
}

class AudioplayersAmbient implements AmbientEngine {
  final _players = <Ambient, AudioPlayer>{};

  // No audio focus on Android, so the recitation isn't paused by it; iOS
  // keeps the regular playback session for lock-screen controls.
  static final _context = AudioContext(
    android: const AudioContextAndroid(
      audioFocus: AndroidAudioFocus.none,
      usageType: AndroidUsageType.media,
      contentType: AndroidContentType.music,
      stayAwake: true,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const {},
    ),
  );

  @override
  Future<void> start(Ambient sound, double volume) async {
    final existing = _players[sound];
    if (existing != null) {
      await existing.setVolume(volume);
      if (existing.state != PlayerState.playing) await existing.resume();
      return;
    }
    final p = _players[sound] = AudioPlayer(playerId: 'ambient-${sound.name}');
    await p.setAudioContext(_context);
    await p.setReleaseMode(ReleaseMode.loop);
    await p.setVolume(volume);
    await p.play(AssetSource(sound.asset));
  }

  @override
  Future<void> setVolume(Ambient sound, double volume) async =>
      _players[sound]?.setVolume(volume);

  @override
  Future<void> stop(Ambient sound) async {
    final p = _players.remove(sound);
    await p?.stop();
    await p?.dispose();
  }

  @override
  Future<void> pauseAll() async {
    for (final p in _players.values) {
      await p.pause();
    }
  }

  @override
  Future<void> dispose() async {
    for (final p in _players.values) {
      await p.dispose();
    }
    _players.clear();
  }
}
