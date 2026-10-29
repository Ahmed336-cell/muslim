import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../services/identify_guard.dart';
import '../../services/notifications.dart';
import '../../services/quran.dart';
import '../../services/quran_text.dart';
import '../../services/recite_engine.dart';
import '../../services/reciter_id.dart';

enum IdentifyPhase { idle, downloading, listening, matching, result }

class IdentifyState extends Equatable {
  const IdentifyState({
    this.phase = IdentifyPhase.idle,
    this.progress = 0,
    this.background = true,
    this.message,
    this.match,
    this.ayah,
    this.span,
  });

  final IdentifyPhase phase;
  final double progress;

  /// When true, leave the app — mic + models keep going.
  final bool background;
  final String? message;
  final ReciterMatch? match;
  final Ayah? ayah;
  final VerseSpan? span;

  bool get busy =>
      phase == IdentifyPhase.downloading ||
      phase == IdentifyPhase.listening ||
      phase == IdentifyPhase.matching;

  IdentifyState copyWith({
    IdentifyPhase? phase,
    double? progress,
    bool? background,
    String? message,
    ReciterMatch? match,
    Ayah? ayah,
    VerseSpan? span,
    bool clearMessage = false,
    bool clearResult = false,
  }) => IdentifyState(
    phase: phase ?? this.phase,
    progress: progress ?? this.progress,
    background: background ?? this.background,
    message: clearMessage ? null : message ?? this.message,
    match: clearResult ? null : match ?? this.match,
    ayah: clearResult ? null : ayah ?? this.ayah,
    span: clearResult ? null : span ?? this.span,
  );

  @override
  List<Object?> get props => [
    phase,
    progress,
    background,
    message,
    match,
    ayah,
    span,
  ];
}

/// Owns identify so leaving the screen (or the app) does not cancel it.
class IdentifyCubit extends Cubit<IdentifyState> {
  IdentifyCubit({
    required ReciterId id,
    required ReciteEngine recite,
    required QuranText quran,
    PrayerNotifier? notifier,
  }) : _id = id,
       _recite = recite,
       _quran = quran,
       _notifier = notifier ?? PrayerNotifier(),
       super(const IdentifyState());

  final ReciterId _id;
  final ReciteEngine _recite;
  final QuranText _quran;
  final PrayerNotifier _notifier;
  var _gen = 0;

  void setBackground(bool on) => emit(state.copyWith(background: on));

  Future<void> start({
    required String downloading,
    required String listening,
    required String matching,
    required String empty,
    required String needMic,
    required String unknown,
    required String failed,
    required String readyTitle,
    required String Function(ReciterMatch match, Ayah? ayah) readyBody,
  }) async {
    if (state.busy) return;
    final gen = ++_gen;
    emit(
      state.copyWith(
        phase: IdentifyPhase.downloading,
        progress: 0,
        clearMessage: true,
        clearResult: true,
      ),
    );
    final background = state.background;
    try {
      await WakelockPlus.enable();
      if (background) {
        await IdentifyGuard.start(title: downloading, body: listening);
      }
      await _id.downloadModel(
        onProgress: (p) {
          if (gen != _gen) return;
          emit(state.copyWith(progress: p * .5));
        },
      );
      if (gen != _gen) return;
      if (!await _recite.hasModel()) {
        await _recite.downloadModel(
          onProgress: (p) {
            if (gen != _gen) return;
            emit(state.copyWith(progress: .5 + p * .5));
          },
        );
      }
      if (gen != _gen) return;
      await _id.loadCatalog();
      if (!_id.catalogReady) {
        emit(state.copyWith(phase: IdentifyPhase.idle, message: empty));
        return;
      }
      emit(
        state.copyWith(
          phase: IdentifyPhase.listening,
          progress: 0,
          clearMessage: true,
        ),
      );
      if (background) {
        await IdentifyGuard.update(title: listening, body: matching);
      }
      unawaited(_recite.warmModel());
      final capture = await _id.listen(
        onProgress: (p) {
          if (gen != _gen) return;
          emit(state.copyWith(progress: p));
        },
      );
      if (gen != _gen) return;
      if (capture == null) {
        emit(state.copyWith(phase: IdentifyPhase.idle));
        return;
      }
      if (capture.denied || capture.matches.isEmpty) {
        emit(
          state.copyWith(
            phase: IdentifyPhase.idle,
            message: capture.denied ? needMic : unknown,
          ),
        );
        return;
      }
      emit(state.copyWith(phase: IdentifyPhase.matching, clearMessage: true));
      if (background) {
        await IdentifyGuard.update(title: matching, body: listening);
      }
      // Reciter + ayah together — wait for both before result.
      final top = capture.matches.first;
      final transcript = await _recite.transcribePcm(
        capture.pcm,
        maxSeconds: 10,
      );
      if (gen != _gen) return;
      final span = transcript.isEmpty
          ? null
          : await _quran.locateSpan(transcript);
      if (gen != _gen) return;
      emit(
        IdentifyState(
          phase: IdentifyPhase.result,
          background: state.background,
          match: top,
          span: span,
          ayah: span?.start,
        ),
      );
      if (background) {
        await _notifier.showIdentifyReady(
          title: readyTitle,
          body: readyBody(top, span?.start),
        );
      }
    } catch (error, stack) {
      debugPrint('identify failed: $error\n$stack');
      if (gen != _gen) return;
      emit(state.copyWith(phase: IdentifyPhase.idle, message: failed));
    } finally {
      if (gen == _gen) {
        await IdentifyGuard.stop();
        await WakelockPlus.disable();
        await _notifier.clearWork();
      }
    }
  }

  void stop() {
    _gen++;
    _id.stop();
    unawaited(IdentifyGuard.stop());
    unawaited(WakelockPlus.disable());
    unawaited(_notifier.clearWork());
    if (state.busy) {
      emit(state.copyWith(phase: IdentifyPhase.idle));
    }
  }

  @override
  Future<void> close() {
    stop();
    return super.close();
  }
}
