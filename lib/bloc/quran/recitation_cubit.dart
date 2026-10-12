import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data.dart';
import '../../l10n/l10n.dart' show arabicDigits;
import '../../services/player.dart';
import '../../services/recitation.dart';
import '../../services/reciter_photos.dart';

enum RecitationKind {
  /// Verse by verse while reading; follows along in the mushaf.
  ayahs,

  /// Whole surahs from a reciter's recording.
  surahs,
}

final class RecitationState extends Equatable {
  const RecitationState({
    this.kind,
    this.tracks = const [],
    this.index = 0,
    this.playing = false,
    this.buffering = false,
    this.error = false,
    this.repeat = false,
    this.recording,
  });

  final RecitationKind? kind;
  final List<Track> tracks;
  final int index;
  final bool playing;
  final bool buffering;
  final bool error;

  /// The current track loops.
  final bool repeat;

  /// mp3quran recording id when playing whole surahs.
  final int? recording;

  Track? get current => tracks.isEmpty ? null : tracks[index];
  bool get active => current != null;
  bool get hasNext => index < tracks.length - 1;
  bool get hasPrevious => index > 0;

  /// The ayah being recited, when following along.
  (int, int)? get ayah => kind == RecitationKind.ayahs ? current?.ayah : null;

  RecitationState _copy({
    List<Track>? tracks,
    int? index,
    bool? playing,
    bool? buffering,
    bool? error,
    bool? repeat,
  }) => RecitationState(
    kind: kind,
    tracks: tracks ?? this.tracks,
    index: index ?? this.index,
    playing: playing ?? this.playing,
    buffering: buffering ?? this.buffering,
    error: error ?? this.error,
    repeat: repeat ?? this.repeat,
    recording: recording,
  );

  @override
  List<Object?> get props => [
    kind,
    tracks.length,
    tracks.isEmpty ? null : tracks.first.id,
    index,
    playing,
    buffering,
    error,
    repeat,
    recording,
  ];
}

/// The Quran player: one queue for the whole app.
class RecitationCubit extends Cubit<RecitationState> {
  RecitationCubit({required this._engine}) : super(const RecitationState()) {
    _sub = _engine.states.listen(
      _onEngine,
      onError: (Object _) =>
          emit(state._copy(playing: false, buffering: false, error: true)),
    );
  }

  final AudioEngine _engine;
  late final StreamSubscription<EngineState> _sub;
  AyahReciter? _reciter;
  String _language = 'en';
  bool _extending = false;

  Stream<Duration> get position => _engine.position;
  Stream<Duration?> get duration => _engine.duration;

  static String surahTitle(int surah, String language) => language == 'ar'
      ? 'سورة ${surahs[surah - 1].arabic}'
      : surahs[surah - 1].name;

  static List<Track> _ayahTracks(
    int surah,
    int from,
    AyahReciter reciter,
    String language,
  ) => [
    for (var a = from; a <= surahs[surah - 1].ayahs; a++)
      Track(
        id: '${reciter.id}:$surah:$a',
        uri: reciter.ayahUrl(surah, a),
        title:
            '${surahTitle(surah, language)} · '
            '${language == 'ar' ? arabicDigits('$a') : '$a'}',
        artist: reciter.label(language),
        surah: surah,
        ayah: (surah, a),
        art: reciterPhoto(reciter.mp3quranId),
      ),
  ];

  /// Recites from [surah]:[ayah] on, running into the following surahs.
  Future<void> playAyahs(
    int surah,
    int ayah,
    AyahReciter reciter,
    String language,
  ) async {
    _reciter = reciter;
    _language = language;
    final tracks = _ayahTracks(surah, ayah, reciter, language);
    emit(
      RecitationState(
        kind: RecitationKind.ayahs,
        tracks: tracks,
        buffering: true,
        playing: true,
      ),
    );
    await _load(tracks, 0);
  }

