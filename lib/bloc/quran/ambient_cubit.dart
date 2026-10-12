import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../services/ambient.dart';

final class AmbientMix extends Equatable {
  const AmbientMix({this.volumes = const {}});

  static const defaultVolume = .4;

  /// Sounds in the mix and their volume, 0…1.
  final Map<Ambient, double> volumes;

  bool contains(Ambient a) => volumes.containsKey(a);

  @override
  List<Object> get props => [volumes];
}

/// Background sounds that play along with the recitation and pause with it.
class AmbientCubit extends HydratedCubit<AmbientMix> {
  AmbientCubit({required this._engine}) : super(const AmbientMix());

  final AmbientEngine _engine;
  bool _live = false;

  Future<void> toggle(Ambient sound) async {
    if (state.contains(sound)) {
      emit(AmbientMix(volumes: {...state.volumes}..remove(sound)));
      await _guard(() => _engine.stop(sound));
    } else {
      emit(
        AmbientMix(
          volumes: {...state.volumes, sound: AmbientMix.defaultVolume},
        ),
      );
      if (_live) {
        await _guard(() => _engine.start(sound, AmbientMix.defaultVolume));
      }
    }
  }

  Future<void> setVolume(Ambient sound, double volume) async {
    if (!state.contains(sound)) return;
    final v = volume.clamp(0.0, 1.0);
    emit(AmbientMix(volumes: {...state.volumes, sound: v}));
    await _guard(() => _engine.setVolume(sound, v));
  }

  Future<void> clearMix() async {
    final playing = state.volumes.keys.toList();
    emit(const AmbientMix());
    for (final s in playing) {
      await _guard(() => _engine.stop(s));
    }
  }

  /// Follows the recitation: sounds run only while it plays.
  Future<void> setLive(bool live) async {
    if (live == _live) return;
    _live = live;
    if (live) {
      for (final MapEntry(key: s, value: v) in state.volumes.entries) {
        await _guard(() => _engine.start(s, v));
      }
    } else {
      await _guard(_engine.pauseAll);
    }
  }

  static Future<void> _guard(Future<void> Function() f) async {
    try {
      await f();
    } catch (_) {
      // A missing platform player shouldn't break the recitation.
    }
  }

  @override
  Future<void> close() async {
    await _engine.dispose();
    return super.close();
  }

  @override
  AmbientMix? fromJson(Map<String, dynamic> json) => AmbientMix(
    volumes: {
      for (final MapEntry(:key, :value)
          in (json['volumes'] as Map? ?? const {}).entries)
        ?Ambient.values.asNameMap()[key]: (value as num).toDouble(),
    },
  );

  @override
  Map<String, dynamic> toJson(AmbientMix state) => {
    'volumes': {for (final e in state.volumes.entries) e.key.name: e.value},
  };
}
