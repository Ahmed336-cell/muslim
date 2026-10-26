import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data.dart';
import '../../l10n/l10n.dart' show arabicDigits;
import '../../services/player.dart';
import '../../services/quran_radio.dart';
import '../../services/recitation.dart';
import '../../services/tafsir.dart';
import '../../services/reciter_photos.dart';

enum RecitationKind {
  /// Verse by verse while reading; follows along in the mushaf.
  ayahs,

  /// Whole surahs from a reciter's recording.
  surahs,

  /// Prophetic praise (تواشيح) queue from a munshid.
  tawashih,

  /// Live إذاعة القرآن الكريم stream.
  radio,

  /// Spoken tafsir, one passage per track.
  tafsir,
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
    this.sleepAt,
    this.sleepAfterSurah = false,
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

  /// Playback fades out and pauses at this time.
  final DateTime? sleepAt;

  /// Playback pauses when the current surah ends.
  final bool sleepAfterSurah;

  bool get sleepOn => sleepAt != null || sleepAfterSurah;

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
    DateTime? Function()? sleepAt,
    bool? sleepAfterSurah,
  }) => RecitationState(
    kind: kind,
    tracks: tracks ?? this.tracks,
    index: index ?? this.index,
    playing: playing ?? this.playing,
    buffering: buffering ?? this.buffering,
    error: error ?? this.error,
    repeat: repeat ?? this.repeat,
    recording: recording,
    sleepAt: sleepAt != null ? sleepAt() : this.sleepAt,
    sleepAfterSurah: sleepAfterSurah ?? this.sleepAfterSurah,
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
    sleepAt,
    sleepAfterSurah,
  ];
}

/// The Quran player: one queue for the whole app.
class RecitationCubit extends Cubit<RecitationState> {
  RecitationCubit({required this._engine, DateTime Function()? now})
    : _now = now ?? DateTime.now,
      super(const RecitationState()) {
    _sub = _engine.states.listen(
      _onEngine,
      onError: (Object _) =>
          emit(state._copy(playing: false, buffering: false, error: true)),
    );
  }

  final AudioEngine _engine;
  final DateTime Function() _now;
  late final StreamSubscription<EngineState> _sub;
  Timer? _sleepTimer;

