import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/quran/ambient_cubit.dart';
import '../bloc/quran/recitation_cubit.dart';
import '../data.dart';
import '../l10n/l10n.dart';
import '../screens/now_playing_screen.dart';
import '../theme.dart';
import 'gramophone_disc.dart';
import 'listen_style.dart';
import 'reciter_art.dart';

/// Shared by every mini player so hiding the ayah hides it everywhere.
final _miniAyah = ValueNotifier<bool>(true);

/// Floating now-playing card; invisible while nothing is queued. Tap to
/// open the full player.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
    this.canOpenReader = true,
    this.safeArea = true,
  });

  /// The full player may jump to the mushaf; off inside the mushaf.
  final bool canOpenReader;

  /// Pad for the home indicator when nothing sits below the bar.
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cubit = context.read<RecitationCubit>();
    final s = context.watch<RecitationCubit>().state;
    final track = s.current;
    if (track == null) return const SizedBox.shrink();
    final quran =
        s.kind != RecitationKind.tawashih &&
        s.kind != RecitationKind.radio &&
        s.kind != RecitationKind.tafsir &&
        track.surah >= 1 &&
        track.surah <= surahs.length;
    final (_, dark) = coverColors(track.artist);
    final ambient = context.select(
      (AmbientCubit c) => c.state.volumes.isNotEmpty,
    );

    return SafeArea(
      top: false,
      bottom: safeArea,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
        child: Material(
          color: Palette.dark
              ? Listen.surfaceHi
              : Color.alphaBlend(Colors.black.withValues(alpha: .25), dark),
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          elevation: 6,
          shadowColor: Colors.black45,
          child: InkWell(
            onTap: () => showNowPlaying(context, canOpenReader: canOpenReader),
            child: ValueListenableBuilder<bool>(
              valueListenable: _miniAyah,
              builder: (context, showAyah, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (quran && showAyah)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 2, 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: AyahBar(
                              cubit: cubit,
                              surah: track.surah,
                              ayah: s.ayah?.$2,
                              recording: s.ayah == null ? s.recording : null,
                              clip: track.start ?? Duration.zero,
                              canOpenReader: false,
                              top: 0,
                            ),
                          ),
                          IconButton(
                            tooltip: l.hideMeaning,
                            color: Listen.textSoft,
                            onPressed: () => _miniAyah.value = false,
                            icon: const Icon(
                              Icons.visibility_off_outlined,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 4, 6),
                    child: Row(
                      children: [
                        s.kind == RecitationKind.tawashih ||
                                s.kind == RecitationKind.radio ||
                                s.kind == RecitationKind.tafsir
                            ? GramophoneDisc(
                                name: track.artist,
                                spinning: s.playing,
                                size: 42,
                              )
                            : ReciterArt(
                                name: track.artist,
                                size: 42,
                                label: surahs[track.surah - 1].arabic,
                                photo: track.art,
                              ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Fonts.body(
                                  14,
                                  color: Listen.text,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                s.error ? l.playbackError : track.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Fonts.body(
                                  12.5,
                                  color: s.error
                                      ? Palette.clay
                                      : Listen.textSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (ambient)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.spa_outlined,
                              size: 18,
                              color: Listen.accent,
                            ),
                          ),
                        if (quran && !showAyah)
                          IconButton(
                            tooltip: l.showMeaning,
                            color: Listen.textSoft,
                            onPressed: () => _miniAyah.value = true,
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 20,
                            ),
                          ),
                        SizedBox.square(
                          dimension: 44,
                          child: s.buffering && s.playing
                              ? Padding(
                                  padding: EdgeInsets.all(13),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Listen.text,
                                  ),
                                )
                              : IconButton(
                                  tooltip: s.playing ? l.pauseTip : l.playTip,
                                  color: Listen.text,
                                  onPressed: cubit.toggle,
                                  icon: Icon(
                                    s.playing
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 30,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  _Progress(cubit: cubit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.cubit});

  final RecitationCubit cubit;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: cubit.duration,
      builder: (context, total) => StreamBuilder<Duration>(
        stream: cubit.position,
        builder: (context, pos) {
          final t = total.data?.inMilliseconds ?? 0;
          final p = pos.data?.inMilliseconds ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: LinearProgressIndicator(
              value: t > 0 ? (p / t).clamp(0.0, 1.0) : 0,
              minHeight: 2,
              borderRadius: BorderRadius.circular(1),
              backgroundColor: Listen.textFaint,
              color: Listen.text,
            ),
          );
        },
      ),
    );
  }
}
