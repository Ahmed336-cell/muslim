import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/recitation.dart';

typedef SurahFile = (int recording, int surah);

final class Downloads extends Equatable {
  const Downloads({this.saved = const {}, this.progress = const {}});

  final Set<SurahFile> saved;

  /// In-flight downloads, 0…1.
  final Map<SurahFile, double> progress;

  @override
  List<Object> get props => [saved, progress];
}

/// Surahs saved for offline listening.
class DownloadsCubit extends Cubit<Downloads> {
  DownloadsCubit({required this._store}) : super(const Downloads()) {
    _store.saved().then((s) {
      if (!isClosed) emit(Downloads(saved: s, progress: state.progress));
    }, onError: (Object _) {});
  }

  final AudioStore _store;

  /// Downloaded files for [recording], keyed by surah.
  Future<Map<int, Uri>> local(int recording) async {
    final found = <int, Uri>{};
    for (final (r, s) in state.saved) {
      if (r != recording) continue;
      final uri = await _store.local(r, s);
      if (uri != null) found[s] = uri;
    }
    return found;
  }

  /// Returns false if the download failed.
  Future<bool> download(Recording recording, int surah) async {
    final key = (recording.id, surah);
    if (state.saved.contains(key) || state.progress.containsKey(key)) {
      return true;
    }
    _progress(key, 0);
    try {
      await _store.download(
        recording.id,
        surah,
        recording.surahUrl(surah),
        onProgress: (p) => _progress(key, p),
      );
      emit(
        Downloads(
          saved: {...state.saved, key},
          progress: {...state.progress}..remove(key),
        ),
      );
      return true;
    } catch (_) {
      emit(
        Downloads(
          saved: state.saved,
          progress: {...state.progress}..remove(key),
        ),
      );
      return false;
    }
  }

  void _progress(SurahFile key, double p) {
    if (isClosed) return;
    // Throttle to whole percents; chunks arrive far more often.
    final old = state.progress[key];
    if (old != null && (p - old) < .01 && p < 1) return;
    emit(Downloads(saved: state.saved, progress: {...state.progress, key: p}));
  }

  Future<void> delete(int recording, int surah) async {
    await _store.delete(recording, surah);
    emit(
      Downloads(
        saved: {...state.saved}..remove((recording, surah)),
        progress: state.progress,
      ),
    );
  }
}
