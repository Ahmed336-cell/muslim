import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/quran.dart';
import '../../services/recite_check.dart';
import '../../services/recite_engine.dart';

enum RecitePhase { idle, downloading, recording, checking, done }

enum ReciteError { permission, download, failed, nothing }

final class ReciteState extends Equatable {
  const ReciteState({
    this.phase = RecitePhase.idle,
    this.progress = 0,
    this.result,
    this.error,
  });

  final RecitePhase phase;

  /// Model download, 0…1.
  final double progress;

  /// Live while recording, final once done.
  final ReciteResult? result;
  final ReciteError? error;

  bool get busy => phase != RecitePhase.idle && phase != RecitePhase.done;

  @override
  List<Object?> get props => [phase, progress, result, error];
}

/// Recite a hifz range from memory and mark it word by word.
class ReciteCubit extends Cubit<ReciteState> {
  ReciteCubit({required this._engine}) : super(const ReciteState());

  final ReciteEngine _engine;
  StreamSubscription<String>? _partials;

  Future<bool> hasModel() => _engine.hasModel();

  Future<bool> download() async {
    emit(const ReciteState(phase: RecitePhase.downloading));
    try {
      await _engine.downloadModel(
        onProgress: (p) {
          if (!isClosed) {
            emit(ReciteState(phase: RecitePhase.downloading, progress: p));
          }
        },
      );
      if (!isClosed) emit(const ReciteState());
      return true;
    } catch (_) {
      if (!isClosed) emit(const ReciteState(error: ReciteError.download));
      return false;
    }
  }

  Future<void> start(List<Ayah> ayahs) async {
    emit(const ReciteState(phase: RecitePhase.recording));
    try {
      final partials = await _engine.start();
      if (isClosed) return;
      if (partials == null) {
        emit(const ReciteState(error: ReciteError.permission));
        return;
      }
      _partials = partials.listen((text) {
        if (state.phase != RecitePhase.recording) return;
        emit(
          ReciteState(
            phase: RecitePhase.recording,
            result: ReciteResult.of(ayahs, text),
          ),
        );
      }, onError: (Object _) {});
    } catch (_) {
      if (!isClosed) emit(const ReciteState(error: ReciteError.failed));
    }
  }

  Future<void> finish(List<Ayah> ayahs) async {
    emit(ReciteState(phase: RecitePhase.checking, result: state.result));
    await _partials?.cancel();
    _partials = null;
    try {
      final heard = await _engine.finish();
      if (isClosed) return;
      if (heardWords(heard).isEmpty) {
        emit(const ReciteState(error: ReciteError.nothing));
        return;
      }
      emit(
        ReciteState(
          phase: RecitePhase.done,
          result: ReciteResult.of(ayahs, heard),
        ),
      );
    } catch (_) {
      if (!isClosed) emit(const ReciteState(error: ReciteError.failed));
    }
  }

  Future<void> clear() async {
    if (state.phase == RecitePhase.downloading) return;
    if (state.phase == RecitePhase.recording) {
      await _partials?.cancel();
      _partials = null;
      await _engine.cancel();
    }
    if (!isClosed && state != const ReciteState()) emit(const ReciteState());
  }

  @override
  Future<void> close() async {
    await _partials?.cancel();
    if (state.phase == RecitePhase.recording) await _engine.cancel();
    await _engine.release();
    return super.close();
  }
}
