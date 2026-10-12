import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data.dart';
import '../../services/islamic_api.dart' show ApiException;
import '../../services/quran.dart';

final class TafsirState extends Equatable {
  const TafsirState({
    required this.surah,
    required this.ayah,
    required this.source,
    this.verse,
    this.text,
    this.error,
  });

  final int surah;
  final int ayah;
  final TafsirSource source;

  /// The ayah itself, in the reader's mushaf.
  final Ayah? verse;
  final String? text;
  final String? error;

  bool get loading => text == null && error == null;

  bool get isFirst => surah == 1 && ayah == 1;
  bool get isLast => surah == 114 && ayah == surahs.last.ayahs;

  @override
  List<Object?> get props => [surah, ayah, source, verse, text, error];
}

/// Tafsir of one ayah at a time, for the reader's bottom sheet. Moving
/// past the last ayah of a surah continues into the next one.
class TafsirCubit extends Cubit<TafsirState> {
  TafsirCubit({
    required this._api,
    required this.mushaf,
    required int surah,
    required int ayah,
    required TafsirSource source,
  }) : super(TafsirState(surah: surah, ayah: ayah, source: source)) {
    _load();
  }

  final QuranApi _api;
  final Mushaf mushaf;

  void next() {
    if (state.isLast) return;
    final s = state.surah;
    state.ayah < surahs[s - 1].ayahs
        ? _goTo(s, state.ayah + 1, state.source)
        : _goTo(s + 1, 1, state.source);
  }

  void previous() {
    if (state.isFirst) return;
    final s = state.surah;
    state.ayah > 1
        ? _goTo(s, state.ayah - 1, state.source)
        : _goTo(s - 1, surahs[s - 2].ayahs, state.source);
  }

  void setSource(TafsirSource source) {
    if (source == state.source && state.error == null) return;
    emit(
      TafsirState(
        surah: state.surah,
        ayah: state.ayah,
        source: source,
        verse: state.verse,
      ),
    );
    _load();
  }

  void retry() => setSource(state.source);

  void _goTo(int surah, int ayah, TafsirSource source) {
    emit(TafsirState(surah: surah, ayah: ayah, source: source));
    _load();
  }

  bool _isCurrent(TafsirState s) =>
      !isClosed && state.surah == s.surah && state.ayah == s.ayah;

  Future<void> _load() async {
    final start = state;
    if (start.verse == null) {
      _api
          .fetchAyah(start.surah, start.ayah, mushaf)
          .then((verse) {
            if (_isCurrent(start)) {
              emit(
                TafsirState(
                  surah: state.surah,
                  ayah: state.ayah,
                  source: state.source,
                  verse: verse,
                  text: state.text,
                  error: state.error,
                ),
              );
            }
          })
          .catchError((_) {});
    }

    String? text;
    String? error;
    try {
      text = await _api.fetchTafsir(start.source, start.surah, start.ayah);
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = ApiException.badResponse;
    }
    if (!_isCurrent(start) || state.source != start.source) return;
    emit(
      TafsirState(
        surah: state.surah,
        ayah: state.ayah,
        source: state.source,
        verse: state.verse,
        text: text,
        error: error,
      ),
    );
  }
}