  /// Ten steps make the bedtime fade-out.
  static const fadeStep = Duration(seconds: 3);
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
        sleepAt: state.sleepAt,
        sleepAfterSurah: state.sleepAfterSurah,
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
        sleepAt: state.sleepAt,
        sleepAfterSurah: state.sleepAfterSurah,
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
    int? ayah,
    Duration? startAt,
  }) async {
    _reciter = null;
    final clip = startAt != null && startAt > Duration.zero ? startAt : null;
    final tracks = [
      for (final s in recording.surahs)
        Track(
          id: '${recording.id}:$s',
          uri: local[s] ?? recording.surahUrl(s),
          title: ayah != null && s == surah
              ? '${surahTitle(s, language)} · '
                    '${language == 'ar' ? arabicDigits('$ayah') : '$ayah'}'
              : surahTitle(s, language),
          artist: reciter.name,
          surah: s,
          art: reciterPhoto(reciter.id),
          start: s == surah ? clip : null,
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
        sleepAt: state.sleepAt,
        sleepAfterSurah: state.sleepAfterSurah,
      ),
    );
    await _load(tracks, state.index);
  }

  /// Queues [tracks] from a tawashih munshid, starting at [index].
  /// [local] maps 1-based track numbers to downloaded files.
  /// [recording] is a stable negative id (see [tawashihRecordingId]).
  Future<void> playTawashih({
    required int recording,
    required String artist,
    required List<({String id, Uri uri, String title})> tracks,
    required int index,
    Map<int, Uri> local = const {},
  }) async {
    _reciter = null;
    if (tracks.isEmpty) return;
    final queue = [
      for (var i = 0; i < tracks.length; i++)
        Track(
          id: 'tawashih:$recording:${tracks[i].id}',
          uri: local[i + 1] ?? tracks[i].uri,
          title: tracks[i].title,
          artist: artist,
          // Slot index for next/prev / sleep-after-track; not a Quran surah.
          surah: i + 1,
        ),
    ];
    final start = index.clamp(0, queue.length - 1);
    emit(
      RecitationState(
        kind: RecitationKind.tawashih,
        tracks: queue,
        index: start,
        buffering: true,
        playing: true,
        recording: recording,
        sleepAt: state.sleepAt,
        sleepAfterSurah: state.sleepAfterSurah,
      ),
    );
    await _load(queue, start);
  }

  /// Queues spoken tafsir passages, starting at [index].
  Future<void> playTafsir({
    required String book,
    required List<TafsirTrack> tracks,
    required int index,
  }) async {
    _reciter = null;
    if (tracks.isEmpty) return;
    final queue = [
      for (final track in tracks)
        Track(
          id: 'tafsir:${track.id}',
          uri: track.url,
          title: track.name,
          artist: book,
          surah: track.surah,
        ),
    ];
    final start = index.clamp(0, queue.length - 1);
    emit(
      RecitationState(
        kind: RecitationKind.tafsir,
        tracks: queue,
        index: start,
        buffering: true,
        playing: true,
        sleepAt: state.sleepAt,
        sleepAfterSurah: state.sleepAfterSurah,
      ),
    );
    await _load(queue, start);
  }

  /// Starts the Cairo Quran radio stream. A second call resumes it.
  Future<void> playRadio({
    required String title,
    required String artist,
  }) async {
    _reciter = null;
    if (state.kind == RecitationKind.radio &&
        state.current?.id == quranRadioId) {
      if (!state.playing) await toggle();
      return;
    }
    final track = Track(
      id: quranRadioId,
      uri: Uri.parse(quranRadioStream),
      title: title,
      artist: artist,
      surah: 0,
    );
    emit(
      RecitationState(
        kind: RecitationKind.radio,
        tracks: [track],
        buffering: true,
        playing: true,
        sleepAt: state.sleepAt,
        sleepAfterSurah: state.sleepAfterSurah,
      ),
    );
    await _load([track], 0, live: true);
  }

  Future<void> _load(List<Track> tracks, int index, {bool live = false}) async {
    try {
      if (!live) await _engine.setRepeat(state.repeat);
      await _engine.setVolume(1);
      await _engine.load(tracks, index, live: live);
    } catch (_) {
      if (identical(state.tracks, tracks)) {
        emit(state._copy(playing: false, buffering: false, error: true));
      }
    }
  }

  void _onEngine(EngineState e) {
    if (!state.active) return;
    final index = (e.index ?? state.index).clamp(0, state.tracks.length - 1);
    if (state.sleepAfterSurah &&
        index != state.index &&
        state.tracks[index].surah != state.tracks[state.index].surah) {
      emit(state._copy(index: index, playing: false, sleepAfterSurah: false));
      unawaited(_engine.pause());
      return;
    }
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
      await _load(
        state.tracks,
        state.index,
        live: state.kind == RecitationKind.radio,
      );
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

  /// Fades out and pauses after [after]; null turns the timer off.
  void setSleepTimer(Duration? after) {
    _sleepTimer?.cancel();
    _sleepTimer = after == null ? null : Timer(after, _fadeOut);
    emit(
      state._copy(
        sleepAt: () => after == null ? null : _now().add(after),
        sleepAfterSurah: false,
      ),
    );
  }

  /// Pauses when the current surah ends.
  void sleepAfterThisSurah() {
    _sleepTimer?.cancel();
    emit(state._copy(sleepAt: () => null, sleepAfterSurah: true));
  }

  Future<void> _fadeOut() async {
    final at = state.sleepAt;
    for (var v = 9; v >= 0 && state.sleepAt == at; v--) {
      await _engine.setVolume(v / 10);
      await Future<void>.delayed(fadeStep);
    }
    if (state.sleepAt != at) {
      await _engine.setVolume(1);
      return;
    }
    emit(state._copy(sleepAt: () => null));
    await pause();
    await _engine.setVolume(1);
  }

  Future<void> stop() async {
    _reciter = null;
    _sleepTimer?.cancel();
    final repeat = state.repeat;
    emit(const RecitationState());
    if (repeat) await _engine.setRepeat(false);
    await _engine.stop();
  }

  @override
  Future<void> close() async {
    _sleepTimer?.cancel();
    await _sub.cancel();
    await _engine.dispose();
    return super.close();
  }
}
