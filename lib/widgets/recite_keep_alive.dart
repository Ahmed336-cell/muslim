import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran/recitation_cubit.dart';
import '../bloc/quran/recite_cubit.dart';
import '../l10n/l10n.dart';
import '../services/notifications.dart';
import '../services/player.dart';

/// Keeps a Tarteel model download or recitation check running after the
/// user leaves the screen or the app. Silence on the media session holds
/// the process open; a notification shows the progress.
class ReciteKeepAlive extends StatefulWidget {
  const ReciteKeepAlive({super.key, required this.child});

  final Widget child;

  @override
  State<ReciteKeepAlive> createState() => _ReciteKeepAliveState();
}

class _ReciteKeepAliveState extends State<ReciteKeepAlive> {
  var _bucket = -1;

  void _sync(BuildContext context, ReciteState state) {
    final audio = context.read<AudioEngine>();
    final notes = context.read<PrayerNotifier>();
    final needs =
        state.phase == RecitePhase.downloading ||
        state.phase == RecitePhase.checking;
    if (!needs) {
      if (_bucket < 0) return;
      _bucket = -1;
      unawaited(audio.releaseBackgroundHold());
      unawaited(notes.clearWork());
      return;
    }

    final l = context.l;
    final title = state.phase == RecitePhase.checking
        ? l.reciteChecking
        : l.reciteWorkDownload;
    final bucket = state.phase == RecitePhase.downloading
        ? (state.progress * 20).floor()
        : 100;
    if (!context.read<RecitationCubit>().state.active) {
      unawaited(audio.holdInBackground(title));
    }
    if (bucket == _bucket) return;
    _bucket = bucket;
    unawaited(
      notes.showWork(
        title,
        state.phase == RecitePhase.downloading
            ? l.reciteDownloading(
                '${context.n((state.progress * 100).round())}%',
              )
            : l.reciteChecking,
        progress: state.phase == RecitePhase.downloading
            ? state.progress
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReciteCubit, ReciteState>(
      listenWhen: (a, b) => a.phase != b.phase || a.progress != b.progress,
      listener: _sync,
      child: widget.child,
    );
  }
}