  /// For memorising: each ayah of [surah] [from]–[to] is heard [ayahRepeat]
  /// times, and the whole range [rangeRepeat] times. Doesn't run on into the
  /// next surah.
  Future<void> playHifz(
    int surah,
    int from,
    int to,
    AyahReciter reciter,
    String language, {
    int ayahRepeat = 1,
    int rangeRepeat = 1,
  }) async {
    _reciter = null;
    _language = language;
    final ayahs = _ayahTracks(
      surah,
      from,
      reciter,
      language,
    ).take(to - from + 1).toList();
    final tracks = [
      for (var r = 0; r < rangeRepeat; r++)
        for (final t in ayahs)
          for (var i = 0; i < ayahRepeat; i++)
            Track(
              id: 'hifz:$r:$i:${t.id}',
              uri: t.uri,
              title: t.title,
              artist: t.artist,
              surah: t.surah,
              ayah: t.ayah,
              art: t.art,
            ),
    ];
    if (state.repeat) await _engine.setRepeat(false);
    emit(
      RecitationState(
        kind: RecitationKind.ayahs,
        tracks: tracks,
        buffering: true,
        playing: true,
      ),
    );
    await _load(tracks, 0);
  }

  /// Queues every surah of [recording], starting at [surah]. [local] holds
  /// downloaded files that should play instead of streaming.
  Future<void> playSurahs(
    Reciter reciter,
    Recording recording,
    int surah,
    String language, {
    Map<int, Uri> local = const {},
  }) async {
    _reciter = null;
    final tracks = [
      for (final s in recording.surahs)
        Track(
          id: '${recording.id}:$s',
          uri: local[s] ?? recording.surahUrl(s),
          title: surahTitle(s, language),
          artist: reciter.name,
          surah: s,
          art: reciterPhoto(reciter.id),
        ),
    ];
    final index = recording.surahs.indexOf(surah);
    emit(
      RecitationState(
        kind: RecitationKind.surahs,
        tracks: tracks,
        index: index < 0 ? 0 : index,
        buffering: true,
        playing: true,
        recording: recording.id,
      ),
    );
    await _load(tracks, state.index);
  }

  Future<void> _load(List<Track> tracks, int index) async {
    try {
      await _engine.setRepeat(state.repeat);
      await _engine.load(tracks, index);
    } catch (_) {
      if (identical(state.tracks, tracks)) {
        emit(state._copy(playing: false, buffering: false, error: true));
      }
    }
  }

  void _onEngine(EngineState e) {
    if (!state.active) return;
    final index = (e.index ?? state.index).clamp(0, state.tracks.length - 1);
    emit(
      state._copy(
        index: index,
        playing: e.playing && !e.completed,
        buffering: e.buffering,
        error: false,
      ),
    );
    if (state.kind == RecitationKind.ayahs &&
        index >= state.tracks.length - 2) {
      unawaited(_extend());
    }
  }

  /// Keeps the queue one surah ahead so recitation flows on.
  Future<void> _extend() async {
    final reciter = _reciter;
    final last = state.tracks.last.surah;
    if (_extending || reciter == null || last >= surahs.length) return;
    _extending = true;
    final more = _ayahTracks(last + 1, 1, reciter, _language);
    final tracks = state.tracks;
    try {
      await _engine.append(more);
      if (identical(state.tracks, tracks)) {
        emit(state._copy(tracks: [...tracks, ...more]));
      }
    } catch (_) {
      // Recitation simply stops at the end of this surah.
    } finally {
      _extending = false;
    }
  }

  Future<void> toggle() async {
    if (!state.active) return;
    if (state.playing) {
      emit(state._copy(playing: false));
      await _engine.pause();
    } else if (state.error) {
      emit(state._copy(error: false, buffering: true, playing: true));
      await _load(state.tracks, state.index);
    } else {
      emit(state._copy(playing: true));
      await _engine.play();
    }
  }

  Future<void> pause() async {
    if (!state.playing) return;
    emit(state._copy(playing: false));
    await _engine.pause();
  }

  Future<void> next() => skipTo(state.index + 1);

  Future<void> previous() => skipTo(state.index - 1);

  Future<void> skipTo(int index) async {
    if (index < 0 || index >= state.tracks.length) return;
    emit(state._copy(index: index, playing: true, error: false));
    await _engine.skipTo(index);
  }

  Future<void> seek(Duration position) => _engine.seek(position);

  Future<void> toggleRepeat() async {
    if (!state.active) return;
    final repeat = !state.repeat;
    emit(state._copy(repeat: repeat));
    await _engine.setRepeat(repeat);
  }

  Future<void> stop() async {
    _reciter = null;
    final repeat = state.repeat;
    emit(const RecitationState());
    if (repeat) await _engine.setRepeat(false);
    await _engine.stop();
  }

  @override
  Future<void> close() async {
    await _sub.cancel();
    await _engine.dispose();
    return super.close();
  }
}
